//
//  WatchSurveyViewModel.swift
//  Cozie
//
//  Created by Denis on 30.03.2023.
//

import Foundation

struct QuestionType {
    let id: Int
    let title: String
    let link: String
}

class QuestionViewModel: ObservableObject {
    static let defaultQuestions = [QuestionType(id: 0, title: "Thermal (short)",   link: "https://raw.githubusercontent.com/cozie-app/cozie-apple/master/Watch%20Surveys/watch_survey_thermal_short.json"),
                                   QuestionType(id: 1, title: "Thermal (long)",    link: "https://raw.githubusercontent.com/cozie-app/cozie-apple/master/Watch%20Surveys/watch_survey_thermal_long.json"),
                                   QuestionType(id: 2, title: "Demo",              link: "https://raw.githubusercontent.com/cozie-app/cozie-apple/master/Watch%20Surveys/watch_survey_demo.json"),
                                   QuestionType(id: 3, title: "Noise and privacy", link: "https://raw.githubusercontent.com/cozie-app/cozie-apple/master/Watch%20Surveys/watch_survey_noise_and_privacy.json"),
                                   QuestionType(id: 4, title: "Movement",          link: "https://raw.githubusercontent.com/cozie-app/cozie-apple/master/Watch%20Surveys/watch_survey_movement.json"),
                                   QuestionType(id: 5, title: "Privacy",           link: "https://raw.githubusercontent.com/cozie-app/cozie-apple/master/Watch%20Surveys/watch_survey_privacy.json"),
                                   QuestionType(id: 6, title: "Infection Risk",    link: "https://raw.githubusercontent.com/cozie-app/cozie-apple/master/Watch%20Surveys/watch_survey_infection_risk.json")]
    
    @Published var selectedId: Int = 0
    @Published var list: [QuestionType] = QuestionViewModel.defaultQuestions
    
    func selectedTitle() -> String {
        return list[selectedId].title
    }
    
    func selectedLink() -> String {
        return list[selectedId].link
    }
    
    func selectedIDForTitle(_ title: String) -> Int {
        return list.first(where: { $0.title == title })?.id ?? 0
    }
    
    func selectedIDForLink(_ link: String) -> Int? {
        return list.first(where: { $0.link == link })?.id 
    }
    
    func firstWSInfoLink() -> QuestionType? {
        return list.first
    }
    
    func defaultSelectedID() -> Int {
        return list.first?.id ?? 0
    }
    
    func updateToDefaultState() {
        list = QuestionViewModel.defaultQuestions
    }
    
    @MainActor
    func updateWithBackendSurvey(title: String, link: String) {
        var tmpList = list
        tmpList.removeAll { type in
            type.id == 0
        }
        tmpList.insert(QuestionType(id: 0, title: title, link: link), at: 0)
        list = tmpList
    }
}

