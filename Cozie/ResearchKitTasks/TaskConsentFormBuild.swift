//
//  TaskConsentFormBuild.swift
//  Cozie
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import ResearchKit

public var ConsentForm: ORKConsentDocument {

    // tutorial http://blog.shazino.com/articles/dev/researchkit-consent/

    let consentDocument = ORKConsentDocument()
    consentDocument.title = "Example Consent"

    let section1 = ORKConsentSection(type: .overview)
    section1.summary = "Cozie Apple is a platform for human comfort data collection"
    section1.content = "We are using Cozie Apple to better understand how you perceive your thermal environment."

    let section2 = ORKConsentSection(type: .dataGathering)
    section2.summary = "We are collecting only data needed to better predict your thermal sensation"
    section2.content = "We are monitoring heart rate, steps, ..."

    let section3 = ORKConsentSection(type: .privacy)
    section3.summary = "We are keeping your data confidential."
    section3.content = "Only the PI will have access to the personal data. De-identified data may be used for publications."

    let section4 = ORKConsentSection(type: .dataUse)
    section4.summary = "We will be using your data for publications."
    section4.content = "Only the PI will have access to the personal data. De-identified data may be used for publications."

    let section5 = ORKConsentSection(type: .timeCommitment)
    section5.summary = "One minute of your time per day."
    section5.content = "The time commitment will be approximately 1 minute of your time per day."

    let section6 = ORKConsentSection(type: .studySurvey)
    section6.summary = "We are going to ask you to complete the Cozie survey using your apple watch and some other survey to gather data about you."
    section6.content = "It will not take you long to complete them."

    let section7 = ORKConsentSection(type: .studyTasks)
    section7.summary = "You will only have to complete the surveys nothing more."
    section7.content = "Tasks will be minimal."

    let section8 = ORKConsentSection(type: .withdrawing)
    section8.summary = "You can withdraw from the study."
    section8.content = "Withdrawing from the study will not affect your relations with us and NUS."

    let section9 = ORKConsentSection(type: .overview)
    section9.title = "Risk"
    section9.summary = "Minimal risk."
    section9.content = "You will not have to pay if you break the watch."

    let section10 = ORKConsentSection(type: .overview)
    section10.title = "Compensation"
    section10.summary = "You will receive non monetary compensation"
    section10.content = "You will receive gift vouchers."

    // Create additional section objects for later sections
//    consentDocument.sections = [section1, section2, section3, section4, section5, section6, section7, section8, section9, section10]
    consentDocument.sections = [section1, section10]

    consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle: "Participant", dateFormatString: nil,
            identifier: "ConsentDocumentParticipantSignature"))

    return consentDocument
}

