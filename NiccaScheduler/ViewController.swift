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
        // df.dateFormat = "yyyy-MM-dd"
        //let currentDay = df.string(from: date)
        let RealmInstance = try! Realm()
        TaskListResluts = RealmInstance.objects(TaskModel.self)
        /*
        if (taskList.count > 0) {
            todayTaskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate == %@", currentDay)
            print(taskList)
            // taskがあればスケジュールを取得、なければ作成
            for value in todayTaskScheduleList {
                print("\(value)")
            }
        }
        */
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

