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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentDate = Date()
        
        let doneTaskScheduleList = DoneTaskScheduleModel.getTaskSchedule(with: currentDate)
        dataSource.doneTaskScheduleList = doneTaskScheduleList
        doneScheduleTable.reloadData()
    }
}
