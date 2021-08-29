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

    var datePicker: UIDatePicker = UIDatePicker()
    
    var TaskListResluts: Results<TaskModel>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        scheduleEndAtTextField.inputView = datePicker
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        scheduleEndAtTextField.inputView = datePicker
        scheduleEndAtTextField.inputAccessoryView = toolbar
        

    }
    
    @objc func done() {
        scheduleEndAtTextField.endEditing(true)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        scheduleEndAtTextField.text = "\(formatter.string(from: datePicker.date))"
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
