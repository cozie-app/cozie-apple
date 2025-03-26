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
    
}
