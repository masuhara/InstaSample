//
//  SignUpViewController.swift
//  InstaSample
//
//  Created by Masuhara on 2017/08/23.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import NCMB

class SignUpViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var userIdTextField: UITextField!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        userIdTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signUp() {
        let user = NCMBUser()
        
        if (userIdTextField.text?.characters.count)! < 4 {
            print("文字数が足りません")
            return
        }
        
        user.userName = userIdTextField.text!
        user.mailAddress = emailTextField.text!
        
        if passwordTextField.text == confirmTextField.text {
            user.password = passwordTextField.text!
        } else {
            print("パスワードの不一致")
        }
        
        let acl = NCMBACL()
        acl.setPublicReadAccess(true)
        user.acl = acl
        
        user.signUpInBackground { (error) in
            if error != nil {
                // エラーがあった場合
                print(error)
            } else {
                // 登録成功
                let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                UIApplication.shared.keyWindow?.rootViewController = rootViewController
                
                // ログイン状態の保持
                let ud = UserDefaults.standard
                ud.set(true, forKey: "isLogin")
                ud.synchronize()
            }
        }
        
    }

    func finishTutorial() {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        let rootViewController = storyboard.instantiateViewController(withIdentifier: "Mainの1つめの画面につけたIdentifier")
        UIApplication.shared.keyWindow?.rootViewController = rootViewController
        
        let ud = UserDefaults.standard
        ud.set(true, forKey: "isFirstLaunch")
        ud.synchronize()
    }
    
    
}











