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
    static let defaultQuestions = [QuestionType(id: 0, title: "Weather (short)", link:                             "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_weather_short.txt"),
                                   QuestionType(id: 1, title: "Thermal (short)", link: "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_thermal_short.txt"),
                                   QuestionType(id: 2, title: "Thermal (long)", link: "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_thermal_long.txt"),
                                   QuestionType(id: 3, title: "Noise and privacy", link: "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_noise_and_privacy.txt"),
                                   QuestionType(id: 4, title: "Movement", link: "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_movement.txt"),
                                   QuestionType(id: 5, title: "Privacy", link: "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_privacy.txt"),
                                   QuestionType(id: 6, title: "Infection Risk", link: "https://raw.githubusercontent.com/mariofrei/cozie-test/main/watch_surveys/watch_survey_infection_risk.txt")]
    
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
    
    func updateWithBackendSurvey(title: String, link: String) {
        var tmpList = list
        tmpList.removeAll { type in
            type.id == 0
        }
        tmpList.insert(QuestionType(id: 0, title: title, link: link), at: 0)
        list = tmpList
    }
}

