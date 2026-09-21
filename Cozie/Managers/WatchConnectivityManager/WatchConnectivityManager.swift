//
//  WatchConnectivityManager.swift
//  Cozie
//
//  Created by Alexandr Chmal on 19.04.23.
//

import Foundation
import WatchConnectivity

protocol WatchConnectivityManagerPhoneProtocol {
    func sendAll(data: Data,
                 writeApiURL: String,
                 writeApiKey: String,
                 userID: String,
                 expID: String,
                 password: String,
                 userOneSignalID: String,
                 timeInterval: Int,
                 healthCutoffTimeInterval: Double, completion: ((_ error: Error?)->())?)
}

// Small transport boundary so activation, delayed delivery and acknowledgements are testable.
protocol WatchSettingsSession: AnyObject {
    var delegate: WCSessionDelegate? { get set }
    var activationState: WCSessionActivationState { get }
    var isReachable: Bool { get }
    func activate()
    func updateApplicationContext(_ applicationContext: [String: Any]) throws
    func sendMessage(_ message: [String: Any], replyHandler: (([String: Any]) -> Void)?, errorHandler: ((Error) -> Void)?)
}

extension WCSession: WatchSettingsSession {}

class WatchConnectivityManagerPhone: NSObject, WatchConnectivityManagerPhoneProtocol {
    
    enum WatchConnectivityManagerError: Error, LocalizedError {
        case connectionError, surveyJSONError, invalidSettings, pending, superseded
        public var errorDescription: String? {
               switch self {
               case .invalidSettings: return "Syncing with watch failed: settings or survey are incomplete or invalid."
               case .pending: return "Settings are saved for delivery. Open Cozie on your watch to finish syncing, then press Sync to confirm."
               case .superseded: return "A newer settings sync has replaced this request."
               case .connectionError: return "Syncing with watch failed: Cozie watch app not reachable."
               case .surveyJSONError: return "Syncing with watch failed: JSON file download failed."
               }
           }
    }
    
    static let shared = WatchConnectivityManagerPhone()
    
    let session: WatchSettingsSession
    private let defaults: UserDefaults
    private let supported: Bool
    private let acknowledgementTimeout: TimeInterval
    lazy var loggerInteractor = LoggerInteractor.shared
    private static let snapshotKey = "CozieLatestSettingsSnapshot"
    private var snapshot: [String: Any]
    private var completion: ((Error?) -> Void)?
    private var timeout: DispatchWorkItem?
    private var sendingRevision: String?
    var transferringFileCompletion: ((_ error: Error?)->())?

    init(session: WatchSettingsSession = WCSession.default,
         defaults: UserDefaults = .standard,
         supported: Bool = WCSession.isSupported(),
         acknowledgementTimeout: TimeInterval = 20) {
        self.session = session
        self.defaults = defaults
        self.supported = supported
        self.acknowledgementTimeout = acknowledgementTimeout
        self.snapshot = defaults.dictionary(forKey: Self.snapshotKey) ?? [:]
        super.init()
        activate()
    }

    func activate() {
        guard supported else { return }
        session.delegate = self
        session.activate()
    }

    func sendAll(data: Data,
                 writeApiURL: String,
                 writeApiKey: String,
                 userID: String,
                 expID: String,
                 password: String,
                 userOneSignalID: String,
                 timeInterval: Int,
                 healthCutoffTimeInterval: Double,
                 completion: ((_ error: Error?)->())? = nil) {
        DispatchQueue.main.async {
            let revision = UUID().uuidString
            let timestamp = max(Date().timeIntervalSince1970,
                                (self.snapshot[CommunicationKeys.settingsTimestamp.rawValue] as? Double ?? 0) + 0.001)
            let params: [String: Any] = [
                CommunicationKeys.settingsRevision.rawValue: revision,
                CommunicationKeys.settingsTimestamp.rawValue: timestamp,
                CommunicationKeys.jsonKey.rawValue: data,
                CommunicationKeys.writeApiURL.rawValue: writeApiURL,
                CommunicationKeys.writeApiKey.rawValue: writeApiKey,
                CommunicationKeys.userIDKey.rawValue: userID,
                CommunicationKeys.expIDKey.rawValue: expID,
                CommunicationKeys.passwordIDKey.rawValue: password,
                CommunicationKeys.userOneSignalIDKey.rawValue: CozieStorage.shared.playerID(),
                CommunicationKeys.timeInterval.rawValue: timeInterval,
                CommunicationKeys.healthCutoffTimeInterval.rawValue: healthCutoffTimeInterval
            ]
            guard SettingsSyncPayload.isValid(params) else {
                completion?(WatchConnectivityManagerError.invalidSettings)
                return
            }
            guard self.supported else {
                completion?(WatchConnectivityManagerError.connectionError)
                return
            }
            self.finish(WatchConnectivityManagerError.superseded)
            self.snapshot = params
            self.defaults.set(params, forKey: Self.snapshotKey)
            self.completion = completion
            let timeout = DispatchWorkItem { [weak self] in
                self?.finish(WatchConnectivityManagerError.pending)
            }
            self.timeout = timeout
            DispatchQueue.main.asyncAfter(deadline: .now() + self.acknowledgementTimeout, execute: timeout)
            if self.session.activationState == .activated {
                self.deliverLatestSettings()
            } else {
                self.activate()
            }
        }
    }

