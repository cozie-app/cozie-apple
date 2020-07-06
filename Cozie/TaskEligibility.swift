//
//  TaskEligibility.swift
//  Cozie
//
//  Created by Federico Tartarini on 6/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import ResearchKit

/**
A task demonstrating how the ResearchKit framework can be used to determine
eligibility using a navigable ordered task.
*/

public var TaskEligibility: ORKTask {

    let questionTextOne = "Are you at least 21 years of age?"
    let questionTextOneAnswer = "Yes"
    let questionTextTwo = "Are you proficient in English?"
    let questionTextTwoAnswer = "Yes"
    let questionTextThree = "Have you planning to leave Singapore in the new month?"
    let questionTextThreeAnswer = "No"

    // add here new identifiers if you need to add new questions
    enum Identifier {
        case eligibilityTask
        case eligibilityIntroStep
        case eligibilityFormStep
        case eligibilityFormItem01
        case eligibilityFormItem02
        case eligibilityFormItem03
        case eligibilityIneligibleStep
        case eligibilityEligibleStep
    }

    // Intro step
    let introStep = ORKInstructionStep(identifier: String(describing: Identifier.eligibilityIntroStep))
    introStep.title = NSLocalizedString("Eligibility Task", comment: "")
    introStep.text = "Please complete this short survey to see if you are eligible in participating in the study"
    introStep.detailText = NSLocalizedString("""
                                             By completing the following survey we will be able to determine if you are 
                                             eligible for participating in the present study.
                                             After completing the survey the application will tell you if you met all 
                                             the eligibility criteria for the study.
                                             You can contact the project investigator if you have any further questions
                                             """, comment: "")

    // Form step
    let formStep = ORKFormStep(identifier: String(describing: Identifier.eligibilityFormStep))
    formStep.title = NSLocalizedString("Eligibility", comment: "")
    formStep.isOptional = false

    // Form items
    let textChoices: [ORKTextChoice] = [ORKTextChoice(text: "Yes", value: "Yes" as NSCoding & NSCopying & NSObjectProtocol),
                                        ORKTextChoice(text: "No", value: "No" as NSCoding & NSCopying & NSObjectProtocol), 
                                        ORKTextChoice(text: "N/A", value: "N/A" as NSCoding & NSCopying & NSObjectProtocol)]
    let answerFormat = ORKTextChoiceAnswerFormat(style: ORKChoiceAnswerStyle.singleChoice, textChoices: textChoices)

    let formItem01 = ORKFormItem(identifier: String(describing: Identifier.eligibilityFormItem01),
            text: questionTextOne, answerFormat: answerFormat)
    formItem01.isOptional = false
    let formItem02 = ORKFormItem(identifier: String(describing: Identifier.eligibilityFormItem02),
            text: questionTextTwo, answerFormat: answerFormat)
    formItem02.isOptional = false
    let formItem03 = ORKFormItem(identifier: String(describing: Identifier.eligibilityFormItem03),
            text: questionTextThree, answerFormat: answerFormat)
    formItem03.isOptional = false

    formStep.formItems = [
        formItem01,
        formItem02,
        formItem03
    ]

    // Ineligible step
    let ineligibleStep = ORKInstructionStep(identifier: String(describing: Identifier.eligibilityIneligibleStep))
    ineligibleStep.title = NSLocalizedString("Eligibility Result", comment: "")
    ineligibleStep.detailText = NSLocalizedString("You are ineligible to join the study", comment: "")

    // Eligible step
    let eligibleStep = ORKCompletionStep(identifier: String(describing: Identifier.eligibilityEligibleStep))
    eligibleStep.title = NSLocalizedString("Eligibility Result", comment: "")
    eligibleStep.detailText = NSLocalizedString("You are eligible to join the study", comment: "")

    // Create the task
    let eligibilityTask = ORKNavigableOrderedTask(identifier: String(describing: Identifier.eligibilityTask), steps: [
        introStep,
        formStep,
        ineligibleStep,
        eligibleStep
    ])

    // Build navigation rules.
    var resultSelector = ORKResultSelector(stepIdentifier: String(describing: Identifier.eligibilityFormStep),
            resultIdentifier: String(describing: Identifier.eligibilityFormItem01))
    let predicateFormItem01 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector,
            expectedAnswerValue: questionTextOneAnswer as NSCoding & NSCopying & NSObjectProtocol)

    resultSelector = ORKResultSelector(stepIdentifier: String(describing: Identifier.eligibilityFormStep),
            resultIdentifier: String(describing: Identifier.eligibilityFormItem02))
    let predicateFormItem02 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector,
            expectedAnswerValue: questionTextTwoAnswer as NSCoding & NSCopying & NSObjectProtocol)

    resultSelector = ORKResultSelector(stepIdentifier: String(describing: Identifier.eligibilityFormStep),
            resultIdentifier: String(describing: Identifier.eligibilityFormItem03))
    let predicateFormItem03 = ORKResultPredicate.predicateForChoiceQuestionResult(with: resultSelector,
            expectedAnswerValue: questionTextThreeAnswer as NSCoding & NSCopying & NSObjectProtocol)

    let predicateEligible = NSCompoundPredicate(andPredicateWithSubpredicates: [predicateFormItem01,
                                                                                predicateFormItem02, predicateFormItem03])
    let predicateRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [(predicateEligible,
            String(describing: Identifier.eligibilityEligibleStep))])

    eligibilityTask.setNavigationRule(predicateRule, forTriggerStepIdentifier: String(describing: Identifier.eligibilityFormStep))

    // Add end direct rules to skip unneeded steps
    let directRule = ORKDirectStepNavigationRule(destinationStepIdentifier: ORKNullStepIdentifier)
    eligibilityTask.setNavigationRule(directRule, forTriggerStepIdentifier: String(describing: Identifier.eligibilityIneligibleStep))

    return eligibilityTask
}
