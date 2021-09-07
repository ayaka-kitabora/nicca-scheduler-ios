//
//  TaskCell.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/05/23.
//

import UIKit
import RealmSwift

class TaskCell: UITableViewCell {

    @IBOutlet weak var checkbox: CheckBox!
    @IBOutlet weak var taskLabel: UILabel!
    var taskScheduleId: String = ""
    var endedFlag: Bool = false
    var scheduleEndPageNumber: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func dataInit(_ isChecked: Bool){
        checkbox.setChecked(isChecked)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @IBAction func tapCheckButton(_ sender: CheckBox) {
        let isChecked = !checkbox.isChecked
        checkbox.setChecked(isChecked)
        doneTaskSchedule(isChecked: sender.isChecked)
    }
    
    func doneTaskSchedule(isChecked: Bool) {
        let RealmInstance = try! Realm()
        let taskScheduleResult = RealmInstance.objects(TaskScheduleModel.self).filter("taskScheduleId == %@", taskScheduleId)
        let taskSchedule = taskScheduleResult[0]

        try! RealmInstance.write{
            if (isChecked == true) {
                // 終了予定のページを実際に終了したページとする
                // TODO: 実際に終了したページをユーザーが入力できるようにしたい
                taskSchedule.endedFlag = true
            } else {
                // チェックが外されたら初期値に戻す
                taskSchedule.endedFlag = false
            }
        }
        // Notificationで通知を送る
        NotificationCenter.default.post(name: .doneTask, object: nil)
    }
}
