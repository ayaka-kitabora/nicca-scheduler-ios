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
        
        let currentTaskSchedule = CurrentTaskSchedule(date: currentDate)
        currentTaskScheduleList = currentTaskSchedule.createTaskSchedule()
        
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
        let currentTaskSchedule = CurrentTaskSchedule(date: currentDate)
        currentTaskScheduleList = currentTaskSchedule.createTaskSchedule()
        taskTableView.reloadData()
    }
    
  
    // カレンダー日時取得
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        currentDate = date
        selectedDate.text = DateUtils.stringFromDate(date: currentDate, format: "YYYY-MM-dd")
        // Notificationで通知を送る
        NotificationCenter.default.post(name: .submitTodo, object: nil)
    }
    
}

