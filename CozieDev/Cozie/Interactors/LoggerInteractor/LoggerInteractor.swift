//
//  LoggerInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 12.04.23.
//

import Foundation

final class LoggerInteractor {
    
    let userIntaractor = UserInteractor()
    
    // MARK: Private
    private enum Constants: String {
        case fileNamePrefix = "cozie_"
        case fileNameSufix = "logs.txt"
        case errorTitle = "Log history is empty"
    }
    
    private func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    private func buildFileName(additionalName: String?) -> String {
        var name = Constants.fileNamePrefix.rawValue + Constants.fileNameSufix.rawValue
        if let additionalName = additionalName {
            name = Constants.fileNamePrefix.rawValue + additionalName + Constants.fileNameSufix.rawValue
        }
        return name
    }
    
    private func userFileName(user: User) -> String {
        var name = ""
        if let participantID = user.participantID,
            let experimentID = user.experimentID {
            name = participantID + "_" + experimentID + "_"
        }
        return name
    }
    
    // MARK: Public
    func logInfo(action: String, info: String) {
        if let currentUser = userIntaractor.currentUser {
            let filename = getDocumentsDirectory().appendingPathComponent(buildFileName(additionalName: userFileName(user: currentUser)))
            
            do {
                var logHistory = ""
                if FileManager.default.fileExists(atPath: filename.relativePath) {
                    logHistory = try String(contentsOfFile: filename.relativePath)
                }
                if !logHistory.isEmpty {
                    logHistory.removeLast()
                    logHistory.append(",\n")
                } else {
                    logHistory.append("[")
                }
                
                logHistory.append(info)
                logHistory.append("]")
                try logHistory.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
            } catch let error {
                debugPrint(error)
            }
        }
    }
    
    func logdeInfo(completion:((_ url: URL?,_ error: String?) -> ())?) {
        if let currentUser = userIntaractor.currentUser {
            let filename = getDocumentsDirectory().appendingPathComponent(buildFileName(additionalName: userFileName(user: currentUser)))
            
            if FileManager.default.fileExists(atPath: filename.relativePath) {
                completion?(filename, nil)
            } else {
                completion?(nil, Constants.errorTitle.rawValue)
            }
        }
    }
}
