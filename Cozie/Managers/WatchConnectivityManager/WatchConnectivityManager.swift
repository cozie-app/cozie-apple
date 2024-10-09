//
//  WatchConnectivityManager.swift
//  Cozie
//
//  Created by Alexandr Chmal on 19.04.23.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManagerPhone: NSObject {
    
    enum WatchConnectivityManagerError: Error, LocalizedError {
        case connectionError, surveyError
        public var errorDescription: String? {
               switch self {
               case .connectionError: return "Cozie Watch App not reachable"
               case .surveyError: return "Load watch survey JSON error."
               }
           }
    }
    
    static let shared = WatchConnectivityManagerPhone()
    
    let session: WCSession = WCSession.default
    let loggerInteractor = LoggerInteractor.shared
    let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), loger: LoggerInteractor.shared)
    var activateCompletion: (()->())?
    var activateFahlerCompletion: ((_ error: Error)->())?
    var transferingFileCompletion: ((_ error: Error?)->())?
    
    override init() {
        super.init()
        activate()
    }
    
    func activate() {
        if WCSession.isSupported(), !session.isReachable {
            if session.activationState == .activated, !session.isReachable {
                failer()
                return
            }
            session.delegate = self
            session.activate()
        } else {
            failer()
        }
    }
    
    private func failer() {
        if activateFahlerCompletion != nil {
            activateFahlerCompletion?(WatchConnectivityManagerError.connectionError)
            activateFahlerCompletion = nil
        }
    }
    
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
                        self?.transferingFileCompletion = completion
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
        
        activateFahlerCompletion = completion
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
            failer()
            activateCompletion = nil
        }
    }
    
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
        if transferingFileCompletion != nil {
            transferingFileCompletion?(error)
        }
        transferingFileCompletion = nil
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
