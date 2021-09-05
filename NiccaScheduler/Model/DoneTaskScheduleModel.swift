//
//  DoneSchedule.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/09/01.
//

import Foundation
import RealmSwift

class DoneTaskScheduleModel: Object {
    dynamic var doneTaskScheduleList: Results<TaskScheduleModel>!
    @objc dynamic var currentDay: Date!
    override required init() {
        super.init()
        
    }
}

extension DoneTaskScheduleModel {

    static func getTaskSchedule(with date: Date) -> Results<TaskScheduleModel>! {
        let model = self.init()

        model.doneTaskScheduleList = nil
        
        let RealmInstance = try! Realm()
        model.doneTaskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("endedPageNumber > 0")
        return model.doneTaskScheduleList
    }
}
