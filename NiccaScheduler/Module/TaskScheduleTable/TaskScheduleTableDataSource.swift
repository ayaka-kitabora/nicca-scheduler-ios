//
//  TaskScheduleTableDataSource.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/08/18.
//


import UIKit
import RealmSwift

final class TaskScheduleTableDataSource: NSObject {
    var currentTaskScheduleList: Results<TaskScheduleModel>!
}

extension TaskScheduleTableDataSource: UITableViewDataSource {
    
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
}

extension TaskScheduleTableDataSource: UITableViewDelegate {
    
}
