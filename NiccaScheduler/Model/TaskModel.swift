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
    @objc dynamic var scheduleStartAt = Date() // 開始予定日
    @objc dynamic var scheduleEndAt = Date() // 終了予定日
    @objc dynamic var endedAt: Date? = nil // タスクが終了した日
    @objc dynamic var pageAllCount: Int = 0 // 全体のページ数
    //@objc dynamic var page1DayCount: Int = 0 // 現在の１日に予定されているページ数
    @objc dynamic var pageEndedCount: Int = 0 // 現時点で終了しているページ数
    
    let taskSchedules = List<TaskScheduleModel>() // 1:多の関係
    
    override static func primaryKey() -> String? {
        return "taskId"
    }
    
    override required init() {
        super.init()
    }
}

extension TaskModel {
    
    static func createTask(with taskName: String, pageAllCount: Int, scheduleEndAt: Date, scheduleStartAt: Date) -> Self {
        let model = self.init()
        
        model.taskName = taskName
        model.pageAllCount = pageAllCount
        model.scheduleEndAt = scheduleEndAt
        model.scheduleStartAt = scheduleStartAt
        // データベース取得。エラーの場合はクラッシュ
        let RealmInstance = try! Realm()
        
        try! RealmInstance.write {
            RealmInstance.add(model)
        }
        
        return model
    }

    static func page1DayCount(with id: String) -> Int! {
        let RealmInstance = try! Realm()
        if let model = RealmInstance.object(ofType: TaskModel.self, forPrimaryKey: id) {
            // タスク予定は何日間か計算
            let dayInterval = Int((Calendar.current.dateComponents([.day], from: model.scheduleStartAt, to: model.scheduleEndAt)).day!) + 1
            print("dayInterval", dayInterval)
            
            // 1日にやるpage数 割り切れなければ+1ページ
            let page1DayCount = model.pageAllCount % dayInterval > 0 ? (model.pageAllCount / dayInterval) + 1 : model.pageAllCount / dayInterval
            return page1DayCount
        } else {
            return 0
        }
    }
    
    // 何日間タスクを行うか
    static func dayInterval(with id: String) -> Int! {
        let model = self.getTask(with: id)
        return Int((Calendar.current.dateComponents([.day], from: model.scheduleStartAt, to: model.scheduleEndAt)).day!) + 1
    }
    
    static func getTask(with id: String) -> Self {
        let RealmInstance = try! Realm()
        let model = RealmInstance.object(ofType: TaskModel.self, forPrimaryKey: id)
        return model as! Self
    }
}
