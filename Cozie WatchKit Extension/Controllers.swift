//
//  WelcomeInterfaceController.swift
//  Cozie WatchKit Extension
//
//  Created by Square Infosoft on 24/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import WatchKit
import UIKit

class WelcomeInterfaceController: WKInterfaceController {
    let userDefaults = UserDefaults.standard
    
    @IBAction func onClickThermal() {
        self.pushController(withName: "Thermal", context: nil)
    }
    @IBAction func onClickOther() {
        self.pushController(withName: "Other", context: nil)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
}

class OtherIC: WKInterfaceController {
    
    @IBAction func onClickLeftOption() {
        self.pushController(withName: "OptionsIC", context: 0)
    }
    
    @IBAction func onClickRightOption() {
        self.pushController(withName: "OptionsIC", context: 0)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
}

class OptionsIC: WKInterfaceController {
    
    @IBOutlet weak var question: WKInterfaceLabel!
    
    @IBOutlet weak var centerImage: WKInterfaceImage!
    @IBOutlet weak var centerOption: WKInterfaceLabel!
    @IBOutlet weak var topLeftImage: WKInterfaceImage!
    @IBOutlet weak var topLeftOption: WKInterfaceLabel!
    @IBOutlet weak var topRightImage: WKInterfaceImage!
    @IBOutlet weak var topRightOption: WKInterfaceLabel!
    @IBOutlet weak var bottomLeftImage: WKInterfaceImage!
    @IBOutlet weak var bottomLeftOption: WKInterfaceLabel!
    @IBOutlet weak var bottomRightImage: WKInterfaceImage!
    @IBOutlet weak var bottomRightOption: WKInterfaceLabel!
    
    var questions = [Question]()
    var type:TotalOption = .other
    var questionIndex = -1
    
    @IBAction func onClickCenterOption() {
        self.nextQuestion(for: self.questions[questionIndex].nextQuestion[0])
    }
    
    @IBAction func onClickTopLeftOption() {
        self.nextQuestion(for: self.questions[questionIndex].nextQuestion[self.type == .three ? 1 : 0])
    }
    
    @IBAction func onClickTopRightOption() {
        self.nextQuestion(for: self.questions[questionIndex].nextQuestion[self.type == .three ? 2 : 1])
    }
    
    @IBAction func onClickBack() {
        self.pop()
    }
    
    @IBAction func onClickCancel() {
        self.popToRootController()
    }
    
    @IBAction func onClickBottomLeftOption() {
        self.nextQuestion(for: self.questions[questionIndex].nextQuestion[2])
    }
    
    @IBAction func onClickBottomRight() {
        self.nextQuestion(for: self.questions[questionIndex].nextQuestion[3])
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        if let index = context as? Int {
            self.questionIndex = index
            let index = 0
            self.questions = [
                Question(title: "Are you?", options: ["Indoor", "Outdoor"], icons: ["loc-indoor", "loc-outdoor"],
                         nextQuestion: [index + 1, index + 1], identifier: "location-in-out"),
                Question(title: "Activity last 10-minutes", options: ["Relaxing", "Sitting", "Standing", "Exercising"],
                         icons: ["met-relaxing", "met-sitting", "met-walking", "met-exercising"], nextQuestion: [index + 2, index + 2, index + 2, index + 2],
                         identifier: "met"),
                Question(title: "Can you perceive air movement?", options: ["Yes", "No"],
                         icons: ["yes", "no"], nextQuestion: [index + 3, index + 3], identifier: "air-speed"),
                Question(title: "Should the light be?", options: ["Dimmer", "No change", "Brighter"],
                         icons: ["light-dim", "light-comf", "light-bright"], nextQuestion: [index + 4, index + 4, index + 4], identifier: "light"),
                Question(title: "Any changes in the last 10-min?",
                         options: ["Yes", "No"], icons: ["yes", "no"], nextQuestion: [index + 5, index + 5], identifier: "any-change"),
                Question(title: "The air is ...", options: ["Stuffy", "Fresh"],
                         icons: ["air-quality-smelly", "air-quality-fresh"], nextQuestion: [index + 6, index + 6],
                         identifier: "air-quality"),
                Question(title: "Do you feel ... ?", options: ["Sleepy", "Alert"],
                         icons: ["alertness-sleepy", "alertness-alert"], nextQuestion: [index + 7, index + 7],
                         identifier: "alertness"),
                Question(title: "The space is ...", options: ["Too Quiet", "Comfortable", "Too noisy"],
                         icons: ["noise-quiet", "noise-no-change", "noise-noisy"], nextQuestion: [index + 8, index + 8, index + 8],
                         identifier: "noise"),
                Question(title: "Should the air movement be?", options: ["Less", "No Change", "More"],
                         icons: ["air-mov-less", "air-mov-no-change", "air-mov-more"], nextQuestion: [index + 9, index + 9, index + 9],
                         identifier: "air-movement")]
            self.setupView()
        } else {
            self.popToRootController()
        }
    }
    
