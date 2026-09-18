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
        
        let firstQuestion = try #require(mod.survey.first)
        let firstOption = try #require(firstQuestion.responseOptions.first)
        #expect(firstQuestion.questionType == .singleSelect)
        #expect(firstQuestion.nextQuestionID == nil)
        #expect(!firstOption.exclusive)
    }

    @Test func parseExtendedWatchSurveySchema() throws {
        let mod = try JSONDecoder().decode(WatchSurveyModelController.self, from: TestSurveyData.extendedSurveyStub)
        let textQuestion = try #require(mod.survey.first)
        let multiSelectQuestion = try #require(mod.survey.last)
        let regularOption = try #require(multiSelectQuestion.responseOptions.first)
        let exclusiveOption = try #require(multiSelectQuestion.responseOptions.last)

        #expect(textQuestion.questionType == .text)
        #expect(textQuestion.nextQuestionID == "q_recent_activities")
        #expect(multiSelectQuestion.questionType == .multiSelect)
        #expect(multiSelectQuestion.nextQuestionID == "q_done")
        #expect(!regularOption.exclusive)
        #expect(exclusiveOption.exclusive)
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

    static var extendedSurveyStub: Data {
        get {
        """
        {
          "survey_name": "Extended schema",
          "survey_id": "extended_schema",
          "survey": [
            {
              "question": "Please enter your seat ID.",
              "question_id": "q_seat_id",
              "question_type": "text",
              "next_question_id": "q_recent_activities",
              "response_options": [
                {
                  "text": "",
                  "icon": "",
                  "icon_background_color": "",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000"
                }
              ]
            },
            {
              "question": "Please select all recent activities.",
              "question_id": "q_recent_activities",
              "question_type": "multi_select",
              "next_question_id": "q_done",
              "response_options": [
                {
                  "text": "Had a meal",
                  "icon": "cutlery",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000"
                },
                {
                  "text": "Did none of the above activities",
                  "icon": "text_none",
                  "icon_background_color": "#F1A62E",
                  "use_sf_symbols": false,
                  "sf_symbols_color": "#000000",
                  "exclusive": true
                }
              ]
            }
          ]
        }
        """.data(using: .utf8) ?? Data()
        }
    }
}
