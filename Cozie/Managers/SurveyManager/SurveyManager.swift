//
//  SurveyManager.swift
//  Cozie
//
//  Created by Alexandr Chmal on 25.05.23.
//

import Foundation

class SurveyManager {
    // TO DO: async/await
    func update(surveyListData: Data, storage: StorageRepositoryProtocol, selected: Bool, completion: ((_ error: Error?)->())? ) {
        do {
            let surveyModel = try JSONDecoder().decode(WatchSurveyModelController.self, from: surveyListData)
            // set first question ID
            surveyModel.firstQuestionID = surveyModel.survey.first?.questionID
            Task {
                try await storage.updateStorageWithSurvey(surveyModel, selected: selected)
                DispatchQueue.main.async {
                    completion?(nil)
                }
            }
            
        } catch let error {
            debugPrint(error.localizedDescription)
            DispatchQueue.main.async {
                completion?(WatchConnectivityManagerPhone.WatchConnectivityManagerError.surveyJSONError)
            }
        }
    }
    // TO DO: async/await
    func asyncUpdate(surveyListData: Data, storage: StorageRepositoryProtocol, selected: Bool) async throws {
        return try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) -> Void in
            self.update(surveyListData: surveyListData, storage: storage, selected: selected) { err in
                if let error = err {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
}

extension SurveyManager: SurveyManagerProtocol {}
