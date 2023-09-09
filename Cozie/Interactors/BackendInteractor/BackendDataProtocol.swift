//
//  BackendDataProtocol.swift
//  Cozie
//
//  Created by Alexandr Chmal on 04.07.23.
//

import Foundation

typealias WApiInfo = (wUrl: String, wKey: String)

protocol BackendDataProtocol {
    var apiWriteInfo: WApiInfo? { get }
}
