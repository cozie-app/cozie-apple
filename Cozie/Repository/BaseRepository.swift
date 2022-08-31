//
//  BaseRepository.swift
//  Cozie
//
//  Created by Alexandr Chmal on 09.08.2022.
//  Copyright © 2022 Federico Tartarini. All rights reserved.
//

import Foundation


open class BaseRepository {
    enum Method: String {
        case GET, POST, PUT, DELETE
    }
    
    enum CommonError: Error {
        case custorm(message: String)
        
        func message() -> String {
            switch self {
            case .custorm(let message):
                return message
            }
        }
    }
    
    func post(url: URL, parameters: [String: Any]? = nil, body: Data? = nil, headers:[String: Any]? = nil, completion:((_ result: Result<Any, Error>)-> ())? = nil) {
        let session = URLSession.shared

        var request = baseRequest(method: .POST, url: url)
        
        if let body = body {
            request.httpBody = body
#warning("Add paramter/object encoding if needed")
        } else if let parameters = parameters, !parameters.isEmpty {}
        
        request.setValue(AWSWriteAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        // create dataTask using the session object to send data to the server
        session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

            guard error == nil else {
                completion?(.failure(error!))
                return
            }

            guard data != nil else {
                completion?(.failure(CommonError.custorm(message: "Invalid response.")))
                return
            }

            if let response = response,
                let nsHTTPResponse = response as? HTTPURLResponse,
               nsHTTPResponse.statusCode == 200 {
                completion?(.success(()))
            }
        }).resume()
    }
    
    func baseRequest(method: Method, url: URL) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        
        request.setValue(AWSWriteAPIKey, forHTTPHeaderField: "x-api-key")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        return request
    }
}
