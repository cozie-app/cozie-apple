//
//  WatchConnectivityManager.swift
//  Cozie
//
//  Created by Alexandr Chmal on 19.04.23.
//

import Foundation
import WatchConnectivity

class WatchConnectivityManagerPhone: NSObject {
    
    static let shared = WatchConnectivityManagerPhone()
    
    let session: WCSession = WCSession.default
    let loggerInteractor = LoggerInteractor()
    var activateCompletion: (()->())?
    
    override init() {
        super.init()
        activate()
    }
    
    func activate() {
        if WCSession.isSupported(), !session.isReachable {
            session.delegate = self
            session.activate()
        }
    }
    
    func sendUserData(userID: String, expID: String, password: String) {
        activateCompletion = { [weak self] in
            let params = [CommunicationKeys.userIDKey.rawValue: userID,
                          CommunicationKeys.expIDKey.rawValue: expID,
                          CommunicationKeys.passwordIDKey.rawValue: password]
            
            self?.session.sendMessage(params, replyHandler: { responce in
                debugPrint(responce)
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
            
            self?.session.sendMessage(params, replyHandler: { responce in
                debugPrint(responce)
            }, errorHandler: { error in
                debugPrint(error)
            })
        }
        
        activateIfNeededAndSendMessage()
    }
    
    func sendWatchSurvey(data: Data) {
        activateCompletion = { [weak self] in
            let params = [CommunicationKeys.jsonKey.rawValue: data]
            
            self?.session.sendMessage(params, replyHandler: { responce in
                debugPrint(responce)
            }, errorHandler: { error in
                debugPrint(error)
            })
        }
        
        activateIfNeededAndSendMessage()
    }
    
    func sendAll(data: Data, writeApiURL: String, writeApiKey: String, userID: String, expID: String, password: String, timeInterval: Int, completion: (()->())? = nil) {
        activateCompletion = { [weak self] in
            let params = [CommunicationKeys.jsonKey.rawValue: data,
                          CommunicationKeys.writeApiURL.rawValue: writeApiURL,
                          CommunicationKeys.writeApiKey.rawValue: writeApiKey,
                          CommunicationKeys.userIDKey.rawValue: userID,
                          CommunicationKeys.expIDKey.rawValue: expID,
                          CommunicationKeys.passwordIDKey.rawValue: password,
                          CommunicationKeys.timeInterval.rawValue: timeInterval]
            
            self?.session.sendMessage(params, replyHandler: { responce in
                debugPrint(responce)
                completion?()
            }, errorHandler: { error in
                debugPrint(error)
            })
        }
        
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
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
    }
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated, session.isReachable {
            activateCompletion?()
            activateCompletion = nil
        } else {
            activateCompletion = nil
        }
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any], replyHandler: @escaping ([String : Any]) -> Void) {
        replyHandler([CommunicationKeys.resived.rawValue: true])
        
        if let logs = message[CommunicationKeys.wsLogs.rawValue] as? String {
            loggerInteractor.logInfo(action: "", info: logs)
        }
    }
}
