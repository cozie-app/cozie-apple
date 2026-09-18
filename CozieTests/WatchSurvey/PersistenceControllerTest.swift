//
//  PersistenceControllerTest.swift
//  Cozie
//
//  Created by Alexandr Chmal on 18.10.24.
//

import Testing
@testable import Cozie

final class PersistenceControllerTest {
    let storage = PersistenceController(inMemory: true)
    let surveyManager: SurveyManagerProtocol = SurveyManager()
    @Test("Test Persistence Controller") func testSaveSurvey() async throws {
        let request = WatchSurveyData.fetchRequest()
        let preList  = try storage.container.viewContext.fetch(request)
        
        #expect(preList.isEmpty)
        try await surveyManager.asyncUpdate(surveyListData: TestSurveyData.surveyStub, storage: storage, selected: false)
        

        let posList  = try storage.container.viewContext.fetch(request)
        #expect(!posList.isEmpty)
    }

    @Test("Test extended survey schema persistence") func testSaveExtendedSurveySchema() async throws {
        let storage = PersistenceController(inMemory: true)
        try await surveyManager.asyncUpdate(surveyListData: TestSurveyData.extendedSurveyStub, storage: storage, selected: false)

        let survey = try #require(try storage.externalWatchSurvey()?.toModel())
        let textQuestion = try #require(survey.survey.first)
        let multiSelectQuestion = try #require(survey.survey.last)
        let exclusiveOption = try #require(multiSelectQuestion.responseOptions.last)

        #expect(textQuestion.questionType == .text)
        #expect(textQuestion.nextQuestionID == "q_recent_activities")
        #expect(multiSelectQuestion.questionType == .multiSelect)
        #expect(multiSelectQuestion.nextQuestionID == "q_done")
        #expect(exclusiveOption.exclusive)
    }
    
}
