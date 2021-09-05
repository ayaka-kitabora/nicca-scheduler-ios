//
//  DoneSchedule.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/09/01.
//
import Foundation
import RealmSwift

// タスクごと日毎スケジュール
class TaskScheduleModel: Object {
    @objc dynamic var taskScheduleId: String = NSUUID().uuidString // タスクスケジュールID primarykey
    @objc dynamic var taskId: String? = nil // タスクID relationkey
    @objc dynamic var scheduleStartPageNumber: Int = 0 // 今日スタート予定のページ数
    @objc dynamic var scheduleEndPageNumber: Int = 0 // 今日終了予定のページ数
    @objc dynamic var endedPageNumber: Int = 0 // 今日実際に終了したページ数(やってない場合はstartPage - 1) // 一旦使用しない
    @objc dynamic var endedFlag: Bool = false
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    @objc dynamic var executionDate: Date? = nil // 実行する日時 YYYY-MM-DD
    
    let task = LinkingObjects(fromType: TaskModel.self, property: "taskSchedules")
    
    override static func primaryKey() -> String? {
        return "taskScheduleId"
    }
    
    override required init() {
        super.init()
        
    }
}

extension TaskScheduleModel {

    static func getDoneTaskSchedule(with date: Date) -> Results<TaskScheduleModel>! {
        let RealmInstance = try! Realm()
        return RealmInstance.objects(TaskScheduleModel.self).filter("endedflag == true")
    }
    
    // 初期スケジュールを登録
    static func createTaskSchedules(with taskId: String) -> Void {
        let RealmInstance = try! Realm()
        let task = TaskModel.getTask(with: taskId)
        let dayInterval = TaskModel.dayInterval(with: taskId)
        let page1DayCount = TaskModel.page1DayCount(with: task.taskId)
        
        for i in 0 ..< dayInterval! {
            print(i)
            let currentDate = Calendar.current.date(byAdding: .day, value: i, to: task.scheduleStartAt)!
            
            
            let currentDay = i // 0スタートで何日目か
            
            // 前日までに終わっている予定のページ数
            let beforeEndedPageNumber = currentDay * page1DayCount!

            // その日にやる予定の開始ページ
            let scheduleStartPageNumber = beforeEndedPageNumber + 1

            // その日にやる予定の終了ページ
            let scheduleEndPageNumber =
                beforeEndedPageNumber + page1DayCount! > task.pageAllCount ?
                task.pageAllCount :
                beforeEndedPageNumber + page1DayCount!
            
            if (scheduleStartPageNumber <= 0) {
                continue
            }
            
            let model = self.init()
            model.taskId = task.taskId
            model.scheduleStartPageNumber = scheduleStartPageNumber
            model.scheduleEndPageNumber = scheduleEndPageNumber
            model.executionDate = currentDate
            
            try! RealmInstance.write {
                task.taskSchedules.append(model)
                    // これだとリレーションが保存されない RealmInstance.add(instanceTaskScheduleModel)
            }
            
        }
    }
    
    // その日のスケジュールを取得
    static func getTaskSchedule(with date: Date) -> Results<TaskScheduleModel> {
        let RealmInstance = try! Realm()
        let result = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate == %@", date)
        return result
    }
}
