//
//  DOneScheduleTableDataSource.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/09/01.
//

import UIKit
import RealmSwift

final class DoneScheduleTableDataSource: NSObject {
    var doneTaskScheduleList: Results<TaskScheduleModel>!
}

extension DoneScheduleTableDataSource: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // セルを取得する
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! TaskCell
        
        // タップ時のハイライトの色を無効に
        cell.selectionStyle = UITableViewCell.SelectionStyle.none
        
        if (doneTaskScheduleList.count > 0) {
            let taskSchedule = doneTaskScheduleList[indexPath.row]
            let task = taskSchedule.task.first
            if (task == nil) {
                cell.taskLabel.text = "タスクがありません"
                return cell
            }
            let text = "\(String(describing: task!.taskName!)) \(taskSchedule.scheduleStartPageNumber)〜\( taskSchedule.scheduleEndPageNumber)"
            cell.taskLabel.text = text
            cell.taskScheduleId = taskSchedule.taskScheduleId
            cell.endedFlag = taskSchedule.endedFlag
            cell.scheduleEndPageNumber = taskSchedule.scheduleEndPageNumber
            
            var isChecked = false
            if (taskSchedule.endedFlag && taskSchedule.scheduleEndPageNumber > 0) {
                isChecked = true
            }
            
            cell.dataInit(isChecked)
        }
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (doneTaskScheduleList == nil) { return 0 }
        return doneTaskScheduleList.count
    }
}
