//
//  UserPageViewController.swift
//  InstaSample
//
//  Created by Masuhara on 2017/08/23.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher

class UserPageViewController: UIViewController, UICollectionViewDataSource {
    
    var posts = [Post]()
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIntroductionTextView: UITextView!
    
    @IBOutlet var photoCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        photoCollectionView.dataSource = self
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        loadPhoto()
        
        if let user = NCMBUser.current() {
            userDisplayNameLabel.text = user.object(forKey: "displayName") as? String
            userIntroductionTextView.text = user.object(forKey: "introduction") as? String
            self.navigationItem.title = user.userName
            
            let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            file.getDataInBackground { (data, error) in
                if error != nil {
                    let alert = UIAlertController(title: "画像取得エラー", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    if data != nil {
                        let image = UIImage(data: data!)
                        self.userImageView.image = image
                    }
                }
            }
        } else {
            // NCMBUser.current()がnilだったとき
            let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            // ログイン状態の保持
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath)
        let photoImageView = cell.viewWithTag(1) as! UIImageView
        let photoImagePath = posts[indexPath.row].imageUrl
        photoImageView.kf.setImage(with: URL(string: photoImagePath))
        return cell
    }
    
    
    @IBAction func showMenu() {
        let alertController = UIAlertController(title: "メニュー", message: "メニューを選択して下さい。", preferredStyle: .actionSheet)
        
        let signOutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground({ (error) in
                if error != nil {
                    print(error)
                } else {
                    // ログアウト成功
                    let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    // ログイン状態の保持
                    let ud = UserDefaults.standard
                    ud.set(false, forKey: "isLogin")
                    ud.synchronize()
                }
            })
        }
        
        let deleteAction = UIAlertAction(title: "退会", style: .default) { (action) in
            
            let alert = UIAlertController(title: "会員登録の解除", message: "本当に退会しますか？退会した場合、再度このアカウントをご利用頂くことができません。", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                let user = NCMBUser.current()
                // ユーザーの削除
                user?.deleteInBackground({ (error) in
                    if error != nil {
                        print(error)
                    } else {
                        // ログアウト成功
                        let storyboard = UIStoryboard(name: "SignIn", bundle: Bundle.main)
                        let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                        
                        // ログイン状態の保持
                        let ud = UserDefaults.standard
                        ud.set(false, forKey: "isLogin")
                        ud.synchronize()
                    }
                })
            })
            
            let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
                alert.dismiss(animated: true, completion: nil)
            })
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        alertController.addAction(signOutAction)
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func loadPhoto() {
        let query = NCMBQuery(className: "Post")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: NCMBUser.current())
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                print(error)
            } else {
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    
                    // 退会済みユーザーの投稿を避けるため、userが存在しているかnilチェック
                    if user.objectId != nil {
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        
                        // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as! String
                        let text = postObject.object(forKey: "text") as! String
                        
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = Post(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
                        
                        // likeの状況(自分が過去にLikeしているか？)によってデータを挿入
                        let likeUser = postObject.object(forKey: "likeUser") as? [String]
                        if likeUser?.contains(NCMBUser.current().objectId) == true {
                            post.isLiked = true
                        } else {
                            post.isLiked = false
                        }
                        // 配列に加える
                        self.posts.append(post)
                    }
                }
                self.photoCollectionView.reloadData()
            }
        })
    }
    
}


