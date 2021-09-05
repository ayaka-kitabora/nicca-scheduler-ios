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
    @objc dynamic var endedPageNumber: Int = 0 // 今日実際に終了したページ数(やってない場合はstartPage - 1)
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
        return RealmInstance.objects(TaskScheduleModel.self).filter("endedPageNumber > 0")
    }
    
    static func createTaskSchedule(with date: Date) -> Results<TaskScheduleModel>! {
        let model = self.init()
        
        let calendar = Calendar.current
        let startTime = calendar.startOfDay(for: date)

        let currentDay = startTime
        let currentTaskScheduleList: Results<TaskScheduleModel>!
        let selectedDate = DateUtils.stringFromDate(date: currentDay, format: "YYYY-MM-dd")
        let TaskListResluts: Results<TaskModel>!
        
        let RealmInstance = try! Realm()
        TaskListResluts = RealmInstance.objects(TaskModel.self) // TODO: 期間中のタスクに絞る
        if (TaskListResluts.count > 0) {
            for task in TaskListResluts {
                let taskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate == %@", currentDay as Any).filter("taskId == %@", task.taskId)
                // 一旦その日のスケジュールがない場合に作成
                // 終わったページを更新したタイミングで作成しなおす必要がある
                if (taskScheduleList.count == 0) {
                    // その日の分のタスクスケジュールを作成する
                    // TODO: 一旦 page1DayCountから割って算出するけど、実際の前日終了ページ数(endedPageNumber)から計算しなおす必要がある
                    // 何日間で行うか
                    let dayInterval = Int((Calendar.current.dateComponents([.day], from: task.scheduleStartAt!, to: currentDay)).day!)
                    print("dayInterval")
                    print(dayInterval)
                    
                    if (dayInterval < 0) {
                        continue
                    }
                    // 前日までに終わっている予定のページ数
                    let beforeEndedPageNumber = dayInterval * task.page1DayCount
                    
                    print("beforeEndedPageNumber")
                    print(beforeEndedPageNumber)
                    // その日にやる予定の開始ページ
                    let scheduleStartPageNumber = beforeEndedPageNumber + 1
                    
                    print("scheduleStartPageNumber")
                    print(scheduleStartPageNumber)
                    // その日にやる予定の終了ページ
                    let scheduleEndPageNumber = beforeEndedPageNumber + task.page1DayCount
                    
                    
                    print("scheduleEndPageNumber")
                    print(scheduleEndPageNumber)
                    
                    if (scheduleStartPageNumber <= 0 || scheduleEndPageNumber > task.pageAllCount) {
                        continue
                    }
                    
                    let instanceTaskScheduleModel: TaskScheduleModel = TaskScheduleModel()
                    instanceTaskScheduleModel.taskId = task.taskId
                    instanceTaskScheduleModel.scheduleStartPageNumber = scheduleStartPageNumber
                    instanceTaskScheduleModel.scheduleEndPageNumber = scheduleEndPageNumber
                    instanceTaskScheduleModel.executionDate = currentDay
                    
                    try! RealmInstance.write {
                        task.taskSchedules.append(instanceTaskScheduleModel)
                            // これだとリレーションが保存されない RealmInstance.add(instanceTaskScheduleModel)
                    }
                }
            }
        }
        // スケジュールを取得し直す
        return  RealmInstance.objects(TaskScheduleModel.self).filter("executionDate == %@", currentDay as Any)
    }
}


