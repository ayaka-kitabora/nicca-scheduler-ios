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

    @IBOutlet weak var scheduleStartAtTextField: UITextField!
    var datePicker: UIDatePicker = UIDatePicker()
    
    var TaskListResluts: Results<TaskModel>!
    
    var editingDatePickerType: String! // start or end
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.datePickerMode = UIDatePicker.Mode.date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.timeZone = NSTimeZone.local
        datePicker.locale = Locale.current
        
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 35))
        let spacelItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        let doneItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done))
        toolbar.setItems([spacelItem, doneItem], animated: true)
        
        scheduleStartAtTextField.inputView = datePicker
        scheduleStartAtTextField.inputAccessoryView = toolbar
        scheduleEndAtTextField.inputView = datePicker
        scheduleEndAtTextField.inputAccessoryView = toolbar
    }
    
    @IBAction func handleClickScheduleStartAtTextField(_ sender: Any) {
        editingDatePickerType = "start"
    }
    
    @IBAction func handleClickScheduleEndAtTextField(_ sender: Any) {
        editingDatePickerType = "end"
    }
    
    @objc func done() {
        if (editingDatePickerType == "start") {
            scheduleStartAtTextField.endEditing(true)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            scheduleStartAtTextField.text = "\(formatter.string(from: datePicker.date))"
        } else {
            scheduleEndAtTextField.endEditing(true)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            scheduleEndAtTextField.text = "\(formatter.string(from: datePicker.date))"
        }
        editingDatePickerType = nil
    }
    
    @IBAction func send(_ sender: Any) {
        let instanceTaskModel: TaskModel = TaskModel()
        instanceTaskModel.taskName = self.taskNameTextField.text
        instanceTaskModel.pageAllCount =  Int(self.pageAllCountTextField.text!)!
        let scheduleEndAt = DateUtils.dateFromString(string: scheduleEndAtTextField.text!, format: "yyyy-MM-dd")
        instanceTaskModel.scheduleEndAt = scheduleEndAt
        let scheduleEndAt = DateUtils.dateFromString(string: scheduleStartAtTextField.text!, format: "yyyy-MM-dd")
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
