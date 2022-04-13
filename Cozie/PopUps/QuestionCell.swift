//
//  QuestionCell.swift
//  Cozie
//
//  Created by MAC on 21/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

protocol selectAnswerDelegate {
    func onClickOption(cell: QuestionCell)
    func otherAnswer(text: String)
}

class QuestionCell: UITableViewCell {

    @IBOutlet weak var buttonView: UIView!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var labelQuestion: UILabel!
    @IBOutlet weak var otherTextField: UITextField!
    
    var delegate: selectAnswerDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        buttonView.layer.borderWidth = 1
        buttonView.layer.borderColor = UIColor.lightGray.cgColor
        button.layer.cornerRadius = button.frame.height / 2
        buttonView.layer.cornerRadius = buttonView.frame.height / 2
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        otherTextField.addTarget(self, action: #selector(self.textFieldValueChanged), for: UIControl.Event.editingChanged)
    }
    
    @objc private func buttonClicked(_ sender: UIButton){
        delegate?.onClickOption(cell: self)
    }
    
    @objc private func textFieldValueChanged() {
        delegate?.otherAnswer(text: self.otherTextField.text ?? "")
    }
    
}
