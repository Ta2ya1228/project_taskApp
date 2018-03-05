//
//  InputViewController.swift
//  project_taskapp
//
//  Created by 後達哉 on 2018/02/22.
//  Copyright © 2018年 Ta2ya1228. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class InputViewController: UIViewController {
    
//データベースの設定
    var task: Task!                 //継承    (RealmのObject)
    let realm = try! Realm()        //インスタンス
    

    
    
    

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var contentsTextView: UITextView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var category: UITextField!
    
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    //背景(view)をタップしたらdismissKeyboardメソッドを呼ぶように設定する
        
        //tapGesture設定されてるとこタップされたらdismiss作動
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target:self, action:#selector(dismissKeyboard))
        
        //viewにGestureRecognizer(tapGesture)を設定する
        self.view.addGestureRecognizer(tapGesture)
        
        
    //InputVCのタイトル・日付とかにはデータベースに入れたタイトル・日付とかを代入する
        titleTextField.text = task.title
        contentsTextView.text = task.contents
        datePicker.date = task.date
        category.text = task.category
    }
    
    //キーボードを閉じるメソッド(tapGestureで設定されてる)
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //メモ選択画面に遷移する時の処理(データベースのデータを初期設定する)
    override func viewWillDisappear(_ animated: Bool) {
        try! realm.write {
            self.task.title = self.titleTextField.text!
            self.task.contents = self.contentsTextView.text
            self.task.category = self.category.text!
            self.task.date = self.datePicker.date
            self.realm.add(self.task, update: true)
        
        }
        
        setNotification(task: task)
        
        super.viewWillDisappear(animated)
    }
    
    
    //タスクのローカル通知を登録する
    func setNotification(task: Task){
        let content = UNMutableNotificationContent()
        //タイトルと内容を設定
        if task.title == "" {
            content.title = "(タイトルなし)"
        }else{
            content.title = task.title
        }
        
        if task.contents == ""{
            content.body = "(内容なし)"
        }else{
            content.body = task.contents
        }
        content.sound = UNNotificationSound.default()
        
        // ローカル通知が発動するtrigger（日付マッチ）を作成
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: task.date)
        let trigger = UNCalendarNotificationTrigger.init(dateMatching: dateComponents, repeats: false)
        
        //identifier,content,triggerからローカル通知を作成(identifierが同じだとローカル通知を上書き保存)
        let request = UNNotificationRequest.init(identifier: String(task.id), content: content, trigger: trigger)
        
        //ローカル通知を登録 ( error が nil ならローカル通知の登録に成功したと表示します。errorが存在すればerrorを表示する)
        let center = UNUserNotificationCenter.current()
        center.add(request) {(error) in
            print(error ?? "ローカル通知登録 OK")
        }

        //未通知のローカル通知一覧をログ出力
        center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
            for request in requests {
                print("/---------------")
                print(request)
                print("---------------/")
            }
        }
    
    
    
    }
    
    

}
