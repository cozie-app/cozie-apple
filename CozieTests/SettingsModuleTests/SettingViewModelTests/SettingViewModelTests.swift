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
        @MainActor func linkFromBackendDataSetterOnFirstLoad() async throws {
            let storageMock = CozieStorageMock()
            let dbStorage = PersistenceController(inMemory: true)
            
            let sut = SettingViewModel(reminderManager: ReminderManager(), storage: storageMock, dbStorage: dbStorage, backendInteractor: BackendInteractor(storage: storageMock, dbStorage: dbStorage))
            
            try dbStorage.removeBackendSetting()
            
            // set default backend data
            sut.backendInteractor.prepareBackendData()

            sut.prepareSelectedWSLinkUI(Defaults.WSStitle, updateExternalSurvey: false)
            
            #expect(storageMock.wsLinkStub == Defaults.watchSurveyLink)
            #expect(storageMock.wsTitleStub == Defaults.WSStitle)
            
            #expect(sut.questionViewModel.selectedId == 0)
        }
        
        @Test
        @MainActor func defaultLinkWithoutBackendDataSetterOnFirstLoad() async throws {
            let storageMock = CozieStorageMock()
            let sut = SettingViewModel(reminderManager: ReminderManager(), storage: storageMock, dbStorage: PersistenceController(inMemory: true), backendInteractor: BackendInteractor(storage: storageMock))
            
            // set default backend data to empty string
            sut.backendInteractor.prepareBackendData(apiReadUrl: nil, apiReadKey: nil, apiWriteUrl: nil, apiWriteKey: nil, oneSignalId: nil, participantPassword: nil, watchSurveyLink: "", phoneSurveyLink: nil)

            sut.prepareSelectedWSLinkUI(Defaults.WSStitle, updateExternalSurvey: false)
            
            #expect(sut.questionViewModel.selectedId == 0)
            #expect(sut.questionViewModel.list.first?.id == QuestionViewModel.defaultQuestions.first?.id)
            #expect(sut.questionViewModel.list.first?.link == QuestionViewModel.defaultQuestions.first?.link)
        }
        
        @Test
        @MainActor func linkUpdatedIfBackendDataSetterNewLink() async throws {
            let storageMock = CozieStorageMock()
            storageMock.wsLinkStub = BackendSettingStub.oldWatchSurveyLink
            let sut = SettingViewModel(reminderManager: ReminderManager(), storage: storageMock, dbStorage: PersistenceController(inMemory: true), backendInteractor: BackendInteractor(storage: storageMock))
            
            sut.backendInteractor.prepareBackendData(apiReadUrl: BackendSettingStub.apiReadUrl, apiReadKey: BackendSettingStub.apiReadUrl, apiWriteUrl: BackendSettingStub.apiWriteUrl, apiWriteKey: BackendSettingStub.apiWriteKey, oneSignalId: BackendSettingStub.oneSignalId, participantPassword: BackendSettingStub.participantPassword, watchSurveyLink: BackendSettingStub.watchSurveyLink, phoneSurveyLink: BackendSettingStub.phoneSurveyLink)

            sut.prepareSelectedWSLinkUI(Defaults.WSStitle, updateExternalSurvey: false)
            
            #expect(sut.questionViewModel.selectedId == 0)
            #expect(sut.questionViewModel.list.first?.id == 0)
            #expect(sut.questionViewModel.list.first?.link == BackendSettingStub.watchSurveyLink)
            #expect(sut.questionViewModel.list.first?.title == "")
        }
        
        @Test
        @MainActor func selectedNotExternalLink() async throws {
            let storageMock = CozieStorageMock()
            storageMock.wsLinkStub = "https://raw.githubusercontent.com/cozie-app/cozie-apple/master/Watch%20Surveys/watch_survey_demo.json"
            storageMock.wsTitleStub = "Demo"
            
            let sut = SettingViewModel(reminderManager: ReminderManager(), storage: storageMock, dbStorage: PersistenceController(inMemory: true), backendInteractor: BackendInteractor(storage: storageMock))

            sut.prepareSelectedWSLinkUI(Defaults.WSStitle, updateExternalSurvey: false)
            
            #expect(sut.questionViewModel.selectedId == 2)
            #expect(sut.questionViewModel.list[sut.questionViewModel.selectedId].id == 2)
            #expect(sut.questionViewModel.list[sut.questionViewModel.selectedId].link == storageMock.wsLinkStub)
            #expect(sut.questionViewModel.list[sut.questionViewModel.selectedId].title == storageMock.wsTitleStub)
        }
    }
}
