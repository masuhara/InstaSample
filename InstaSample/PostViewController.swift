//
//  PostViewController.swift
//  InstaSample
//
//  Created by Masuhara on 2017/09/23.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit
import NYXImagesKit
import NCMB
import UITextView_Placeholder
import SVProgressHUD

class PostViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    let placeholderImage = UIImage(named: "photo-placeholder")
    
    var resizedImage: UIImage!
    
    @IBOutlet var postImageView: UIImageView!
    
    @IBOutlet var postTextView: UITextView!
    
    @IBOutlet var postButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()

        postImageView.image = placeholderImage
        
        postButton.isEnabled = false
        postTextView.placeholder = "キャプションを書く"
        postTextView.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        resizedImage = selectedImage.scale(byFactor: 0.7)
        
        postImageView.image = resizedImage
        
        picker.dismiss(animated: true, completion: nil)
        
        confirmContent()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        confirmContent()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textView.resignFirstResponder()
    }
    
    @IBAction func selectImage() {
        let alertController = UIAlertController(title: "画像選択", message: "シェアする画像を選択して下さい。", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "カメラで撮影", style: .default) { (action) in
            // カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        
        let photoLibraryAction = UIAlertAction(title: "フォトライブラリから選択", style: .default) { (action) in
            // アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) == true {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(cameraAction)
        alertController.addAction(photoLibraryAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func sharePhoto() {
        SVProgressHUD.show()
        
        // 撮影した画像をデータ化したときに右に90度回転してしまう問題の解消
        UIGraphicsBeginImageContext(resizedImage.size)
        let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
        resizedImage.draw(in: rect)
        resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let data = UIImagePNGRepresentation(resizedImage)
        // ここを変更（ファイル名無いので）
        let file = NCMBFile.file(with: data) as! NCMBFile
        file.saveInBackground({ (error) in
            if error != nil {
                SVProgressHUD.dismiss()
                let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            } else {
                // 画像アップロードが成功
                let postObject = NCMBObject(className: "Post")
                
                if self.postTextView.text.characters.count == 0 {
                    print("入力されていません")
                    return
                }
                postObject?.setObject(self.postTextView.text!, forKey: "text")
                postObject?.setObject(NCMBUser.current(), forKey: "user")
                let url = "https://mb.api.cloud.nifty.com/2013-09-01/applications/vLEKsnidG4wHsPV7/publicFiles/" + file.name
                postObject?.setObject(url, forKey: "imageUrl")
                postObject?.saveInBackground({ (error) in
                    if error != nil {
                        SVProgressHUD.showError(withStatus: error!.localizedDescription)
                    } else {
                        SVProgressHUD.dismiss()
                        self.postImageView.image = nil
                        self.postImageView.image = UIImage(named: "photo-placeholder")
                        self.postTextView.text = nil
                        self.tabBarController?.selectedIndex = 0
                    }
                })
            }
        }) { (progress) in
            print(progress)
        }
    }
    
    func confirmContent() {
        if postTextView.text.characters.count > 0 && postImageView.image != placeholderImage {
            postButton.isEnabled = true
        } else {
            postButton.isEnabled = false
        }
    }
    
    @IBAction func cancel() {
        if postTextView.isFirstResponder == true {
            postTextView.resignFirstResponder()
        }
        
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.postTextView.text = nil
            self.postImageView.image = UIImage(named: "photo-placeholder")
            self.confirmContent()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }

}
