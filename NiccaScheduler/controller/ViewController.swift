//
//  ViewController.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/05/05.
//

import UIKit
import FSCalendar
import CalculateCalendarLogic
import RealmSwift

class ViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance,
                      UITableViewDelegate, UITableViewDataSource{

    @IBOutlet weak var taskTableView: UITableView!
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var selectedDate: UILabel!
    
    var TaskListResluts: Results<TaskModel>!
    var currentTaskScheduleList: Results<TaskScheduleModel>!
    
    var currentDate = Date()
    let df = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: デバックコード あとで消す
        print("Realm file-----")
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        // カレンダー
        self.calendar.dataSource = self
        self.calendar.delegate = self
        // テーブル
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "Cell")
        // Notificationの登録
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable), name: .submitTodo, object: nil)
        createSchedule(date: Date())
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskCell
        
        // タップ時のハイライトの色を無効に
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if (currentTaskScheduleList.count > 0) {
            let taskSchedule = currentTaskScheduleList[indexPath.row]
            let task = taskSchedule.task.first
            if (task == nil) {
                cell.taskLabel.text = "タスクがありません"
                return cell
            }
            let text = "\(String(describing: task!.taskName!)) \(taskSchedule.scheduleStartPageNumber)〜\( taskSchedule.scheduleEndPageNumber)"
            cell.taskLabel.text = text
            cell.taskScheduleId = taskSchedule.taskScheduleId
            cell.endedPageNumber = taskSchedule.endedPageNumber
            cell.scheduleEndPageNumber = taskSchedule.scheduleEndPageNumber
            
            var isChecked = false
            if (taskSchedule.endedPageNumber > 0 && taskSchedule.scheduleEndPageNumber > 0 && taskSchedule.scheduleEndPageNumber <= taskSchedule.endedPageNumber) {
                isChecked = true
            }
            
            cell.dataInit(isChecked)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (currentTaskScheduleList == nil) { return 0 }
        return currentTaskScheduleList.count
    }
    
    @objc private func updateTable(_ notification: Notification) {
        createSchedule(date: currentDate)
        taskTableView.reloadData()
    }
    
    @objc private func createSchedule(date: Date) {
        let currentDay = date
        selectedDate.text = DateUtils.stringFromDate(date: currentDay, format: "YYYY-MM-dd")
        let calendar = Calendar.current
        let startOfDay =  calendar.startOfDay(for: date)
        let endOfDay =  calendar.endOfDay(for: date)
        currentTaskScheduleList = nil
        
        let RealmInstance = try! Realm()
        TaskListResluts = RealmInstance.objects(TaskModel.self) // TODO: 期間中のタスクに絞る
        if (TaskListResluts.count > 0) {
            for task in TaskListResluts {
                let taskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate >= %@ AND executionDate <= %@", startOfDay, endOfDay).filter("taskId == %@", task.taskId)
                if (taskScheduleList.count == 0) {
                    // その日の分のタスクスケジュールを作成する
                    // TODO: 一旦 page1DayCountから割って算出するけど、実際の前日終了ページ数(endedPageNumber)から計算しなおす必要がある
                    let dayInterval = Int((Calendar.current.dateComponents([.day], from: task.scheduleStartAt!, to: currentDay)).day!)
                    
                    // 前日までに終わっている予定のページ数
                    let beforeEndedPageNumber = dayInterval * task.page1DayCount
                    // その日にやる予定の開始ページ
                    let scheduleStartPageNumber = beforeEndedPageNumber + 1
                    
                    // その日にやる予定の終了ページ
                    let scheduleEndPageNumber = beforeEndedPageNumber + task.page1DayCount
                    if (scheduleStartPageNumber <= 0 || scheduleEndPageNumber > task.pageAllCount) {
                        continue
                    }
                    
                    let instanceTaskScheduleModel: TaskScheduleModel = TaskScheduleModel()
                    instanceTaskScheduleModel.taskId = task.taskId
                    instanceTaskScheduleModel.scheduleStartPageNumber = scheduleStartPageNumber
                    instanceTaskScheduleModel.scheduleEndPageNumber = scheduleEndPageNumber
                    instanceTaskScheduleModel.executionDate = currentDay
                    
                    try! RealmInstance.write {
                        task.taskSchedules.append(instanceTaskScheduleModel)
                        // これだとリレーションが保存されない RealmInstance.add(instanceTaskScheduleModel)
                    }
                }
            }
        }
        // スケジュールを取得し直す
        currentTaskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate >= %@ AND executionDate <= %@", startOfDay, endOfDay)
        
    }
    // カレンダー日時取得
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        currentDate = date
        // Notificationで通知を送る
        NotificationCenter.default.post(name: .submitTodo, object: nil)
    }
    
}

