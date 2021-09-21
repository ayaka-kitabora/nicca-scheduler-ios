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
    @IBOutlet weak var errorLabel: UILabel!
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
        errorLabel.text = ""
        
        if (taskNameTextField.text == "" || pageAllCountTextField.text == "" || scheduleEndAtTextField.text == "" || scheduleStartAtTextField.text == "") {
            errorLabel.text = "全ての項目を入力してください"
            return
        }
        
        guard let pageAllCount: Int = Int(pageAllCountTextField.text!) else {
            errorLabel.text = "ページを正しく入力してください"
            return
        }
        
        let formatter: DateFormatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = "yyyy-MM-dd"
        
        guard let scheduleStartAt: Date = formatter.date(from: scheduleStartAtTextField.text!) as Date? else {
            errorLabel.text = "開始日を正しく入力してください"
            return
        }
        
        guard let scheduleEndAt: Date = formatter.date(from: scheduleEndAtTextField.text!) as Date? else {
            errorLabel.text = "終了日を正しく入力してください"
            return
        }
        
        let calendar = Calendar(identifier: .gregorian)
        let diff = calendar.dateComponents([.day], from: scheduleStartAt, to: scheduleEndAt)
        let numberOfDays = diff.day!

        guard numberOfDays >= 0 else {
            errorLabel.text = "開始日と終了日を正しく入力してください"
            return
        }

        let taskName = taskNameTextField.text
        // タスクの作成
        let task = TaskModel.createTask(with: taskName!, pageAllCount: pageAllCount, scheduleEndAt: scheduleEndAt, scheduleStartAt: scheduleStartAt)
        
        // スケジュールの作成
        TaskScheduleModel.createTaskSchedules(with: task.taskId)
        
        // Notificationで通知を送る
        NotificationCenter.default.post(name: Notification.Name.submitTodo, object: nil)
        
        // 前のページに戻る
        self.navigationController?.popViewController(animated: true)
        
    }
    
}
