////
////  TaskConsentFormBuild.swift
////  Cozie
////
////  Created by Federico Tartarini on 25/5/20.
////  Copyright © 2020 Federico Tartarini. All rights reserved.
////
//
//import Foundation
//import ResearchKit
//
//public var ConsentForm: ORKConsentDocument {
//
//    // tutorial http://blog.shazino.com/articles/dev/researchkit-consent/
//
//    let consentDocument = ORKConsentDocument()
//    consentDocument.title = "Example Consent"
//
//    // defined below are all the consent sections
//    let section1 = ORKConsentSection(type: .overview)
//    section1.summary = """
//                       My name is Federico Tartarini, PhD. I am a postdoctoral researcher at Berkeley Education Alliance for Research in Singapore (BEARS Ltd.), working under the supervision of Prof. Stefano Schiavon, associate professor at the University of California, Berkeley and Clayton Miller assistant professor at the National University of Singapore, Singapore.
//
//                       We are planning to conduct a research study in which we are aiming to determine how environmental (e.g. relative humidity, dry-bulb air temperature), personal (i.e. clothing and metabolic rate) and physiological (e.g. skin temperature, heart rate) parameters affect how you perceive your thermal environment.
//
//                       Key information:
//                       \t•\tYou are being invited to participate in a research study. Participation in research is completely voluntary.
//                       \t•\tThe purpose of the study is to determine how environmental and physiological parameters affect how you perceive your thermal environment. The data collection phase is expected to last for 180 days. You are expected to complete an average of 42 thermal comfort surveys each week (6 per day) for the whole duration of the project. Each survey is expected to take less than 10 seconds to complete.
//                       \t•\tRisks and/or discomforts may include wearing a Fitbit which has two small temperature sensors attached, breach of confidentiality.
//                       \t•\tThere is no direct benefit for you. This study may help us to improve conditions in spaces indoors.
//                       """
//    section1.content = section1.summary
//
//    let section2 = ORKConsentSection(type: .dataGathering)
//    section2.title = "Data Collection"
//    section2.summary = "The data collection phase is expected to last for 180 days. \n\t•\tThe only active task that you will be required to do during this period is to complete a thermal comfort survey using the clock face installed in your Fitbit. The survey contains 8 questions e.g. are you indoor? Yes or No; Are you comfy? Yes or No. You can complete the survey at any time but no more than 6 times per hour. Surveys can be completed only after wearing the Fitbit for at least 20 minutes. You will not be required to wear the Fitbit for a minimum amount of time daily. However, we will encourage you to wear it for as long as possible.\n\t•\tWe will be monitoring remotely temperature and relative humidity at: your workplace; home using the Netatmo and Ubibot stations provided to you. We will be monitoring air temperature near a bag of your choice that you generally carry with you; and near your body using two iButtons. You will also have to connect the Netatmo station, and preferably the Ubibot, to the Wi-Fi. Remotely we will also be logging noise and CO2 concentrations at your home and illuminance at your workplace. The Fitbit API services will be used to record automatically your heart rate and steps. Finally, we will be recording your location (GPS coordinates) when you complete a thermal comfort survey using the Fitbit App and every time you come in close proximity to either of the beacons using the BEARS app. Your location will not be monitored at all time. \n\t•\tWe will use the telegram app to communicate with you and occasionally remind you to complete the thermal comfort survey, if need be. The telegram app will not be used to collect data and you will never be forced to complete a survey. Telegram messages may be sent to you between 9:00 and 22:00. A maximum of 1 message per hour will be sent.\n\t•\tYou will be able to access anytime the set-up instructions, a copy of the ethics, consent form, this document and other general information about this study using this link: https://github.com/FedericoTartarini/Cozie-field-study/wiki\n\t•\tYou will be invited to attend two follow up sessions during which we will download the data collected by the iButtons. One session will be scheduled approximately 30 days after the start of the study and the second session after 90 days.\nFor the whole duration of the study you will have to maintain the status of ‘active participant’. If you fail to do so, PIs will ask you to withdraw from the study. Active participant status is maintained if all the conditions listed below are met: \n\t•\tComplete an average of at least 42 thermal comfort surveys per week. If you will not meet the aforementioned response rate for more than one consecutive week, you will be asked to withdraw from the study, unless you provide a valid justification. You will not be asked to complete the questionnaire if you feel unwell. If you were sick for a cumulative period longer than 2 weeks during the study, you will be asked to extend your participation in the study by a number of weeks equal to the period you were unwell.\n\t•\tYou should not complete the survey more than 6 times per hour. A maximum count of 6 responses per hour will be used to calculate the aforementioned average weekly response rate.\n\t•\tIf you will not wear the watch in an appropriate manner (e.g. loose and the iButtons will not be in contact with your skin) you will be asked to withdraw from the study.\n\t•\tThe environmental logger installed in your home must be connected to the Wi-Fi at all times. The environmental logger cannot connect to 5GHz nor to Enterprise Wi-Fi networks."
//    section2.content = section2.summary
//
//    let section3 = ORKConsentSection(type: .privacy)
//    section3.title = "Confidentiality"
//    section3.summary = "Your study data will be handled as confidentially as possible. If results of this study are published or presented, individual names and other personally identifiable information will never be disclosed. The access to all identifiable data and records will be limited only to the investigators stated in this protocol. To minimize the risks all data collected from you during the experiment will be labeled with unique identifiers. Unique identifiers will be used to match the data collected by the data loggers with the data you provided in the participant survey (e.g. height, weight, etc.). Your research records will be stored in encrypted format in password-protected computers owned by researchers in accordance with the UC Berkeley regulations."
//    section3.content = section3.summary
//
//    let section4 = ORKConsentSection(type: .dataUse)
//    section4.summary = "After identifiers removal from the data, de-identified data could be used for future research studies or distributed to other investigators without additional informed consent from the subject or the legally authorized representative. De-identified data will be retained indefinitely of possible use in future research done by ourselves or others. The identification data (key) will be retained for a maximum period of 1 year after the end of the study and then destroyed. Personal data collected using survey tools will be downloaded and removed from the survey tool providers’ database after all participants have been on-boarded in the study. Signed consent forms will be retained for a minimum of three years after the end of the study."
//    section4.content = section4.summary
//
//    let section5 = ORKConsentSection(type: .timeCommitment)
//    section5.summary = "The data collection is expected to last for 180 days. It is expected to take you less than 10 seconds to complete each survey. Hence, we are estimating that you will have to commit no more than 20 hours of your time in total to perform active tasks (which include for example completing comfort surveys, attending on-boarding, etc.). We expect that on a normal day your average commitment will be approximately 1 minute (time to complete at least 6 comfort surveys). While your average commitment per week will be approximately less than 10 minutes (7 minutes to complete surveys plus 3 minutes to charge the Fitbit)."
//    section5.content = section5.summary
//
//    let section6 = ORKConsentSection(type: .studySurvey)
//    section6.summary = "We are going to ask you to complete the Cozie survey using your apple watch on a daily basis and some other survey to gather data about you."
//    section6.content = section6.summary
//
//    let section7 = ORKConsentSection(type: .studyTasks)
//    section7.title = "On-boarding"
//    section7.summary = "The on-boarding will be held at SinBerBEST headquarter, CREATE Tower, 1 CREATE Way, #11- 02, University Town, Singapore 138602. \n\t•\tThe scope of the introduction session is to explain how the experiment will be conducted, how data will be collected and how you can prepare for the study. It is expected that this session will run for approximately an hour. \n\t•\tYou will be asked to fill a survey regarding your basic demographic information (sex, age, academic status, ethnic group). This survey and all other questionnaires are available for your evaluation before you decide to take part in the study. \n\t•\tDuring the introduction session we will give you to bring home with you: one Fitbit Versa, two iButton installed on the Fitbit wrist band to measure near body and skin temperature, one Netatmo logger, one Ubibot logger, one iButton and two Bluetooth beacons. You will only have to connect the Netatmo and Ubibot loggers to the Wi-Fi and power up the Netatmo using the power adapter provided. No other installation is required. The BLE beacons do not need any installation and are battery powered. They can be even be hidden in a drawer if you prefer.\n\t•\tFinally, I will ask you to install the following applications of your Android personal device: BEARS BLE beacon scanner, Telegram, Fitbit."
//    section7.content = section7.summary
//
//    let section8 = ORKConsentSection(type: .withdrawing)
//    section8.summary = "Participation in this research is completely voluntary. You have the right to decline to participate or to withdraw at any point in this study without penalty or loss of benefits to which you are otherwise entitled."
//    section8.content = section8.summary
//
//    let section9 = ORKConsentSection(type: .custom)
//    section9.title = "Costs and benefits"
//    section9.summary = """
//                       You will get to keep a Fitbit Versa for the whole duration of the study. You will be able to use the Fitbit to track your fitness, steps, sleep and activities. In addition, this study will allow us to learn more about factors affecting people’s thermal preferences, and we hope that this information will help in the future to create better conditions in the built environment spaces.
//
//                       There are no costs to subjects or their insurance carriers. Participant will be provided with all the necessary equipment. The only direct cost associated with the study would be the electricity used to recharge the smart watch and to power up one of the two indoor environmental station. In addition, the BEARS app may use few MB of data over the course of the whole study. While the Netatmo and Ubibot loggers may use few MB of your broadband data plan. You will not have to pay for damaging any of the equipment provided by investigators as long as you will return to the investigators all damaged items. However, your non-monetary contribution will be reduced if you fail to return any of the following equipment: i) Fitbit, Netatmo, or Ubibot your compensation will be reduced by SGD 150 per item; ii) BLE beacons or iButtons your compensation will be reduced by SGD 50. You will not be charged if the total amount of equipment lost/not returned exceeds your non-monetary contribution. If you lose any of the devices or they are stolen, you must promptly report that to the police or campus security and share with us the police record as soon as available. 
//                       """
//    section9.content = section9.summary
//
//    let section10 = ORKConsentSection(type: .custom)
//    section10.title = "Compensation"
//    section10.summary = "In return for your time and effort if you participate for the whole duration of the study (i.e. 180 days) you will receive non-monetary compensation in the form of gift vouchers (e.g. Capita Voucher, Grab Gift Voucher). The voucher will be issued to you only after you return all the gear that was given to you. However, if you decide to withdraw earlier from the study or you are invited to withdraw by any of the PIs you will be compensated as follows: No compensation - participation shorter than a 15 days; 20 SGD - participation between 16 and 30 days; 50 SGD - participation between 31 and 90 days; 100 SGD - participation between 91 and 180 days; 400 SGD participation for more than 180 days."
//    section10.content = section10.summary
//
//    // You can add or remove sections based on the IRB document
//    consentDocument.sections = [section1, section2, section3, section4, section5, section6, section7, section8, section9, section10]
//
//    consentDocument.addSignature(ORKConsentSignature(forPersonWithTitle: "Participant", dateFormatString: nil,
//            identifier: "ConsentDocumentParticipantSignature"))
//
//    return consentDocument
//}
//
