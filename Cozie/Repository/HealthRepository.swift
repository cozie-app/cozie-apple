//
//  HealthRepository.swift
//  Cozie
//
//  Created by Alexandr Chmal on 09.08.2022.
//  Copyright © 2022 Federico Tartarini. All rights reserved.
//

import Foundation
protocol HealthRepositoryType {
    func sendHealthInfo(data: Data, completion: ((_ result: Result<Void, Error>)->())?)
}

class HealthRepository: BaseRepository {}

extension HealthRepository: HealthRepositoryType {
    func sendHealthInfo(data: Data, completion: ((_ result: Result<Void, Error>)->())?) {
        guard let url = URL(string: AWSWriteURL) else { return }
        
        post(url: url, parameters: nil, body: data, headers: nil) { result in
            switch result {
            case .success(_):
                completion?(.success(()))
            case .failure(let error):
                completion?(.failure(error))
            }
        }
    }
}
