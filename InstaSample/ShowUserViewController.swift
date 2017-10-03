//
//  ShowUserViewController.swift
//  InstaSample
//
//  Created by Masuhara on 2017/10/02.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import NCMB
import Kingfisher
import SVProgressHUD

class ShowUserViewController: UIViewController, UICollectionViewDataSource {
    
    var selectedUser: NCMBUser!
    
    var posts = [Post]()
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userDisplayNameLabel: UILabel!
    
    @IBOutlet var userIntroductionTextView: UITextView!
    
    @IBOutlet var photoCollectionView: UICollectionView!
    
    @IBOutlet var postCountLabel: UILabel!
    
    @IBOutlet var followerCountLabel: UILabel!
    
    @IBOutlet var followingCountLabel: UILabel!
    
    @IBOutlet var followButton: BorderButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        photoCollectionView.dataSource = self
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        // ユーザー基礎情報の読み込み
        userDisplayNameLabel.text = selectedUser.object(forKey: "displayName") as? String
        userIntroductionTextView.text = selectedUser.object(forKey: "introduction") as? String
        self.navigationItem.title = selectedUser.userName
        
        // プロフィール画像の読み込み
        let file = NCMBFile.file(withName: selectedUser.objectId, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                if data != nil {
                    let image = UIImage(data: data!)
                    self.userImageView.image = image
                }
            }
        }
        
        // ユーザーの投稿した写真の読み込み
        loadPosts()
        
        // フォロー中かどうかの読み込み
        loadFollowingStatus()
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
    
    func loadFollowingStatus() {
        let query = NCMBQuery(className: "Follow")
        query?.includeKey("user")
        query?.includeKey("following")
        query?.whereKey("user", equalTo: NCMBUser.current())
        
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                for following in result as! [NCMBObject] {
                    let user = following.object(forKey: "following") as! NCMBUser
                    if self.selectedUser.objectId == user.objectId {
                        self.followButton.setTitle("フォロー解除", for: .normal)
                        self.followButton.setTitleColor(UIColor.red, for: .normal)
                        self.followButton.borderColor = UIColor.red
                        break
                    }
                }
            }
        })
    }

    func loadPosts() {
        let query = NCMBQuery(className: "Post")
        query?.includeKey("user")
        query?.whereKey("user", equalTo: selectedUser)
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                SVProgressHUD.showError(withStatus: error!.localizedDescription)
            } else {
                self.posts = [Post]()
                
                for postObject in result as! [NCMBObject] {
                    // ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
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
                self.photoCollectionView.reloadData()
                
                // post数を表示
                self.postCountLabel.text = String(self.posts.count)
            }
        })
    }
    
    @IBAction func follow() {
        
    }
}
