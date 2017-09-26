//
//  User.swift
//  InstaSample
//
//  Created by Masuhara on 2017/09/25.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit

class User {
    var objectId: String
    var userName: String
    var displayName: String?

    init(objectId: String, userName: String) {
        self.objectId = objectId
        self.userName = userName
    }
}
