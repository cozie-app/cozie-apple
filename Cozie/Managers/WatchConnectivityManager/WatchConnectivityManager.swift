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

class WatchConnectivityManagerPhone: NSObject, WatchConnectivityManagerPhoneProtocol {
    
    enum WatchConnectivityManagerError: Error, LocalizedError {
        case connectionError, surveyJSONError
        public var errorDescription: String? {
               switch self {
               case .connectionError: return "Syncing with watch failed: Cozie watch app not reachable."
               case .surveyJSONError: return "Syncing with watch failed: JSON file download failed."
               }
           }
    }
    
    static let shared = WatchConnectivityManagerPhone()
    
    let session: WCSession = WCSession.default
    let loggerInteractor = LoggerInteractor.shared
    let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), logger: LoggerInteractor.shared)
    var activateCompletion: (()->())?
    var activateFailureCompletion: ((_ error: Error)->())?
    var transferringFileCompletion: ((_ error: Error?)->())?
    
    override init() {
        super.init()
        activate()
    }
    
    func activate() {
        if WCSession.isSupported(), !session.isReachable {
            if session.activationState == .activated, !session.isReachable {
                failure()
                return
            }
            session.delegate = self
            session.activate()
        } else {
            failure()
        }
    }
    
    private func failure() {
        if activateFailureCompletion != nil {
            activateFailureCompletion?(WatchConnectivityManagerError.connectionError)
            activateFailureCompletion = nil
        }
    }
    // TODO: - Unit Tests
    func sendUserData(userID: String, expID: String, password: String) {
        activateCompletion = { [weak self] in
            let params = [CommunicationKeys.userIDKey.rawValue: userID,
                          CommunicationKeys.expIDKey.rawValue: expID,
                          CommunicationKeys.passwordIDKey.rawValue: password]
            
            self?.session.sendMessage(params, replyHandler: { response in
                debugPrint(response)
            }, errorHandler: { error in
                debugPrint(error)
            })
        }
        
        activateIfNeededAndSendMessage()
    }
    // TODO: - Unit Tests
    func sendAPI(writeApiURL: String, writeApiKey: String) {
        
        activateCompletion = { [weak self] in
            let params = [CommunicationKeys.writeApiURL.rawValue: writeApiURL,
                          CommunicationKeys.writeApiKey.rawValue: writeApiKey]
            
            self?.session.sendMessage(params, replyHandler: { response in
                debugPrint(response)
            }, errorHandler: { error in
                debugPrint(error)
            })
        }
        
        activateIfNeededAndSendMessage()
    }
    // TODO: - Unit Tests
    func sendWatchSurvey(data: Data) {
        activateCompletion = { [weak self] in
            let params = [CommunicationKeys.jsonKey.rawValue: data]
            
            self?.session.sendMessage(params, replyHandler: { response in
                debugPrint(response)
            }, errorHandler: { error in
                debugPrint(error)
            })
        }
        
        activateIfNeededAndSendMessage()
    }
    
    // TODO: - Unit Tests
    func sendAll(data: Data,
                 writeApiURL: String,
                 writeApiKey: String,
                 userID: String,
                 expID: String,
                 password: String,
                 userOneSignalID: String,
                 timeInterval: Int,
                 healthCutoffTimeInterval: Double, completion: ((_ error: Error?)->())? = nil) {
        
        activateCompletion = { [weak self] in
            let params = [CommunicationKeys.jsonKey.rawValue: data,
                          CommunicationKeys.writeApiURL.rawValue: writeApiURL,
                          CommunicationKeys.writeApiKey.rawValue: writeApiKey,
                          CommunicationKeys.userIDKey.rawValue: userID,
                          CommunicationKeys.expIDKey.rawValue: expID,
                          CommunicationKeys.userOneSignalIDKey.rawValue: CozieStorage.shared.playerID(),
                          CommunicationKeys.passwordIDKey.rawValue: password,
                          CommunicationKeys.timeInterval.rawValue: timeInterval,
                          CommunicationKeys.healthCutoffTimeInterval.rawValue: healthCutoffTimeInterval]
            
            self?.session.sendMessage(params, replyHandler: { response in
                debugPrint(response)
                if let success = response[CommunicationKeys.received.rawValue] as? Bool, success {
                    completion?(nil)
                    return
                }
                
                if let transferStatus = response[CommunicationKeys.transferFileStatusKey.rawValue] as? Int {
                    switch transferStatus {
                    case FileTransferStatus.started.rawValue:
                        self?.transferringFileCompletion = completion
                    case FileTransferStatus.error.rawValue:
                        completion?(WatchConnectivityManagerError.connectionError)
                    default:
                        completion?(WatchConnectivityManagerError.connectionError)
                    }
                }
            }, errorHandler: { error in
                debugPrint(WatchConnectivityManagerError.connectionError)
                completion?(WatchConnectivityManagerError.connectionError)
            })
        }
        
        activateFailureCompletion = completion
        activateIfNeededAndSendMessage()
    }
    
    private func activateIfNeededAndSendMessage() {
        if session.isReachable {
            sendMessage()
        } else {
            activate()
        }
    }
    
    private func sendMessage() {
        activateCompletion?()
        activateCompletion = nil
    }
}

extension WatchConnectivityManagerPhone: WCSessionDelegate {
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("Session Did Become Inactive")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("Session Did Deactivate")
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated, session.isReachable {
            activateCompletion?()
            activateCompletion = nil
        } else {
            failure()
            activateCompletion = nil
        }
    }
    
    // TODO: - Unit Tests
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        
        if let logs = message[CommunicationKeys.wsLogs.rawValue] as? String {
            loggerInteractor.logInfo(action: "", info: logs)
            replyHandler([CommunicationKeys.received.rawValue: true])
            
            // testLog(details: "ConnectivityManager received logs from watch!", state: "info")
        }
    }
    
    func sessionReachabilityDidChange(_ session: WCSession) {
        // testLog(details: session.isReachable ? "ConnectivityManager Session Reachabil!" : "ConnectivityManager Session not Reachabil!", state: "info")
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
