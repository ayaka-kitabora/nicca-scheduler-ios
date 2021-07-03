//
//  TaskInputViewController.swift
//  NiccaScheduler
//
//  Created by 北洞亜也加 on 2021/06/02.
//

import UIKit
import RealmSwift

class TaskInputViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var taskNameTextField: UITextField!
    @IBOutlet weak var pageAllCountTextField: UITextField!
    @IBOutlet weak var scheduleEndAtTextField: UITextField!
    
    var TaskListResluts: Results<TaskModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        

    }
    
    @IBAction func send(_ sender: Any) {
        let instanceTaskModel: TaskModel = TaskModel()
        instanceTaskModel.taskName = self.taskNameTextField.text
        instanceTaskModel.pageAllCount =  Int(self.pageAllCountTextField.text!)!
        let scheduleEndAt = DateUtils.dateFromString(string: scheduleEndAtTextField.text!, format: "yyyy-MM-dd")
        instanceTaskModel.scheduleEndAt = scheduleEndAt
        // TODO: 開始日は一旦本日縛り。変更できるように
        let scheduleStartAt = Date()
        instanceTaskModel.scheduleStartAt = scheduleStartAt
        
        // タスク予定は何日間か計算
        let dayInterval = Int((Calendar.current.dateComponents([.day], from: scheduleStartAt, to: scheduleEndAt)).day!) + 1
        print("dayInterval", dayInterval)
        
        // 1日にやるpage数 割り切れなければ+1ページ
        instanceTaskModel.page1DayCount = instanceTaskModel.pageAllCount % dayInterval > 0 ? (instanceTaskModel.pageAllCount / dayInterval) + 1 : instanceTaskModel.pageAllCount / dayInterval
        
        print("page1DayCount", instanceTaskModel.page1DayCount)
        
        // データベース取得。エラーの場合はクラッシュ
        let RealmInstance = try! Realm()
        
        try! RealmInstance.write {
            RealmInstance.add(instanceTaskModel)
        }
        
        // Notificationで通知を送る
        NotificationCenter.default.post(name: .submitTodo, object: nil)
        
        // 前のページに戻る
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
