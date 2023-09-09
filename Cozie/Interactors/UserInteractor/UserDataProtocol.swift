//
//  UserDataProtocol.swift
//  Cozie
//
//  Created by Alexandr Chmal on 04.07.23.
//

import Foundation

typealias CUserInfo = (participantID: String, passwordID: String, experimentID: String)

protocol UserDataProtocol {
    var userInfo: CUserInfo? { get }
}
