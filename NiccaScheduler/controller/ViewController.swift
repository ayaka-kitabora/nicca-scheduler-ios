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
    // TODO: データ構造を後で見直す
    
    // let taskList = ["Udemy 240〜250", "Udemy 251〜261", "Udemy 262〜272"]
    var TaskListResluts: Results<TaskModel>!
    var currentTaskScheduleList: Results<TaskScheduleModel>!
    
    let date = Date()
    let df = DateFormatter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // カレンダー
        self.calendar.dataSource = self
        self.calendar.delegate = self
        // テーブル
        taskTableView.delegate = self
        taskTableView.dataSource = self
        taskTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "Cell")
        // Notificationの登録
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable), name: .submitTodo, object: nil)
        
        // Realm
        let currentDay = Date() // 一旦今日にするが、カレンダーの選択日に指定する
        
        let RealmInstance = try! Realm()
        TaskListResluts = RealmInstance.objects(TaskModel.self) // TODO: 期間中のタスクに絞る
        if (TaskListResluts.count > 0) {
            
            for task in TaskListResluts {
                print("\(task)")
                currentTaskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate == %@", currentDay).filter("taskId == %@", task.taskId)
                if (currentTaskScheduleList.count == 0) {
                    // その日の分のタスクスケジュールを作成する
                    
                    let instanceTaskScheduleModel: TaskScheduleModel = TaskScheduleModel()
                    instanceTaskScheduleModel.taskId = task.taskId
                    // 今日は何ページからやる予定か計算
                    // TODO: 一旦 page1DayCountから割って算出するけど、実際の前日終了ページ数(endedPageNumber)から計算しなおす必要がある
                    let dayInterval = Int((Calendar.current.dateComponents([.day], from: task.scheduleStartAt!, to: currentDay)).day!)
                    
                    // 前日までに終わっている予定のページ数
                    let beforeEndedPageNumber = dayInterval * task.page1DayCount
                    
                    instanceTaskScheduleModel.scheduleStartPageNumber = beforeEndedPageNumber + 1
                    
                    instanceTaskScheduleModel.scheduleEndPageNumber = beforeEndedPageNumber + task.page1DayCount
                    
                    instanceTaskScheduleModel.executionDate = currentDay
                    
                    try! RealmInstance.write {
                        RealmInstance.add(instanceTaskScheduleModel)
                    }
                    // Notificationで通知を送る
                    NotificationCenter.default.post(name: .submitTodo, object: nil)
                    
                }
            }
        }
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
        let task = TaskListResluts[indexPath.row]
        cell.taskLabel.text = task.taskName
        
        // タップ時のハイライトの色を無効に
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TaskListResluts.count
    }
    
    @objc private func updateTable(_ notification: Notification) {
        taskTableView.reloadData()
    }
    
}

