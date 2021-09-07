//
//  DoneViewController.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/09/01.
//

import UIKit
import RealmSwift

class DoneViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var doneScheduleTable: UITableView! {
        didSet {
            doneScheduleTable.dataSource = dataSource
            doneScheduleTable.delegate = self
            dataSource.doneTaskScheduleList = doneTaskScheduleList
            doneScheduleTable.register(UINib(nibName: "TaskCell", bundle: nil), forCellReuseIdentifier: "Cell")
        }
    }
    
    var doneTaskScheduleList: Results<TaskScheduleModel>!
    private let dataSource = DoneScheduleTableDataSource()
    let currentDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let doneTaskScheduleList = TaskScheduleModel.getDoneTaskSchedule(with: currentDate)
        dataSource.doneTaskScheduleList = doneTaskScheduleList
        
        // Notificationの登録
        NotificationCenter.default.addObserver(self, selector: #selector(self.updateTable), name: .doneTask, object: nil)
        
        NotificationCenter.default.post(name: .doneTask, object: nil)
    }
    
    @objc private func updateTable(_ notification: Notification) {
        dataSource.doneTaskScheduleList = TaskScheduleModel.getDoneTaskSchedule(with: currentDate)
        doneScheduleTable.reloadData()
    }
}
