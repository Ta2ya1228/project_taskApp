//
//  ViewController.swift
//  project_taskapp
//
//  Created by 後達哉 on 2018/02/22.
//  Copyright © 2018年 Ta2ya1228. All rights reserved.
//

import UIKit
import RealmSwift
import UserNotifications

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchControllerDelegate, UISearchResultsUpdating{

    @IBOutlet weak var tableView: UITableView!
    
    var mySearchBar = UISearchController(searchResultsController: nil)
    
    let realm = try! Realm()
  
    // データベース内のタスクが格納されるリスト。日付近い順でソート
    // 以降内容をアップデートするとリスト内は自動的に更新される。
    var taskArray = try! Realm().objects(Task.self).sorted(byKeyPath: "date", ascending: false)

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    
        
        mySearchBar.delegate = self
        mySearchBar.searchResultsUpdater = self
        
        self.tableView.tableHeaderView = mySearchBar.searchBar

    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

//DataSourceプロトコルのメソッド(必須)
    
    //テーブルが何行か(何セルある)かを返すメソッド
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return taskArray.count //taskArrayの要素数を返す
    }
    
    //各セルの内容を返すメソッド
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        //(再利用可能なcellを得るメソッド)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        //cellに値を設定する(taskArrayはセル群でindexPath.rowはセル番号)
        let task = taskArray[indexPath.row]
        cell.textLabel?.text = task.title
        
    
        
        //dateFormatはdateクラスを文字列に変換する
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm" //dateFormatはdateクラスを文字列に変換する  //"年-月-日 時間：分"
        
        let dateString:String = formatter.string(from: task.date)
        cell.detailTextLabel?.text = "\(dateString)       category:\(task.category)"
        
        return cell
    }

    
//Delegateプロトコルのメソッド(必須)
    
    //セルを選択(タップ)した時に実行されるメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath){
        performSegue(withIdentifier: "cellSegue", sender: nil)
    }
    
    //セルが削除可能なことを伝えるメソッド
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle{
        return .delete
    }
    //Deleteボタン押した時のメソッド
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath){
        if editingStyle == .delete {
            
            //削除されたタスクを取得する
            let task = self.taskArray[indexPath.row]
            
            //ローカル通知をキャンセルする
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [String(task.id)])
            
            //データベースから削除する
            try! realm.write{
            self.realm.delete(self.taskArray[indexPath.row])
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
            // 未通知のローカル通知一覧をログ出力
            center.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
                for request in requests {
                    print("/---------------")
                    print(request)
                    print("---------------/")
                }
            }
        }
    }
        
        
        
//segueで画面遷移する時に呼ばれる(cellをタップ)
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        
        //segueから遷移先のInputViewControllerを取得する(以降Inputの数値いじれる)
        let inputViewController: InputViewController = segue.destination as! InputViewController
        
        //もしセルをタップで起きる遷移だったら
        if segue.identifier == "cellSegue"{
            let indexPath = self.tableView.indexPathForSelectedRow
            inputViewController.task = taskArray[indexPath!.row]
        }else{
            let task = Task()
            task.date = Date()
  
            let taskArray = realm.objects(Task.self)
            if taskArray.count != 0{
                task.id = taskArray.max(ofProperty: "id")! + 1
            }
            inputViewController.task = task
        }
        
    }
    
    //入力画面から戻ってきた時にTableViewを更新させる
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    
    
//category == searchController.searchBar.textで設定されているものがずらっと出てくる
    func updateSearchResults(for searchController: UISearchController) {
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            taskArray = try! Realm().objects(Task.self).filter("category == %@", searchText)
            
        }
        tableView.reloadData()
        if let searchText = searchController.searchBar.text, searchText.isEmpty {
            taskArray = try! Realm().objects(Task.self)
    }
    
    
    

}
}
