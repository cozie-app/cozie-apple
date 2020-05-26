//
//  ViewController.swift
//  Cozie
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import ResearchKit

class ViewController: UIViewController, ORKTaskViewControllerDelegate {
    
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        //Handle results with taskViewController.result
        taskViewController.dismiss(animated: true, completion: nil)
        
        print("Start printing results ..................")
        
        if let results = taskViewController.result.results as? [ORKStepResult] {
            print("Results: \(results)")
            print("End results ........")
            for stepResult: ORKStepResult in results {

                for result in stepResult.results as! [ORKResult] {

                    if let questionResult = result as? ORKQuestionResult {
                        print("\(questionResult.identifier), \(questionResult.answer)")
                    }
                    if let tappingResult = result as? ORKTappingIntervalResult {
                        print("\(tappingResult.identifier), \(tappingResult.samples), \(NSCoder.string(for: tappingResult.buttonRect1)) \(NSCoder.string(for: tappingResult.buttonRect1)))")
                    }
                    if let toneAudiometryResult = result as? ORKToneAudiometryResult {
                        print("\(toneAudiometryResult.identifier), \(toneAudiometryResult.samples)")
                    }
                    if let spatialSpanResult = result as? ORKSpatialSpanMemoryResult {
                        print("Score \(spatialSpanResult.score) Number of games \(spatialSpanResult.numberOfGames) Number of failuers \(spatialSpanResult.numberOfFailures)")
                    }
                    else{
                        print("No printable results.")
                    }

                }
            }

        }
    }
    
    @IBAction func ConsentButton(_ sender: Any) {
        let taskViewController = ORKTaskViewController(task: ConsentTask, taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }
    
    @IBAction func SurveyButton(_ sender: Any) {
        let taskViewController = ORKTaskViewController(task: SurveyTask, taskRun: nil)
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
