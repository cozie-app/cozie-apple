//
//  WatchSurveyModelControllerTest.swift
//  CozieTests
//
//  Created by Alexandr Chmal on 18.10.24.
//

import Testing
import Foundation
@testable import Cozie

final class WatchSurveyModelControllerTest {
    
    init() async throws {}
    deinit {}
    
    @Test func parseWatchSurveyModel() throws {
        let mod = try JSONDecoder().decode(WatchSurveyModelController.self, from: TestSurveyData.surveyStub)
        
        #expect(mod.surveyName == "Thermal (short)")
        #expect(mod.surveyID == "thermal_short")
        
        _ = try #require(mod.survey.first)
    }
}

// MARK: - Helper

struct TestSurveyData {
    static var surveyStub: Data {
        get {
        """
        {
          "survey_name": "Thermal (short)",
          "survey_id": "thermal_short",
          "survey": [{
              "question": "How would you prefer to be?",
              "question_id": "q_thermal",
              "response_options": [{
                  "text": "Cooler",
                  "icon": "snowflake",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "next_question_id": "q_location"
                },
                {
                  "text": "No Change",
                  "icon": "emoticon_happy",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "next_question_id": "q_location"
                },
                {
                  "text": "Warmer",
                  "icon": "flame",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "next_question_id": "q_location"
                }
              ]
            },
            {
              "question": "Where are you?",
              "question_id": "q_location",
              "response_options": [{
                  "text": "Outdoor",
                  "icon": "person_walking",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "next_question_id": "q_clothing"
                },
                {
                  "text": "Indoor",
                  "icon": "person_laptop",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "next_question_id": "q_clothing"
                }
              ]
            },
            {
              "question": "What clothes are you wearing?",
              "question_id": "q_clothing",
              "response_options": [{
                  "text": "Very light",
                  "icon": "clothes_shirt_sleeveless",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "next_question_id": ""
                },
                {
                  "text": "Light",
                  "icon": "clothes_shirt_shorts",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "next_question_id": ""
                },
                {
                  "text": "Medium",
                  "icon": "clothes_shirt_pants",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "next_question_id": ""
                },
                {
                  "text": "Heavy",
                  "icon": "clothes_pullover",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "next_question_id": ""
                }
              ]
            }
          ]
        }
        """.data(using: .utf8) ?? Data()
        }
    }
}
