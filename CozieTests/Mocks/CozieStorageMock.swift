//
//  CozieStorageMock.swift
//  Cozie
//
//  Created by Alexandr Chmal.
//

@testable import Cozie

final class CozieStorageMock: UserDefaultsStorageProtocol {
    
    var wsLinkStub: String = ""
    var wsTitleStub: String = ""
    
    var wsExternalLinkStub: String = ""
    var wsExternalTitleStub: String = ""
    
    var playerIDStub = "id"
    var maxHealthCutOffIntervalStub: Double = 0
    var healthLastSyncedTimeIntervalStub: Double = 0
    var healthLastSyncedTimeIntervalOfflineStub: Double = 0
    
    var cutoffTimeIntervalStub: Double? = nil
    
    var pIDSyncedStub: Bool = false
    var expIDSyncedStub: Bool = false
    var surveySyncedStub: Bool = false
    
    var healthUpdateLastSyncedTimeIntervalParams: (interval: Double, offline: Bool) = (0.0, false)
    var healthUpdateLastSyncedTimeIntervalOfflineParams: (interval: Double, key: String, offline: Bool) = (0.0, "Key", false)
    var healthUpdateTempLastSyncedTimeIntervalParams: (interval: Double, key: String, offline: Bool) = (0.0, "Key", false)
    var healthUpdateFromTempLastSyncedTimeIntervalParams: (key: String, offline: Bool) = ("Key", false)
    
    var distanceFilterStub: Float = 0.0
    
    func setDistanceFilter(_ distance: Float) {
        distanceFilterStub = distance
    }
    
    func distanceFilter() -> Float {
        distanceFilterStub
    }
    
    
    func maxHealthCutoffTimeInterval() -> Double {
        cutoffTimeIntervalStub ?? 0.0
    }
    
    func saveMaxHealthCutoffTimeInterval(_ interval: Double) {
        cutoffTimeIntervalStub = interval
    }
    
    func playerID() -> String {
        playerIDStub
    }
    
    func savePlayerID(_ id: String) {
        playerIDStub = id
    }
    
    
    func maxHealthCutOffInterval() -> Double {
        maxHealthCutOffIntervalStub
    }
    
    func healthLastSyncedTimeInterval(offline: Bool) -> Double {
        healthLastSyncedTimeIntervalStub
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, offline: Bool) {
        healthUpdateLastSyncedTimeIntervalParams = (interval, offline)
    }
    
    func healthUpdateLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool) {
        healthUpdateLastSyncedTimeIntervalOfflineParams = (interval, key, offline)
    }
    
    func healthLastSyncedTimeInterval(key: String, offline: Bool) -> Double {
        return healthLastSyncedTimeIntervalOfflineStub
    }
    
    func healthUpdateTempLastSyncedTimeInterval(_ interval: Double, key: String, offline: Bool) {
        healthUpdateTempLastSyncedTimeIntervalParams = (interval, key, offline)
    }
    
    func healthUpdateFromTempLastSyncedTimeInterval(key: String, offline: Bool) {
        healthUpdateFromTempLastSyncedTimeIntervalParams  = (key, offline)
    }
    
    func selectedWSLink() -> SurveyInfo {
        (wsLinkStub, wsTitleStub)
    }
    
    func saveWSLink(link: SurveyInfo) {
        wsLinkStub = link.link
        wsTitleStub = link.title
    }
    
    func externalWSLink() -> SurveyInfo {
        (wsExternalLinkStub, wsExternalTitleStub)
    }
    
    func saveExternalWSLink(link: SurveyInfo) {
        wsExternalLinkStub = link.link
        wsExternalTitleStub = link.title
    }
    
    func pIDSynced() -> Bool {
        pIDSyncedStub
    }
    
    func savePIDSynced(_ synced: Bool) {
        pIDSyncedStub = synced
    }
    
    func expIDSynced() -> Bool {
        expIDSyncedStub
    }
    
    func saveExpIDSynced(_ synced: Bool) {
        expIDSyncedStub = synced
    }
    
    func surveySynced() -> Bool {
        surveySyncedStub
    }
    
    func saveSurveySynced(_ synced: Bool) {
        surveySyncedStub = synced
    }
}
