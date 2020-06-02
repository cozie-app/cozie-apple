//
//  ConsentTask.swift
//  Cozie
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import ResearchKit

public var ConsentTask: ORKOrderedTask {

    var steps = [ORKStep]()

    var consentDocument = ConsentDocument
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    steps += [visualConsentStep]

    let signature = consentDocument.signatures!.first as! ORKConsentSignature

    let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)

    reviewConsentStep.title = "Participant information"
    reviewConsentStep.text = "Please provide your name and surname as in your passport in the form below."
    reviewConsentStep.reasonForConsent = "By pressing the Agree button you are providing your consent to join the study"

    steps += [reviewConsentStep]

    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
