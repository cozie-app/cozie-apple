//
//  Persistence.swift
//  Cozie
//
//  Created by Denis on 10.02.2023.
//

import CoreData

protocol StorageRepositoryProtocol {
    func updateStorageWithSurvey(_ surveyModel: WatchSurveyModelController, selected: Bool) async throws
    func removeExternalSurvey() async throws
}

struct PersistenceController {
    static let shared = PersistenceController()

    static var preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        for _ in 0..<10 {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Cozie")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.

                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}

extension PersistenceController: StorageRepositoryProtocol {
    
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
}

