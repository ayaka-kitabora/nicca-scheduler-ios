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
    var endedPageNumber: Int = 0
    var scheduleEndPageNumber: Int = 0
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func dataInit(_ isChecked: Bool){
        checkbox.setChecked(isChecked)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        print("setSelected")
        print(selected)
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func tapCheckButton(_ sender: CheckBox) {
        print(sender)
        print(taskScheduleId)
        print(sender.isChecked)
        doneTaskSchedule(isChecked: sender.isChecked)
    }
    
    func doneTaskSchedule(isChecked: Bool) {
        let RealmInstance = try! Realm()
        let taskScheduleResult = RealmInstance.objects(TaskScheduleModel.self).filter("taskScheduleId == %@", taskScheduleId)
        let taskSchedule = taskScheduleResult[0]

        try! RealmInstance.write{
            if (isChecked) {
                // 終了予定のページを実際に終了したページとする
                // TODO: 実際に終了したページをユーザーが入力できるようにしたい
                let scheduleEndPageNumber = taskSchedule.scheduleEndPageNumber
                taskSchedule.endedPageNumber = scheduleEndPageNumber
            } else {
                // チェックが外されたら初期値に戻す
                taskSchedule.endedPageNumber = 0
            }
        }
    }
}
