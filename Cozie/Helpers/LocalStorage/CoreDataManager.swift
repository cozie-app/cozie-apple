//
//  CoreDataManager.swift
//  Cozie
//
//  Created by Square Infosoft on 06/01/22.
//  Copyright © 2022 Federico Tartarini. All rights reserved.
//

import CoreData
import CoreVideo

final class CoreDataManager {

    private init() {
    }

    static let shared = CoreDataManager()

    private let cdSurveyDetails = "CDSurveyDetails"

    // MARK: - Model SurveyDetails CRUD
    func createSurvey(surveys: [SurveyDetails]) {
        let context = PersistentStorage.shared.newBackgroundContext()
        context.perform {
            surveys.forEach { survey in
                let cdSurvey = CDSurveyDetails(context: context)
                cdSurvey.voteLog = Int64(survey.voteLog)
                cdSurvey.locationTimestamp = survey.locationTimestamp
                cdSurvey.startTimestamp = survey.startTimestamp
                cdSurvey.endTimestamp = survey.endTimestamp
                cdSurvey.participantID = survey.participantID
                cdSurvey.experimentID = survey.experimentID
                cdSurvey.deviceUUID = survey.deviceUUID
                cdSurvey.latitude = survey.latitude
                cdSurvey.longitude = survey.longitude
                cdSurvey.body_mass = survey.body_mass
                cdSurvey.heartRate = Int64(survey.heartRate)
                cdSurvey.isSync = survey.isSync

                var cdQuestionAnswerArray: [Any] = []
                survey.responses?.forEach({ questionAnswer in
                    let cdQuestionAnswer = CDQuestionAnswer(context: context)
                    cdQuestionAnswer.voteLog = Int64(questionAnswer.voteLog ?? -1)
                    cdQuestionAnswer.question = questionAnswer.question
                    cdQuestionAnswer.answer = questionAnswer.answer

                    cdQuestionAnswerArray.append(cdQuestionAnswer)
                })
                cdSurvey.toQuestionAnswer = NSSet(array: cdQuestionAnswerArray)

            }
            context.saveContext()
        }
    }

    func readAllSurvey() -> [SurveyDetails]? {
        let result = PersistentStorage.shared.fetchManagedObject(managedObject: CDSurveyDetails.self)
        var survey: [SurveyDetails] = []
        result?.forEach({ (cdSurvey) in
            survey.append(cdSurvey.convertToSurvey())
        })
        return survey
    }

    func deleteSurvey(VoteLog: Int) {
        let context = PersistentStorage.shared.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: cdSurveyDetails)
        fetchRequest.predicate = NSPredicate(format: "voteLog==%@", VoteLog as CVarArg)
        fetchRequest.fetchLimit = 1
        context.perform {
            context.removeObjects(fetchRequest: fetchRequest)
            context.saveContext()
        }
    }

    private func deleteAllSurvey() {
        deleteEntity(entityName: cdSurveyDetails)
    }

    // MARK: - Model SurveyDetails CRUD
//    func createQuestionAnswer(questionAnswers: [QuestionAnswer]) {
//        let context = PersistentStorage.shared.newBackgroundContext()
//        context.perform {
//            questionAnswers.forEach { questionAnswer in
//
//            }
//            context.saveContext()
//        }
//    }

    // MARK: - Delete Entity
    private func deleteEntity(entityName: String) {
        let context = PersistentStorage.shared.newBackgroundContext()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        context.perform {
            context.removeObjects(fetchRequest: fetchRequest)
            context.saveContext()
        }
    }

    // MARK: - Whole CoreData CRUD
    func deleteAllLocalStorage() {
        deleteAllSurvey()
    }
}

// MARK: - NSManagedObject Extension
extension CDSurveyDetails {
    func convertToSurvey() -> SurveyDetails {
        var questionAnswers: [QuestionAnswer] = []
        let set = toQuestionAnswer
        let cdQuestionAnswerArray = set?.allObjects as? [CDQuestionAnswer]
        cdQuestionAnswerArray?.forEach({ questionAnswer in
            questionAnswers.append(questionAnswer.convertToQuestionAnswer())
        })
        return SurveyDetails(
                voteLog: Int(voteLog),
                locationTimestamp: self.locationTimestamp ?? FormatDateISOString(date: Date()),
                startTimestamp: self.startTimestamp ?? FormatDateISOString(date: Date()),
                endTimestamp: self.endTimestamp ?? FormatDateISOString(date: Date()),
                participantID: self.participantID ?? "",
                experimentID: self.experimentID ?? "",
                deviceUUID: deviceUUID ?? "",
                latitude: latitude,
                longitude: longitude,
                body_mass: body_mass,
                responses: questionAnswers,
                heartRate: Int(heartRate),
                isSync: isSync)
    }
}

extension CDQuestionAnswer {
    func convertToQuestionAnswer() -> QuestionAnswer {
        return QuestionAnswer(voteLog: Int(voteLog), question: question, answer: answer)
    }
}
