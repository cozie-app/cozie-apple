//
//  CommunicationKeys.swift
//  Cozie
//
//  Created by Alexandr Chmal on 19.04.23.
//

import Foundation

public enum CommunicationKeys: String {
    case jsonKey = "CosieCOMJsonKey"
    case userIDKey = "CosieCOMUserIDKey"
    case expIDKey = "CosieCOMExpKey"
    case passwordIDKey = "CosieCOMPasswordIDKey"
    case writeApiKey = "CosieCOMwriteApiKey"
    case writeApiURL = "CosieCOMwriteApiURL"
    case timeInterval = "CosieCOMtimeInterval"
    
    case resived = "recived"
    case wsLogs = "ws_logs"
}
