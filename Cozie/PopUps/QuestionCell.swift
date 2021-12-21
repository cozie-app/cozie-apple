//
//  QuestionCell.swift
//  Cozie
//
//  Created by MAC on 21/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {

    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var labelQuestion: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buttonView.layer.borderWidth = 1
        buttonView.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = button.frame.height / 2
        buttonView.layer.cornerRadius = buttonView.frame.height / 2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }    
    
}
