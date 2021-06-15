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
