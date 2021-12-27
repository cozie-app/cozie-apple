//
//  WekeklySurvey.swift
//  Cozie
//
//  Created by MAC on 21/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class WeeklySurvey: BasePopupVC {
    
    @IBOutlet weak var tableQuestions: UITableView!
    @IBOutlet weak var buttonSubmit: UIButton!
    var headerTitles = ["Are you...?", "Do you prefer to be...?"]
    var section1:[String] = ["XXXX XXX XXXXX", "XXXX XXX XXXXX", "XXXX XXX XXXXX", "XXXX XXX XXXXX"]
    var section2:[String] = ["XXXX XXX XXXXX", "XXXX XXX XXXXX"]
    var button1:[UIButton] = []
    var button2:[UIButton] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        buttonSubmit.layer.cornerRadius = 5
        tableQuestions.dataSource = self
        tableQuestions.delegate = self
        let nib = UINib(nibName: "QuestionCell", bundle: nil)
        tableQuestions.register(nib, forCellReuseIdentifier: "cell")
        self.tableQuestions.setupPadding()
    }
    
    @IBAction func onClickSubmit(_ sender: UIButton) {
        NavigationManager.dismiss(self)
    }
    
}

extension WeeklySurvey: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .systemBackground

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        
        switch section {
        case 0:
            label.text = "Are you...?"
        case 1:
            label.text = "Do you prefer to be...?"
        default:
            label.text = ""
        }
        
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        return view
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 4
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableQuestions.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuestionCell
        switch indexPath.section {
        case 0:
            cell.labelQuestion.text = section1[indexPath.row]
            cell.button.addTarget(self, action: #selector(section1ButtonClicked(_:)), for: .touchUpInside)
            button1.append(cell.button)
        case 1:
            cell.labelQuestion.text = section2[indexPath.row]
            cell.button.addTarget(self, action: #selector(section2ButtonClicked(_:)), for: .touchUpInside)
            button2.append(cell.button)
        default:
            break
        }
        cell.button.tag = indexPath.row
        return cell
    }
    
    @objc private func section1ButtonClicked(_ sender: UIButton){
        
        button1.forEach({$0.backgroundColor = .systemBackground})
        button1[sender.tag].isSelected = true
        sender.backgroundColor = .lightGray
    }
    
    @objc private func section2ButtonClicked(_ sender: UIButton){
        
        button2.forEach({$0.backgroundColor = .systemBackground})
        button2[sender.tag].isSelected = true
        sender.backgroundColor = .lightGray
    }
}
