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
    @Test("Test PersistenceController") func test_seve_survey() async throws {
        let request = WatchSurveyData.fetchRequest()
        let prelist  = try storage.container.viewContext.fetch(request)
        
        #expect(prelist.isEmpty)
        try await surveyManager.asyncUpdate(surveyListData: TestSurveyData.suveyStub, storage: storage, selected: false)
        

        let poslist  = try storage.container.viewContext.fetch(request)
        #expect(!poslist.isEmpty)
    }
    
}
