//
//  Persistence.swift
//  Cozie
//
//  Created by Denis on 10.02.2023.
//

import CoreData

protocol DataBaseStorageProtocol: DataBaseStorageSettingsProtocol {
    func backendSetting() throws -> BackendInfo?
    func createBackendSetting(apiReadUrl: String?,
                           apiReadKey: String?,
                           apiWriteUrl: String?,
                           apiWriteKey: String?,
                           oneSigmnalId: String?,
                           participantPassword: String?,
                           watchSurveyLink: String?,
                           phoneSurveyLink: String?) throws
    func removeBackendSetting() async throws
    
    
    func selectedWatchSurvey() throws -> WatchSurveyData?
    func externalWatchSurvey() throws -> WatchSurveyData?
    
    func updateStorageWithSurvey(_ surveyModel: WatchSurveyModelController, selected: Bool) async throws
    func removeExternalSurvey() async throws

    func saveViewContext() throws
}

protocol DataBaseStorageSettingsProtocol {
    func createSettingsData() -> SettingsData
    func settings() throws -> SettingsData?
}

struct PersistenceController {
#if TEST
    static let shared = PersistenceController(inMemory: true)
#else
    static let shared = PersistenceController()
#endif
    
    static var preview: PersistenceController = {
        return PersistenceController(inMemory: true)
    }()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Cozie")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController: DataBaseStorageProtocol {
    
    func saveViewContext() throws {
        try container.viewContext.save()
    }
    
    func backendSetting() throws -> BackendInfo? {
        try container
            .viewContext
            .fetch(BackendInfo.fetchRequest())
            .first
    }
    
    
    /// Created default settings data.
    func createSettingsData() -> SettingsData {
        SettingsData(context: container.viewContext)
    }
    
    /// Get settins model.
    func settings() throws -> SettingsData? {
        try container.viewContext.fetch(SettingsData.fetchRequest()).first
    }
    
    
    func createBackendSetting(apiReadUrl: String?,
                           apiReadKey: String?,
                           apiWriteUrl: String?,
                           apiWriteKey: String?,
                           oneSigmnalId: String?,
                           participantPassword: String?,
                           watchSurveyLink: String?,
                           phoneSurveyLink: String?) throws {
        let backend = BackendInfo(context: container.viewContext)
        backend.api_read_url = apiReadUrl
        backend.api_read_key = apiReadKey
        backend.api_write_url = apiWriteUrl
        backend.api_write_key = apiWriteKey
        backend.one_signal_id = Defaults.OneSignalAppID // oneSigmnalId
        backend.participant_password = participantPassword
        backend.watch_survey_link = watchSurveyLink
        backend.phone_survey_link = phoneSurveyLink
        
        try container.viewContext.save()
    }
    
    func selectedWatchSurvey() throws -> WatchSurveyData? {
        let request = WatchSurveyData.fetchRequest()
        request.predicate = NSPredicate(format: "selected == %d", true)
        let surveysList = try container.viewContext.fetch(request)
        return surveysList.first
    }
    
    func externalWatchSurvey() throws -> WatchSurveyData? {
        let request = WatchSurveyData.fetchRequest()
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "external == %d", true)
        let surveysList = try container.viewContext.fetch(request)
        return surveysList.first
    }
    
    func updateStorageWithSurvey(_ surveyModel: WatchSurveyModelController, selected: Bool) async throws {
        try await self.container.performBackgroundTask({ context in
            context.automaticallyMergesChangesFromParent = true
            // remove previouse saved external
            let request = WatchSurveyData.fetchRequest()
            if !selected {
                request.predicate = NSPredicate(format: "external == %d", true)
            }
            
            let surveysList = try context.fetch(request)
            
            surveysList.forEach { modle in
                // reset previouse selected
                if selected {
                    if modle.selected {
                        modle.selected = false
                    }
                    // remove all internal
                    if !modle.external {
                        context.delete(modle)
                    }
                } else {
                    context.delete(modle)
                }
            }
            
            // Save new survey to core data
            let watchSurvey = WatchSurveyData(context: context)
            watchSurvey.surveyID = surveyModel.surveyID
            watchSurvey.surveyName = surveyModel.surveyName
            watchSurvey.firstQuestionID = surveyModel.firstQuestionID
            
            if selected  {
                watchSurvey.selected = selected
            } else {
                watchSurvey.external = true
            }
            
            surveyModel.survey.enumerated()
                .forEach{ (index, survey) in
                    let surveyData = SurveyData(context: context)
                    surveyData.watchSurvey = watchSurvey
                    surveyData.question = survey.question
                    surveyData.questionID = survey.questionID
                    surveyData.index = Int16(index)
                    survey.responseOptions.enumerated().forEach { (index, respObj) in
                        let responseOptionData = ResponseOptionData(context: context)
                        responseOptionData.survey = surveyData
                        responseOptionData.index = Int16(index)
                        responseOptionData.text = respObj.text
                        responseOptionData.nextQuestionID = respObj.nextQuestionID
                        responseOptionData.icon = respObj.icon
                        responseOptionData.iconBackgroundColor = respObj.iconBackgroundColor
                        responseOptionData.useSfSymbols = respObj.useSfSymbols
                        responseOptionData.sfSymbolsColor = respObj.sfSymbolsColor
                    }
                }
            
            try context.save()
        })
    }
    
    func removeExternalSurvey() async throws {
        try await self.container.performBackgroundTask({ context in
            context.automaticallyMergesChangesFromParent = true
            // remove previouse saved external
            let request = WatchSurveyData.fetchRequest()
            request.predicate = NSPredicate(format: "external == %d", true)
            
            let surveysList = try context.fetch(request)
            
            surveysList.forEach { modle in
                context.delete(modle)
            }
            try context.save()
        })
    }
    
    func removeBackendSetting() throws {
        let context = self.container.viewContext
        let request = BackendInfo.fetchRequest()
        let settings = try context.fetch(request)
        
        settings.forEach { modle in
            context.delete(modle)
        }
        try context.save()
    }
}