    // All mutable synchronization state is confined to the main queue.
    private func deliverLatestSettings() {
        guard session.activationState == .activated, !snapshot.isEmpty else { return }
        do {
            try session.updateApplicationContext(snapshot)
        } catch {
            debugPrint("Settings context failed:", error)
            finish(error)
            return
        }
        guard session.isReachable,
              let revision = snapshot[CommunicationKeys.settingsRevision.rawValue] as? String,
              sendingRevision != revision else { return }
        sendingRevision = revision
        session.sendMessage(snapshot, replyHandler: { response in
            DispatchQueue.main.async {
                if self.sendingRevision == revision { self.sendingRevision = nil }
                self.receiveAcknowledgement(response)
            }
        }, errorHandler: { error in
            DispatchQueue.main.async {
                if self.sendingRevision == revision { self.sendingRevision = nil }
                // The background context remains queued even if immediate delivery fails.
                debugPrint("Immediate settings delivery failed:", error)
            }
        })
    }

    private func receiveAcknowledgement(_ message: [String: Any]) {
        guard let revision = message[CommunicationKeys.settingsRevision.rawValue] as? String,
              revision == snapshot[CommunicationKeys.settingsRevision.rawValue] as? String,
              let success = message[CommunicationKeys.received.rawValue] as? Bool else { return }
        finish(success ? nil : WatchConnectivityManagerError.invalidSettings)
    }

    private func finish(_ error: Error?) {
        timeout?.cancel()
        timeout = nil
        let callback = completion
        completion = nil
        callback?(error)
    }
}

extension WatchConnectivityManagerPhone: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {}

    func sessionDidDeactivate(_ session: WCSession) {
        DispatchQueue.main.async {
            self.sendingRevision = nil
            self.activate()
        }
    }

    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        DispatchQueue.main.async {
            guard activationState == .activated else {
                self.finish(error ?? WatchConnectivityManagerError.connectionError)
                return
            }
            self.deliverLatestSettings()
        }
    }

    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String: Any]) {
        DispatchQueue.main.async { self.receiveAcknowledgement(applicationContext) }
    }

    func session(_ session: WCSession, didReceiveMessage message: [String: Any], replyHandler: @escaping ([String: Any]) -> Void) {
        if let logs = message[CommunicationKeys.wsLogs.rawValue] as? String {
            loggerInteractor.logInfo(action: "", info: logs)
            replyHandler([CommunicationKeys.received.rawValue: true])
        }
    }

    func sessionReachabilityDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.deliverLatestSettings() }
    }

    func sessionWatchStateDidChange(_ session: WCSession) {
        DispatchQueue.main.async { self.deliverLatestSettings() }
    }

    // TODO: - Unit Tests
    func session(_ session: WCSession, didReceive file: WCSessionFile) {
        do {
            let wlogs = try String(contentsOf: file.fileURL, encoding: .utf8)
            loggerInteractor.logInfo(action: "", info: wlogs)
            session.sendMessage([CommunicationKeys.transferFileStatusKey.rawValue : FileTransferStatus.finished.rawValue], replyHandler: { [weak self] response in
                if let success = response[CommunicationKeys.received.rawValue] as? Bool, success {
                    self?.transferCompletion(nil)
                } else {
                    self?.transferCompletion(WatchConnectivityManagerError.connectionError)
                }
            })
        } catch let error {
            debugPrint("error reading file: \(error)")
            session.sendMessage([CommunicationKeys.transferFileStatusKey.rawValue : FileTransferStatus.error.rawValue], replyHandler: { [weak self] response in
                if let success = response[CommunicationKeys.received.rawValue] as? Bool, success {
                    self?.transferCompletion(nil)
                } else {
                    self?.transferCompletion(WatchConnectivityManagerError.connectionError)
                }
            })
        }
    }
    
    func session(_ session: WCSession, didFinish fileTransfer: WCSessionFileTransfer, error: Error?) {
        if let error = error {
            debugPrint(error)
            transferCompletion(error)
            return
        }
        
        debugPrint(fileTransfer.progress)
    }
    
    private func transferCompletion(_ error: Error?) {
        if transferringFileCompletion != nil {
            transferringFileCompletion?(error)
        }
        transferringFileCompletion = nil
    }
    
    // log test
    //    private func testLog(details: String, state: String = "error") {
    //
    //        let str =
    //        """
    //        {
    //        "trigger": "SessionReachability",
    //        "si_connectivity_manager_state": "\(state)",
    //        "si_connectivity_manager_details": "\(details)",
    //        }
    //        """
    //        LoggerInteractor.shared.logInfo(action: "", info: str)
    //    }
}
