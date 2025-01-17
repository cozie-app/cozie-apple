//
//  SettingViewModelTests.swift
//  Cozie
//
//  Created by Alexandr Chmal on 05.01.25.
//

import Testing
import UIKit
@testable import Cozie

struct SettingViewModelTests {
    
    @Suite(.serialized) struct SetWSLinkTest {
        @Test
        @MainActor func linkFromBackendDataSettedOnFirstLoad() async throws {
            let storegeMock = CozieStorageMock()
            let dbStorage = PersistenceController(inMemory: true)
            
            let sut = SettingViewModel(reminderManager: ReminderManager(), storage: storegeMock, dbStorage: dbStorage, backendInteractor: BackendInteractor(storage: storegeMock, dbStorage: dbStorage))
            
            try dbStorage.removeBackendSetting()
            
            // set default backend data
            sut.backendInteractor.prepareBackendData()

            sut.prepareSelectedWSLinkUI(Defaults.WSStitle, updateExternalSurvey: false)
            
            #expect(storegeMock.wsLinkStub == Defaults.watchSurveyLink)
            #expect(storegeMock.wsTitleStub == Defaults.WSStitle)
            
            #expect(sut.questionViewModel.selectedId == 0)
        }
        
        @Test
        @MainActor func defaultlinkWithoutBackendDataSettedOnFirstLoad() async throws {
            let storegeMock = CozieStorageMock()
            let sut = SettingViewModel(reminderManager: ReminderManager(), storage: storegeMock, dbStorage: PersistenceController(inMemory: true), backendInteractor: BackendInteractor(storage: storegeMock))
            
            // set default backend data to empty string
            sut.backendInteractor.prepareBackendData(apiReadUrl: nil, apiReadKey: nil, apiWriteUrl: nil, apiWriteKey: nil, oneSigmnalId: nil, participantPassword: nil, watchSurveyLink: "", phoneSurveyLink: nil)

            sut.prepareSelectedWSLinkUI(Defaults.WSStitle, updateExternalSurvey: false)
            
            #expect(sut.questionViewModel.selectedId == 0)
            #expect(sut.questionViewModel.list.first?.id == QuestionViewModel.defaultQuestions.first?.id)
            #expect(sut.questionViewModel.list.first?.link == QuestionViewModel.defaultQuestions.first?.link)
        }
        
        @Test
        @MainActor func linkUpdatedIfBackendDataSettedNewLink() async throws {
            let storegeMock = CozieStorageMock()
            storegeMock.wsLinkStub = BackendSettingStub.oldWatchSurveyLink
            let sut = SettingViewModel(reminderManager: ReminderManager(), storage: storegeMock, dbStorage: PersistenceController(inMemory: true), backendInteractor: BackendInteractor(storage: storegeMock))
            
            sut.backendInteractor.prepareBackendData(apiReadUrl: BackendSettingStub.apiReadUrl, apiReadKey: BackendSettingStub.apiReadUrl, apiWriteUrl: BackendSettingStub.apiWriteUrl, apiWriteKey: BackendSettingStub.apiWriteKey, oneSigmnalId: BackendSettingStub.oneSigmnalId, participantPassword: BackendSettingStub.participantPassword, watchSurveyLink: BackendSettingStub.watchSurveyLink, phoneSurveyLink: BackendSettingStub.phoneSurveyLink)

            sut.prepareSelectedWSLinkUI(Defaults.WSStitle, updateExternalSurvey: false)
            
            #expect(sut.questionViewModel.selectedId == 0)
            #expect(sut.questionViewModel.list.first?.id == 0)
            #expect(sut.questionViewModel.list.first?.link == BackendSettingStub.watchSurveyLink)
            #expect(sut.questionViewModel.list.first?.title == "")
        }
        
        @Test
        @MainActor func selectedNotExternalLink() async throws {
            let storegeMock = CozieStorageMock()
            storegeMock.wsLinkStub = "https://raw.githubusercontent.com/cozie-app/cozie-apple/master/Watch%20Surveys/watch_survey_demo.json"
            storegeMock.wsTitleStub = "Demo"
            
            let sut = SettingViewModel(reminderManager: ReminderManager(), storage: storegeMock, dbStorage: PersistenceController(inMemory: true), backendInteractor: BackendInteractor(storage: storegeMock))

            sut.prepareSelectedWSLinkUI(Defaults.WSStitle, updateExternalSurvey: false)
            
            #expect(sut.questionViewModel.selectedId == 2)
            #expect(sut.questionViewModel.list[sut.questionViewModel.selectedId].id == 2)
            #expect(sut.questionViewModel.list[sut.questionViewModel.selectedId].link == storegeMock.wsLinkStub)
            #expect(sut.questionViewModel.list[sut.questionViewModel.selectedId].title == storegeMock.wsTitleStub)
        }
    }
}
