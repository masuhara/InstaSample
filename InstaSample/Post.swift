//
//  Post.swift
//  InstaSample
//
//  Created by Masuhara on 2017/09/25.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit

class Post {
    var objectId: String
    var user: User
    var imageUrl: String
    var text: String
    var createDate: Date
    var isLiked: Bool?
    var comments: [Comment]?
    
    init(objectId: String, user: User, imageUrl: String, text: String, createDate: Date) {
        self.objectId = objectId
        self.user = user
        self.imageUrl = imageUrl
        self.text = text
        self.createDate = createDate
    }
}
