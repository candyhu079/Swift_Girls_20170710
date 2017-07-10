//
//  ViewController.swift
//  ChatWithFirebase
//
//  Created by Candy on 2017/6/17.
//  Copyright © 2017年 CandyHu. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UITextFieldDelegate {
    // 下面兩個IBOutlet 是我們自己拉的UI 元件
    @IBOutlet var dialogTextView: UITextView!
    @IBOutlet var saidTextField: UITextField!
    
    // adjustTextFieldByKeyboard() 中調整textField 位置時需要constraint
    @IBOutlet var saidTextFieldBottomConstraint: NSLayoutConstraint!
    
    // ref及storageRef 是使用Firebase Database, Storage需建立的參考（告訴app database在哪）
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
       
        // 設定textField 的delegate
        saidTextField.delegate = self
        
        // 建立ref
        ref = FIRDatabase.database().reference()
        
        _ = ref.observe(.childAdded, with: { (snapshot: FIRDataSnapshot) in
            if snapshot.value != nil {
                let dict = snapshot.value! as! NSDictionary
                let name = dict["name"] as! String
                let said = dict["said"] as! String
                
                self.dialogTextView.text = self.dialogTextView.text + "\(name): \(said)\n"
            }
        })
        
        // 監聽鍵盤出現及消失的事件，執行adjustTextFieldByKeyboard()（調整TextField 位置）
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.adjustTextFieldByKeyboard(notification:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.adjustTextFieldByKeyboard(notification:)), name: .UIKeyboardWillHide, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: Button Clicked
    // 按下Send 按鈕後觸發的方法，將textField 中的文字上傳至database
    @IBAction func sendButtonClicked(_ sender: UIButton) {
        // 建立一個儲存這筆資料的id
        let key = self.ref.childByAutoId().key
        // 將所需的資料（id, name, said）存成dictionary
        let value = ["id" : "candy", "name" : "Candy", "said" : saidTextField.text!]
        
        let childUpdate = ["\(key)": value]
        
        // 上傳資料至database
        ref.updateChildValues(childUpdate)
        
        // 刪除textField 中的文字
        saidTextField.text = nil
        // 收鍵盤
        saidTextField.resignFirstResponder()
    }
    
    //MARK: TextField Delegate
    // 鍵盤按下Return 後觸發的方法
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // 收鍵盤
        textField.resignFirstResponder()
        
        return true
    }

    //MARK: NotificationCenter Methods
    func adjustTextFieldByKeyboard(notification: Notification) {
        // 判斷鍵盤出現或收合
        if notification.name == .UIKeyboardWillShow {
            // 取得鍵盤高度
            let userInfo = notification.userInfo
            let keyboardHeight = (userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
            // 調整textField 的位置至鍵盤上方
            saidTextFieldBottomConstraint.constant += keyboardHeight
        } else if notification.name == .UIKeyboardWillHide {
            // 調整textField 的位置至預設位置
            saidTextFieldBottomConstraint.constant = 10
        }
    }
    
}

