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

    // import the consent document from TaskConsentFormBuild
    let consentDocument = ConsentForm
    let visualConsentStep = ORKVisualConsentStep(identifier: "VisualConsentStep", document: consentDocument)
    steps += [visualConsentStep]

    let signature = consentDocument.signatures!.first!

    // add review section
    let reviewConsentStep = ORKConsentReviewStep(identifier: "ConsentReviewStep", signature: signature, in: consentDocument)

    reviewConsentStep.title = "Participant information"
    reviewConsentStep.text = "Please provide your name and surname as in your passport in the form below."
    reviewConsentStep.reasonForConsent = "By pressing the Agree button you are providing your consent to join the study"

    steps += [reviewConsentStep]

    // add completion step
    let completionStep = ORKCompletionStep(identifier: "CompletionStep")
    completionStep.title = NSLocalizedString("Welcome aboard.", comment: "")
    completionStep.text = NSLocalizedString("""
                                            Thank you for joining this study. 

                                            In the next view you will be able to review once more the consent document and 
                                            save it locally on your device, for your future reference.

                                            Please share the saved file with the principal investigator of the study.
                                            """, comment: "")
    
    steps += [completionStep]

    return ORKOrderedTask(identifier: "ConsentTask", steps: steps)

}
