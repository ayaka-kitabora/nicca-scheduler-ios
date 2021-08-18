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

class ViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance {

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
    
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.dataSource = dataSource
            tableView.delegate = dataSource
            dataSource.currentTaskScheduleList = currentTaskScheduleList
            taskTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "Cell")
        }
    }
    
    private let dataSource = TaskScheduleTableDataSource()
    
    @objc private func updateTable(_ notification: Notification) {
        createSchedule(date: currentDate)
        taskTableView.reloadData()
    }
    
    @objc private func createSchedule(date: Date) {
        let currentDay = date
        selectedDate.text = DateUtils.stringFromDate(date: currentDay, format: "YYYY-MM-dd")
        currentTaskScheduleList = nil
        
        let RealmInstance = try! Realm()
        TaskListResluts = RealmInstance.objects(TaskModel.self) // TODO: 期間中のタスクに絞る
        if (TaskListResluts.count > 0) {
            for task in TaskListResluts {
                let taskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate == %@", currentDay).filter("taskId == %@", task.taskId)
                // 一旦その日のスケジュールがない場合に作成
                // 終わったページを更新したタイミングで作成しなおす必要がある
                if (taskScheduleList.count == 0) {
                    // その日の分のタスクスケジュールを作成する
                    // TODO: 一旦 page1DayCountから割って算出するけど、実際の前日終了ページ数(endedPageNumber)から計算しなおす必要がある
                    // 何日間で行うか
                    let dayInterval = Int((Calendar.current.dateComponents([.day], from: task.scheduleStartAt!, to: currentDay)).day!)
                    print("dayInterval")
                    print(dayInterval)
                    
                    if (dayInterval < 0) {
                        continue
                    }
                    // 前日までに終わっている予定のページ数
                    let beforeEndedPageNumber = dayInterval * task.page1DayCount
                    
                    print("beforeEndedPageNumber")
                    print(beforeEndedPageNumber)
                    // その日にやる予定の開始ページ
                    let scheduleStartPageNumber = beforeEndedPageNumber + 1
                    
                    print("scheduleStartPageNumber")
                    print(scheduleStartPageNumber)
                    // その日にやる予定の終了ページ
                    let scheduleEndPageNumber = beforeEndedPageNumber + task.page1DayCount
                    
                    
                    print("scheduleEndPageNumber")
                    print(scheduleEndPageNumber)
                    
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
        currentTaskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate == %@", currentDay)
        
    }
    // カレンダー日時取得
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        currentDate = date
        // Notificationで通知を送る
        NotificationCenter.default.post(name: .submitTodo, object: nil)
    }
    
}

