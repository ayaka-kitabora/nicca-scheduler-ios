//
//  TaskModel.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/05/30.
//

import Foundation
import RealmSwift


// サンプルで配列操作を試す
class TaskModel: Object {
    @objc dynamic var taskId: String = NSUUID().uuidString // タスクID
    @objc dynamic var taskName: String? = nil // タスク名
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    @objc dynamic var scheduleStartAt: Date? = nil // 開始予定日
    @objc dynamic var scheduleEndAt: Date? = nil // 終了予定日
    @objc dynamic var endedAt: Date? = nil // タスクが終了した日
    @objc dynamic var pageAllCount: Int = 0 // 全体のページ数
    @objc dynamic var page1DayCount: Int = 0 //
    
    let taskSchedules = List<TaskScheduleModel>() // 1:多の関係
    
    override static func primaryKey() -> String? {
        return "taskId"
    }
}

// タスクごと日毎スケジュール
class TaskScheduleModel: Object {
    @objc dynamic var taskScheduleId: String = NSUUID().uuidString // タスクスケジュールID primarykey
    @objc dynamic var taskId: String? = nil // タスクID relationkey
    @objc dynamic var scheduleStartPageNumber: Int = 0 // 今日スタート予定のページ数
    @objc dynamic var scheduleEndPageNumber: Int = 0 // 今日終了予定のページ数
    @objc dynamic var endedPageNumber: Int = 0 // 今日実際に終了したページ数(やってない場合はstartPage - 1)
    @objc dynamic var createdAt = Date()
    @objc dynamic var updatedAt = Date()
    @objc dynamic var executionDate: String? = nil // 実行する日時 YYYY-MM-DD
    
    let task = LinkingObjects(fromType: TaskModel.self, property: "taskSchedules")
    
    override static func primaryKey() -> String? {
        return "taskScheduleId"
    }
}
