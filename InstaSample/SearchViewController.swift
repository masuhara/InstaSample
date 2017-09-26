//
//  SearchViewController.swift
//  InstaSample
//
//  Created by Masuhara on 2017/09/26.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import NCMB
import SVProgressHUD

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {

    var users = [User]()
    
    var searchBar: UISearchBar!
    
    @IBOutlet var searchUserTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setSearchBar()
        
        searchUserTableView.dataSource = self
        searchUserTableView.delegate = self
        
        // カスタムセルの登録
        let nib = UINib(nibName: "SearchUserTableViewCell", bundle: Bundle.main)
        searchUserTableView.register(nib, forCellReuseIdentifier: "Cell")
        
        // 余計な線を消す
        searchUserTableView.tableFooterView = UIView()
        
        loadUsers()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func setSearchBar() {
        // NavigationBarにSearchBarをセット
        if let navigationBarFrame = self.navigationController?.navigationBar.bounds {
            let searchBar: UISearchBar = UISearchBar(frame: navigationBarFrame)
            searchBar.delegate = self
            searchBar.placeholder = "ユーザーを検索"
            searchBar.autocapitalizationType = UITextAutocapitalizationType.none
            navigationItem.titleView = searchBar
            navigationItem.titleView?.frame = searchBar.frame
            self.searchBar = searchBar
        }
    }
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as! SearchUserTableViewCell
        
        let userImagePath = "https://mb.api.cloud.nifty.com/2013-09-01/applications/vLEKsnidG4wHsPV7/publicFiles/" + users[indexPath.row].objectId
        cell.userImageView.kf.setImage(with: URL(string: userImagePath))
        cell.userImageView.layer.cornerRadius = cell.userImageView.bounds.width / 2.0
        cell.userImageView.layer.masksToBounds = true
        
        cell.userNameLabel.text = users[indexPath.row].displayName
        return cell
    }
    
    func loadUsers() {
        let query = NCMBUser.query()
        // 自分を除外
        query?.whereKey("objectId", notEqualTo: NCMBUser.current().objectId)
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                print(error)
            } else {
                print(result)
                self.users = [User]()
                for userObject in result as! [NCMBUser] {
                    let displayName = userObject.object(forKey: "displayName") as? String
                    let user = User(objectId: userObject.objectId, userName: userObject.userName)
                    user.displayName = displayName
                    self.users.append(user)
                }
                self.searchUserTableView.reloadData()
            }
        })
    }

}
