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

  reviewConsentStep.text = "Review Consent!"
  reviewConsentStep.reasonForConsent = "Consent to join study"

  steps += [reviewConsentStep]

  
  return ORKOrderedTask(identifier: "ConsentTask", steps: steps)
}
