//
//  SearchUserTableViewCell.swift
//  InstaSample
//
//  Created by Masuhara on 2017/09/26.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit

protocol SearchUserTableViewCellDelegate {
    func didTapFollowButton(tableViewCell: UITableViewCell, button: UIButton)
}

class SearchUserTableViewCell: UITableViewCell {
    
    var delegate: SearchUserTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var followButton: BorderButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func tapFollowButton(button: UIButton) {
        self.delegate?.didTapFollowButton(tableViewCell: self, button: button)
    }
    
}
