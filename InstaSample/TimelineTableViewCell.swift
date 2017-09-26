//
//  TimelineTableViewCell.swift
//  InstaSample
//
//  Created by Masuhara on 2017/09/13.
//  Copyright © 2017年 Ylab, Inc. All rights reserved.
//

import UIKit

protocol TimelineTableViewCellDelegate {
    func didTapLikeButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
}

class TimelineTableViewCell: UITableViewCell {
    
    var delegate: TimelineTableViewCellDelegate?
    
    @IBOutlet var userImageView: UIImageView!
    
    @IBOutlet var userNameLabel: UILabel!
    
    @IBOutlet var photoImageView: UIImageView!
    
    @IBOutlet var likeButton: UIButton!
    
    @IBOutlet var likeCountLabel: UILabel!
    
    @IBOutlet var commentTextView: UITextView!
    
    @IBOutlet var timestampLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func like(button: UIButton) {
        self.delegate?.didTapLikeButton(tableViewCell: self, button: button)
    }
    
    @IBAction func openMenu(button: UIButton) {
        self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
    }
    
    @IBAction func showComments(button: UIButton) {
        self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }
    
}