    private func setupView() {
        self.question.setText(questions[questionIndex].title)
        switch questions[questionIndex].options.count {
        case 2: self.withTwoOption()
        case 3: self.withThreeOption()
        case 4: self.withFourOption()
        default: break
        }
        self.showOptions(for: self.type)
    }
    
    private func withTwoOption() {
        self.type = .two
        self.topLeftOption.setText(self.questions[questionIndex].options[0])
        self.topLeftImage.setImageNamed(self.questions[questionIndex].icons[0])
        self.topRightOption.setText(self.questions[questionIndex].options[1])
        self.topRightImage.setImageNamed(self.questions[questionIndex].icons[1])
        if self.questions[questionIndex].options[0] == "Yes" || self.questions[questionIndex].options[0] == "No" {
            self.topLeftOption.setHidden(true)
            self.topRightOption.setHidden(true)
            self.topRightImage.setHeight(45)
            self.topRightImage.setWidth(45)
            self.topLeftImage.setHeight(45)
            self.topLeftImage.setWidth(45)
        }
    }
    
    private func withThreeOption() {
        self.type = .three
        self.centerOption.setText(self.questions[questionIndex].options[0])
        self.centerImage.setImageNamed(self.questions[questionIndex].icons[0])
        self.topLeftOption.setText(self.questions[questionIndex].options[1])
        self.topLeftImage.setImageNamed(self.questions[questionIndex].icons[1])
        self.topRightOption.setText(self.questions[questionIndex].options[2])
        self.topRightImage.setImageNamed(self.questions[questionIndex].icons[2])
        self.showOptions(for: .three)
    }
    
    private func withFourOption() {
        self.type = .four
        self.topLeftOption.setText(self.questions[questionIndex].options[0])
        self.topLeftImage.setImageNamed(self.questions[questionIndex].icons[0])
        self.topRightOption.setText(self.questions[questionIndex].options[1])
        self.topRightImage.setImageNamed(self.questions[questionIndex].icons[1])
        self.bottomLeftOption.setText(self.questions[questionIndex].options[2])
        self.bottomLeftImage.setImageNamed(self.questions[questionIndex].icons[2])
        self.bottomRightOption.setText(self.questions[questionIndex].options[3])
        self.bottomRightImage.setImageNamed(self.questions[questionIndex].icons[3])
        self.showOptions(for: .four)
    }
    
    private func showOptions(for type: TotalOption) {
        switch type {
        case .two:
            self.hideCenter()
            self.hideBottom()
        case .three:
            self.hideBottom()
        case .four:
            self.hideCenter()
        case .other:
            break
        }
    }
    
    private func hideBottom() {
        self.bottomLeftImage.setHidden(true)
        self.bottomLeftOption.setHidden(true)
        self.bottomRightImage.setHidden(true)
        self.bottomRightOption.setHidden(true)
    }
    
    private func hideCenter() {
        self.centerImage.setHidden(true)
        self.centerOption.setHidden(true)
    }
    
    private func nextQuestion(for index: Int) {
        if self.questions.count > index {
            self.pushController(withName: "OptionsIC", context: index)
        } else {
            self.pushController(withName: "feedback", context: nil)
        }
    }
    
    enum TotalOption {
        case two
        case three
        case four
        case other
    }
}

class FeedbackIc: WKInterfaceController {

    override func awake(withContext context: Any?) {
//        WKInterfaceController.reloadRootPageControllers(withNames: ["WelcomeInterfaceController"], contexts: nil, orientation: .horizontal, pageIndex: 0)
    }
}
