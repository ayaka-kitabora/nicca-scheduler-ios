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
    @objc dynamic var page1DayCount: Int = 0 // 現在の１日に予定されているページ数
    @objc dynamic var pageEndedCount: Int = 0 // 現時点で終了しているページ数
    
    let taskSchedules = List<TaskScheduleModel>() // 1:多の関係
    
    override static func primaryKey() -> String? {
        return "taskId"
    }
}
// １日に何ページずつ進める予定か1つModelが必要
// 途中で変更されることがあるので履歴を残しておく
// まだ使う予定はないけど一応
class TaskSchedulePageCountModel: Object {
    @objc dynamic var taskId: String? = nil // タスクID relationkey
    @objc dynamic var createdAt = Date()
    @objc dynamic var page1DayCount: Int = 0 // 現在の１日に予定されているページ数
}
