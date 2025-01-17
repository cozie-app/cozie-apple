//
//  DataBaseStorageMock.swift
//  Cozie
//
//  Created by Alexandr Chmal on 17.01.25.
//

import Testing
import Foundation
@testable import Cozie

final class DataBaseStorageMock: DataBaseStorageProtocol {
    var saveViewContextCalledCout = 0
    var removeExternalSurveyCalledCount = 0
    var settingsDataSpy: SettingsData? = SettingsDataSpy()
    
    func backendSetting() throws -> Cozie.BackendInfo? {
        StubBackendInfo()
    }
    
    func createBackendSetting(apiReadUrl: String?, apiReadKey: String?, apiWriteUrl: String?, apiWriteKey: String?, oneSigmnalId: String?, participantPassword: String?, watchSurveyLink: String?, phoneSurveyLink: String?) throws {
        //
    }
    
    func removeBackendSetting() async throws {
        //
    }
    
    func selectedWatchSurvey() throws -> Cozie.WatchSurveyData? {
        WatchSurveyDataSpy(surveyID: "sID")
    }
    
    func externalWatchSurvey() throws -> Cozie.WatchSurveyData? {
        WatchSurveyDataSpy(surveyID: "sID")
    }
    
    func updateStorageWithSurvey(_ surveyModel: Cozie.WatchSurveyModelController, selected: Bool) async throws {
        //
    }
    
    func removeExternalSurvey() async throws {
        removeExternalSurveyCalledCount += 1
    }
    
    func saveViewContext() throws {
        saveViewContextCalledCout += 1
    }
    
    func createSettingsData() -> Cozie.SettingsData {
        settingsDataSpy = SettingsDataSpy()
        return settingsDataSpy!
    }
    
    func settings() throws -> Cozie.SettingsData? {
        settingsDataSpy
    }
}

final class WatchSurveyDataSpy: WatchSurveyData {
    var firstQuestionIDSpy: String?
    override var firstQuestionID: String? {
        get {
            firstQuestionIDSpy
        }
        set {
            firstQuestionIDSpy = newValue
        }
    }
    
    var surveyIDSpy: String?
    override var surveyID: String? {
        get {
            surveyIDSpy
        }
        set {
            surveyIDSpy = newValue
        }
    }
    
    var surveyNameSpy: String?
    override var surveyName: String? {
        get {
            surveyNameSpy
        }
        set {
            surveyNameSpy = newValue
        }
    }

    var selectedSpy: Bool = false
    override var selected: Bool {
        get {
            selectedSpy
        }
        set {
            selectedSpy = newValue
        }
    }
    
    var externalSpy: Bool = false
    override var external: Bool {
        get {
            externalSpy
        }
        set {
            externalSpy = newValue
        }
    }
    
    var surveySpy: NSSet?
    override var survey: NSSet? {
        get {
            surveySpy
        }
        set {
            surveySpy = survey
        }
    }
    
    convenience init(surveyID: String?) {
        self.init()
        self.surveyID = surveyID
    }
}
