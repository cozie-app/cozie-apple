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
    var questions = ["On which days did you work from home this week?", "Are you experiencing any of the following symptoms? (Select all that apply)", "How much fatigue are you currently experiencing?", "Please indicate your satisfaction levels with the overall indoor air quality in your office.", "How much fatigue have you been experiencing throught the week?"]
    var options: [[String]] = [["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday", "None"], ["None", "Hoarse/dry throat", "Irritation of the eyes", "Dry eyes", "Dry skin", "Flushed facial skin", "Others, please indicate"], ["Not at all", "Slightly", "Moderately", "Very", "Extremely"], ["Extremely dissatisfied", "Moderately dissatisfied", "Slightly dissatisfied", "Neither satisfied or dissatisfied", "Slightly satisfied", "Moderately satisfied", "Extremely satisfied"], ["Not at all", "Slightly", "Moderately", "Very", "Extremely"]]
    var multipleAnswer = [true, true, false, false, false]
    var answers: [Int: [Int]] = [:]
    var buttons: [Int: [UIButton]] = [:]
    var otherAnswer = ""

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
        if self.answers.count != self.questions.count {
            let alert = UIAlertController(title: "Question remaining", message: "Make sure to answer every question in survey", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        } else {
            var tmpResponses: [String: String] = [:]
            for (index, question) in self.questions.enumerated() {
                if self.multipleAnswer[index] == true {
                    var answers1 = ""
                    answers[index]?.forEach { option in
                        answers1 += answers1 == "" ? "" : ", "
                        if index == 1 && option == 6 {
                            answers1 += self.otherAnswer
                        } else {
                            answers1 += "\(options[index][option])"
                        }
                    }
                    tmpResponses[question] = answers1
                } else {
                    tmpResponses[question] = options[index][answers[index]?.first ?? 0]
                }
            }
            do {
                let postMessage = try JSONEncoder().encode(FormatAPI(timestamp_location: GetDateTimeISOString(), timestamp_start: GetDateTimeISOString(), timestamp_end: GetDateTimeISOString(), id_participant: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", responses: tmpResponses, id_device: UIDevice.current.identifierForVendor?.uuidString ?? ""))
                PostRequest(message: postMessage)
            } catch let error {
                print("error WS: \(error.localizedDescription)")
            }
            NavigationManager.dismiss(self)
        }
    }

}

extension WeeklySurvey: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return questions.count
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 20))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return CGFloat(label.calculateMaxLines(forText: self.questions[section])) * 20
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = .systemBackground

        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 200, height: 20))
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.text = self.questions[section]
        view.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        label.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 2).isActive = true

        return view
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.options[section].count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableQuestions.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! QuestionCell
        cell.labelQuestion.text = options[indexPath.section][indexPath.row]
        cell.delegate = self
        self.buttons[indexPath.section]?.append(cell.button)
        cell.button.isSelected = self.answers[indexPath.section]?.contains(indexPath.row) == true
        cell.button.backgroundColor = cell.button.isSelected ? .lightGray : .systemBackground
        if indexPath.section == 1 && indexPath.row == 6 && self.answers[indexPath.section]?.contains(indexPath.row) == true {
            cell.otherTextField.isHidden = false
            cell.otherTextField.text = self.otherAnswer
        } else {
            cell.otherTextField.isHidden = true
        }
        return cell
    }
}

extension WeeklySurvey: selectAnswerDelegate {
    func onClickOption(cell: QuestionCell) {
        if let indexPath = tableQuestions.indexPath(for: cell) {
            if multipleAnswer[indexPath.section] != true {
                buttons[indexPath.section]?.forEach({ $0.backgroundColor = .systemBackground })
            }
            if self.answers[indexPath.section]?.contains(indexPath.row) == true {
                cell.button.isSelected = false
                cell.button.backgroundColor = .systemBackground
                self.answers[indexPath.section]?.removeAll(where: { $0 == indexPath.row })
                if self.answers[indexPath.section]?.count == 0 {
                    self.answers.removeValue(forKey: indexPath.section)
                }
            } else {
                cell.button.isSelected = true
                cell.button.backgroundColor = .lightGray
                if self.multipleAnswer[indexPath.section] == true && self.answers[indexPath.section] != nil {
                    self.answers[indexPath.section]?.append(indexPath.row)
                } else {
                    self.answers[indexPath.section] = [indexPath.row]
                }
            }
            DispatchQueue.main.async {
                self.tableQuestions.reloadData()
            }
        }
    }

    func otherAnswer(text: String) {
        self.otherAnswer = text
    }
}
