//
//  Comment.swift
//  InstaSample
//
//  Created by Masuhara on 2017/09/25.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit

class Comment {    
    var postId: String
    var user: User
    var text: String
    var createDate: Date
    
    init(postId: String, user: User, text: String, createDate: Date) {
        self.postId = postId
        self.user = user
        self.text = text
        self.createDate = createDate
    }
}
