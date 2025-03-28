//
//  SyncInteractor.swift
//  Cozie
//
//  Created by Alexandr Chmal on 03.04.23.
//

import Foundation
import CoreData

// TODO: - Unit Tests
class SyncInteractor {
    let persistenceController = PersistenceController.shared
    let baseRepo = BaseRepository()
    
    let backendInteractor = BackendInteractor()
    
    func getAPI() -> (url: String, key: String) {
        if let backendSettings = backendInteractor.currentBackendSettings {
            return (backendSettings.api_read_url ?? "", backendSettings.api_read_key ?? "")
        }
        return ("", "")
    }

    public func syncData(completion: ( (_ error: Error?) -> Void )?) {
        let param: [String: String]
        if let userList = try? persistenceController.container.viewContext.fetch(User.fetchRequest()),
            let user = userList.first {
            param = ["id_participant": user.participantID ?? "",
                     "id_experiment": user.experimentID ?? "",
                     "id_password": user.passwordID ?? "",
                     "request": """
                     ["ws_survey_count_valid", "ws_survey_count_invalid", "ws_timestamp_survey_last"]
                     """]
        } else {
            param = [:]
        }
        let apiInfo = getAPI()
        baseRepo.get(url: apiInfo.url, parameters: param, key: apiInfo.key) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    let model = try JSONDecoder().decode(WatchSurveyModel.self, from: data)
                    
                    self?.persistenceController.container.performBackgroundTask { context in
                        context.automaticallyMergesChangesFromParent = true
                        
                        if let userList =  try? context.fetch(User.fetchRequest()),
                            let user = userList.first {
                            if let syncInfoList = try? context.fetch(SyncInfo.fetchRequest()),
                               let existingInfo = syncInfoList.first {
                                existingInfo.date = model.formattedDate()
                                existingInfo.validCount = model.validCount
                                existingInfo.invalidCount = model.invalidCount
                                existingInfo.user = user
                            } else {
                                let syncInfo = SyncInfo(context: context)
                                syncInfo.date = model.lastSync
                                syncInfo.validCount = model.validCount
                                syncInfo.invalidCount = model.invalidCount
                                syncInfo.user = user
                            }
                        }
                        try? context.save()
                        completion?(nil)
                    }
                } catch let error {
                    completion?(error)
                }
            case .failure(let error):
                completion?(error)
            }
        }
    }
    
    public func syncSummaryData(completion: ( (_ error: Error?) -> Void )?) {
        let param: [String: String]
        if let userList = try? persistenceController.container.viewContext.fetch(User.fetchRequest()),
            let user = userList.first {
            param = ["id_participant": user.participantID ?? "",
                     "id_experiment": user.experimentID ?? "",
                     "id_password": user.passwordID ?? ""]
        } else {
            param = [:]
        }
        let apiInfo = getAPI()
        baseRepo.get(url: apiInfo.url, parameters: param, key: apiInfo.key) { [weak self] result in
            switch result {
            case .success(let data):
                do {
                    
                    let list = try JSONDecoder().decode([ListSummaryModel].self, from: data)
                    
                    self?.persistenceController.container.performBackgroundTask { context in
                        context.automaticallyMergesChangesFromParent = true

                        if let userList =  try? context.fetch(User.fetchRequest()),
                            let user = userList.first, let savedSummaryList = try? context.fetch(SummaryInfoData.fetchRequest()) {
                            
                            for summary in list.enumerated() {
                                let summaryInfo:SummaryInfoData
                                if let first = savedSummaryList.first(where: { $0.index == Int16(summary.offset) }) {
                                    summaryInfo = first
                                } else {
                                    summaryInfo = SummaryInfoData(context: context)
                                }
                                summaryInfo.label = summary.element.label
                                summaryInfo.data = summary.element.data
                                summaryInfo.index = Int16(summary.offset)
                                summaryInfo.user = user
                            }
                            savedSummaryList.filter{ $0.index > list.count - 1 }.forEach{ context.delete($0) }
                        }
                        try? context.save()
                        completion?(nil)
                    }
                } catch let error {
                    completion?(error)
                }
            case .failure(let error):
                completion?(error)
            }
        }
    }
}
