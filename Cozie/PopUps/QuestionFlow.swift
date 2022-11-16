//
//  QuestionFlow.swift
//  Cozie
//
//  Created by MAC on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class QuestionFlow: BasePopupVC {
    
    @IBOutlet weak var tableFlows: UITableView!
    @IBOutlet weak var questionFlowSetBtn: UIButton!
    
    var selectedQuestionFlow: Int = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.selectedQuestionFlow.rawValue) as? Int ?? 0
    var answer: Int = 0
    var buttons: [UIButton] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        questionFlowSetBtn.layer.cornerRadius = 5
        tableFlows.dataSource = self
        tableFlows.delegate = self
        let nib = UINib(nibName: "QuestionCell", bundle: nil)
        tableFlows.register(nib, forCellReuseIdentifier: "cell")
        self.tableFlows.setupPadding()

    }

    @IBAction func onClickSet(_ sender: Any) {
        UserDefaults.shared.setValue(for: UserDefaults.UserDefaultKeys.selectedQuestionFlow.rawValue, value: self.selectedQuestionFlow)
        NavigationManager.dismiss(self)
    }
    
}

extension QuestionFlow: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return questionFlows.count
        }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableFlows.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuestionCell
        cell.labelQuestion.text = questionFlows[indexPath.row].title
        self.buttons.append(cell.button)
        if (self.selectedQuestionFlow == indexPath.row)
            {cell.button.isSelected = true
                cell.button.backgroundColor = primaryColour}
        else {
            cell.button.isSelected = false
            cell.button.backgroundColor = .systemBackground
        }

        if indexPath.section == 1 && indexPath.row == 6 && self.answer == indexPath.row {
            cell.otherTextField.isHidden = false
        } else {
            cell.otherTextField.isHidden = true
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        self.selectedQuestionFlow = indexPath.row
        self.answer = indexPath.row

        DispatchQueue.main.async {
            self.tableFlows.reloadData()
        }
    }
}
