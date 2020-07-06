//
//  ViewController.swift
//  Cozie
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import ResearchKit

// todo implement function which checks if consent process was completed
// todo add registration Task https://github.com/ResearchKit/ResearchKit/blob/master/docs/Account/Account-template.markdown
// todo save the consent form in PDF so the user can keep a copy and send a copy to the researchers

// temp dictionary to store the answers and for testing purposes
struct AnswerResearchKit: Codable {
    let questionIdentifier: String
    let startDate: String
    let participantID: String
    var responses: [String: String]
}


class ViewController: UIViewController, ORKTaskViewControllerDelegate {

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        //Handle results with taskViewController.result
        taskViewController.dismiss(animated: true, completion: nil)

        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)

        // todo change below variables that are set equal as constant e.g., participantID
        var answer = AnswerResearchKit(questionIdentifier: taskViewController.result.identifier,
                startDate: formatter.string(from: taskViewController.result.startDate),
                participantID: "test999", responses: [:])

        if let results = taskViewController.result.results as? [ORKStepResult] {
            for stepResult: ORKStepResult in results {
                for result in stepResult.results! {
                    if let questionResult = result as? ORKQuestionResult {
                        var resp = String(describing: questionResult.answer!).replacingOccurrences(of: "(\n", with: "")
                        resp = resp.replacingOccurrences(of: "\n)", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
//                        tmpAnswers[questionResult.identifier] = resp
                        answer.responses[questionResult.identifier] = resp
                    }
                }
            }
        }
        
        // todo send answer to database

//
//        if let results = taskViewController.result.results as? [ORKStepResult] {
////            print("Results: \(results)")
////            print("End results ........")
//            for stepResult: ORKStepResult in results {
//
//                for result in stepResult.results! {
//
//                    if let questionResult = result as? ORKQuestionResult {
//                        print("\(questionResult.identifier), \(String(describing: questionResult.answer))")
//                    }
//                    if let tappingResult = result as? ORKTappingIntervalResult {
//                        print("""
//                              \(tappingResult.identifier), \(String(describing: tappingResult.samples)),
//                              \(NSCoder.string(for: tappingResult.buttonRect1)) \(NSCoder.string(for: tappingResult.buttonRect1)))
//                              """)
//                    }
//                    if let toneAudiometryResult = result as? ORKToneAudiometryResult {
//                        print("\(toneAudiometryResult.identifier), \(String(describing: toneAudiometryResult.samples))")
//                    }
//                    if let spatialSpanResult = result as? ORKSpatialSpanMemoryResult {
//                        print("""
//                              Score \(spatialSpanResult.score) Number of games \(spatialSpanResult.numberOfGames)
//                              Number of failuers \(spatialSpanResult.numberOfFailures)
//                              """)
//                    }
//                    else{
//                        print("No printable results.")
//                    }
//                }
//            }
//        }
    }

    @IBAction func ConsentButton(_ sender: Any) {
        let taskViewController = ORKTaskViewController(task: TaskConsent, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    @IBAction func SurveyButton(_ sender: Any) {
        let taskViewController = ORKTaskViewController(task: TaskSurvey, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    @IBAction func EligibilityButton(_ sender: Any) {
        let taskViewController = ORKTaskViewController(task: TaskEligibility, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    @IBAction func ParticipantInfo(_ sender: Any) {
        let taskViewController = ORKTaskViewController(task: TaskOnBoarding, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}

class SettingsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

    }

}
