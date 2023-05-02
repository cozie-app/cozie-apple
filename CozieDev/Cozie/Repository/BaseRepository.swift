//
//  WatchSurvayRepository.swift
//  Cozie
//
//  Created by Denis on 23.03.2023.
//

import Foundation
import CoreData

class BaseRepository: ObservableObject {
    enum ServiceError: Error {
        case badResponce
    }
    
    // MARK: Base GET
    func get(url: String, parameters: [String: String], key: String, completion: @escaping (Result<Data, Error>) -> Void) {
        guard var componentsQuery = URLComponents(string: url) else { return }
        
        var itemsList = [URLQueryItem]()
        for (key, value) in parameters {
            itemsList.append(URLQueryItem(name: key, value: value))
        }
        componentsQuery.queryItems = itemsList
        
        if let url = componentsQuery.url {
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            
            urlRequest.allHTTPHeaderFields = [
                "Accept": "application/json",
                "x-api-key": key
            ]
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let responseData = data {
                    completion(.success(responseData))
                } else {
                    debugPrint("error - Sync data!")
                    completion(.failure(ServiceError.badResponce))
                }
            }.resume()
        }
    }
    
    // MARK: Base GET JSON file
    func getFileContent(url: String, parameters: [String: String]?, completion: @escaping (Result<Data, Error>) -> Void) {
        guard var componentsQuery = URLComponents(string: url) else { return }
        
        if let param = parameters {
            var itemsList = [URLQueryItem]()
            for (key, value) in param {
                itemsList.append(URLQueryItem(name: key, value: value))
            }
            componentsQuery.queryItems = itemsList
        }
        
        if let url = componentsQuery.url {
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "GET"
            
            urlRequest.allHTTPHeaderFields = [
                "Accept": "application/json",
                "Content-Type": "application/json"
            ]
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let responseData = data {
                    DispatchQueue.main.async {
                        completion(.success(responseData))
                    }
                } else {
                    debugPrint("error - GET JSON file!")
                    completion(.failure(ServiceError.badResponce))
                }
            }.resume()
        }
    }
    
    // MARK: Base Post
    func post(url: String, body: Data, key: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        if let url = URL(string: url) {
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            
            urlRequest.allHTTPHeaderFields = [
                "Accept": "application/json",
                "Content-Type": "application/json",
                "x-api-key": key
            ]
            
            urlRequest.httpBody = body
            
            URLSession.shared.dataTask(with: urlRequest) { data, response, error in
                if let httpResponse = response as? HTTPURLResponse,
                   httpResponse.statusCode == 200,
                   let responseData = data {
                    completion(.success(responseData))
                } else {
                    debugPrint("error - POST data!")
                    completion(.failure(ServiceError.badResponce))
                }
            }.resume()
        }
    }
}
