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

class ViewController: UIViewController,FSCalendarDelegate,FSCalendarDataSource,FSCalendarDelegateAppearance, UITableViewDelegate {

    @IBOutlet weak var taskTableView: UITableView! {
        didSet {
            taskTableView.dataSource = dataSource
            taskTableView.delegate = self
            dataSource.currentTaskScheduleList = currentTaskScheduleList
            taskTableView.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "Cell")
        }
    }
    @IBOutlet weak var calendar: FSCalendar!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var selectedDate: UILabel!
    
    var TaskListResluts: Results<TaskModel>!
    var currentTaskScheduleList: Results<TaskScheduleModel>!
    
    var currentDate = Date()
    let df = DateFormatter()

    private let dataSource = TaskScheduleTableDataSource()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // TODO: デバックコード あとで消す
        print("Realm file-----")
        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
        // ナビゲーションを透過
        self.navigationController!.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController!.navigationBar.shadowImage = UIImage()
        
        // カレンダー
        self.calendar.dataSource = self
        self.calendar.delegate = self
        self.calendar.select(currentDate)
        // Notificationの登録
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable), name: .submitTodo, object: nil)
        
        selectedDate.text = DateUtils.stringFromDate(date: currentDate, format: "YYYY-MM-dd")
        // Notificationで通知を送る
        NotificationCenter.default.post(name: Notification.Name.submitTodo, object: nil)
    }
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
  
    @objc private func updateTable(_ notification: Notification) {
        dataSource.currentTaskScheduleList = TaskScheduleModel.getTaskSchedule(with: currentDate)
        taskTableView.reloadData()
    }
    
  
    // カレンダー日時取得
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition){
        currentDate = date
        selectedDate.text = DateUtils.stringFromDate(date: currentDate, format: "YYYY-MM-dd")
        // Notificationで通知を送る
        NotificationCenter.default.post(name: Notification.Name.submitTodo, object: nil)
    }
    
}

