//
//  LoggerInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 12.04.23.
//

import Foundation

final class LoggerInteractor: LoggerProtocol {
    static let shared = LoggerInteractor()
    
    let userIntaractor = UserInteractor()
    
    let semapfore = DispatchSemaphore(value: 1)
    let writeQueue = DispatchQueue.global(qos: .userInitiated)
    
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
            let date = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm"
            let dateString = dateFormatter.string(from: date)
            name = experimentID + "_" + participantID + "_" + dateString + "_"
        }
        return name
    }
    
    // MARK: Public
    func logInfo(action: String, info: String) {
        if let currentUser = userIntaractor.currentUser {
            let filename = getDocumentsDirectory().appendingPathComponent(buildFileName(additionalName: userFileName(user: currentUser)))
            writeQueue.async { [weak self] in
                self?.semapfore.wait()
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
                    self?.semapfore.signal()
                } catch let error {
                    debugPrint(error)
                    self?.semapfore.signal()
//                    self?.logInfo(action: "", info: "Writing error: \(error.localizedDescription)")
                }
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
