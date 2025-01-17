//
//  BackendInteractorMock.swift
//  Cozie
//
//  Created by Alexandr Chmal.
//

import Testing
import UIKit
@testable import Cozie

final class BackendInteractorMock: BackendInteractorProtocol {
    let info = StubBackendInfo()
    
    func loadExternalWatchSurveyJSON(completion: (((any Error)?) -> ())?) {
    }
    
    func updateOneSign(launchOptions: [UIApplication.LaunchOptionsKey : Any]?, surveyInteractor: Cozie.WatchSurveyInteractor) {
    }
    
    var currentBackendSettings: BackendInfo? {
        return info
    }
    
    func prepareBackendData() {
    }
    
    func prepareBackendData(apiReadUrl: String?, apiReadKey: String?, apiWriteUrl: String?, apiWriteKey: String?, oneSigmnalId: String?, participantPassword: String?, watchSurveyLink: String?, phoneSurveyLink: String?) {
        info.api_read_url = apiReadUrl
        info.api_read_key = apiReadKey
        info.api_write_url = apiWriteUrl
        info.api_write_key = apiWriteKey
        
        info.participant_password = participantPassword
        info.watch_survey_link = watchSurveyLink
        info.phone_survey_link = phoneSurveyLink
    }
}

final class StubBackendInfo: BackendInfo {
    var stubbedPhone_survey_link: String = ""
    var stubbedWatch_survey_link: String = ""
    var stubbed_participant_password: String = ""
    var stubbed_one_signal_id: String = ""
    var stubbed_api_write_key: String = ""
    var stubbed_api_write_url: String = ""
    var stubbed_api_read_url: String = ""
    var stubbed_api_read_key: String = ""

    convenience init(name: String = "") {
        self.init()
        self.stubbedPhone_survey_link = name
    }
    
    override var participant_password: String? {
        set {
            stubbed_participant_password = newValue ?? ""
        }
        get {
            return stubbed_participant_password
        }
    }
    
    override var api_read_key: String? {
        set {
            stubbed_api_read_key = newValue ?? ""
        }
        get {
            return stubbed_api_read_key
        }
    }
    
    override var api_read_url: String? {
        set {
            stubbed_api_read_url = newValue ?? ""
        }
        get {
            return stubbed_api_read_url
        }
    }
    
    override var api_write_url: String? {
        set {
            stubbed_api_write_url = newValue ?? ""
        }
        get {
            return stubbed_api_write_url
        }
    }
    
    override var api_write_key: String? {
        set {
            stubbed_api_write_key = newValue ?? ""
        }
        get {
            return stubbed_api_write_key
        }
    }
    
    override var one_signal_id: String? {
        set {
            stubbed_one_signal_id = newValue ?? ""
        }
        get {
            return stubbed_one_signal_id
        }
    }
    
    override var watch_survey_link: String? {
        set {
            stubbedWatch_survey_link = newValue ?? ""
        }
        get {
            return stubbedWatch_survey_link
        }
    }
    
    override var phone_survey_link: String? {
        set {
            stubbedPhone_survey_link = newValue ?? ""
        }
        get {
            return stubbedPhone_survey_link
        }
    }
}
