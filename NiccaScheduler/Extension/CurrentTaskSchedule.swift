//
//  CurrentTaskSchedule.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/08/18.
//

import Foundation
import RealmSwift

class CurrentTaskSchedule {
    var currentTaskScheduleList: Results<TaskScheduleModel>!
    var selectedDate: String
    var TaskListResluts: Results<TaskModel>!
    var currentDay: Date
    
    init(date: Date) {
        self.currentDay = date
        self.currentTaskScheduleList = nil
        self.selectedDate = DateUtils.stringFromDate(date: currentDay, format: "YYYY-MM-dd")
        self.TaskListResluts = nil
    }
    
    func createTaskSchedule() -> Results<TaskScheduleModel>! {
        let RealmInstance = try! Realm()
        TaskListResluts = RealmInstance.objects(TaskModel.self) // TODO: 期間中のタスクに絞る
        if (TaskListResluts.count > 0) {
            for task in TaskListResluts {
                let taskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate == %@", currentDay).filter("taskId == %@", task.taskId)
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
        currentTaskScheduleList = RealmInstance.objects(TaskScheduleModel.self).filter("executionDate == %@", currentDay)
        return currentTaskScheduleList
    }
    
}
