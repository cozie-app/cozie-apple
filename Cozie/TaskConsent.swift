//
//  TaskConsent.swift
//  Cozie
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import ResearchKit

public var TaskConsent: ORKOrderedTask {

    var steps = [ORKStep]()

    let consentDocument = ConsentInfo
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    steps += [visualConsentStep]

    let signature = consentDocument.signatures!.first!

    let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)

    reviewConsentStep.title = "Participant information"
    reviewConsentStep.text = "Please provide your name and surname as in your passport in the form below."
    reviewConsentStep.reasonForConsent = "By pressing the Agree button you are providing your consent to join the study"

    steps += [reviewConsentStep]

    let completionStep = ORKCompletionStep(identifier: "CompletionStep")
    completionStep.title = NSLocalizedString("Welcome aboard.", comment: "")
    completionStep.text = NSLocalizedString("Thank you for joining this study.", comment: "")

    steps += [completionStep]

    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
