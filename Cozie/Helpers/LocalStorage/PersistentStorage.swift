//
//  PersistentStorage.swift
//  Cozie
//
//  Created by Square Infosoft on 06/01/22.
//  Copyright © 2022 Federico Tartarini. All rights reserved.
//

import CoreData

final class PersistentStorage {

    private init() {
    }

    static let shared = PersistentStorage()

    // MARK: - Core Data stack
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Cozie")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    lazy var context = persistentContainer.viewContext

    // MARK: - Core Data Saving support
    func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let error = error as NSError
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
    }

    func newBackgroundContext() -> NSManagedObjectContext {
        let context = persistentContainer.newBackgroundContext()
        context.name = "background_context"
        context.transactionAuthor = "main_app_background_context"
        context.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        context.automaticallyMergesChangesFromParent = true
        return context
    }

    func fetchManagedObject<T: NSManagedObject>(managedObject: T.Type) -> [T]? {
        do {
            guard let result = try PersistentStorage.shared.context.fetch(managedObject.fetchRequest()) as? [T] else {
                return nil
            }
            return result
        } catch let error {
            debugPrint(error)
        }
        return nil
    }
}

extension NSManagedObjectContext {
    func saveContext() {
        if hasChanges {
            do {
                try save()
                reset()
            } catch (let error as NSError) {
                print("coreData save failed: \(error), \(error.userInfo)")
            }
        }
    }

    func removeObjects(fetchRequest: NSFetchRequest<NSFetchRequestResult>) {
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try execute(deleteRequest)
        } catch let error as NSError {
            print(error)
        }
    }
}

struct QuestionAnswer: Codable {
    let voteLog: Int?
    let question: String?
    let answer: String?
}

struct SurveyDetails: Codable {
    let voteLog: Int
    let locationTimestamp: String
    let startTimestamp: String
    let endTimestamp: String
    let participantID: String
    let experimentID: String
    let deviceUUID: String
    let latitude: Double
    let longitude: Double
    let body_mass: Double
    let responses: [QuestionAnswer]?
    let heartRate: Int
    let isSync: Bool
}
