//
//  HomeView.swift
//  Cozie
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import ResearchKit
import FirebaseAuth

// todo implement function which checks if consent process was completed
// todo add registration Task https://github.com/ResearchKit/ResearchKit/blob/master/docs/Account/Account-template.markdown

// temp dictionary to store the answers and for testing purposes
struct AnswerResearchKit: Codable {
    let questionIdentifier: String
    let Timestamp: String
    let participantID: String
    var responses: [String: String]
}


class ViewController: UIViewController, ORKTaskViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    let tasksToCompleteLabels = ["Consent", "Eligibility", "Survey", "On-boarding"]
    let tasksImages = [UIImage(named: "consentForm"), UIImage(named: "eligibility"), UIImage(named: "survey"), UIImage(named: "onBoarding")]
    let tasksToPerform = [TaskConsent, TaskEligibility, TaskSurvey, TaskOnBoarding]

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tasksToCompleteLabels.count
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let taskViewController = ORKTaskViewController(task: tasksToPerform[indexPath.row], taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell

        cell.TaskImage.image = tasksImages[indexPath.row]
        cell.TaskLabel.text = tasksToCompleteLabels[indexPath.row]

        // todo change checkmark if the user completed the task or alternatively hide the view or move it to the bottom

        // This creates the shadows and modifies the cards a little bit
//        cell.contentView.backgroundColor = UIColor.white
        cell.contentView.layer.cornerRadius = 15.0
        cell.contentView.layer.borderWidth = 1.0
        cell.contentView.layer.borderColor = UIColor.clear.cgColor
        cell.contentView.layer.masksToBounds = false
        cell.layer.shadowColor = UIColor.gray.cgColor
        cell.layer.shadowOffset = CGSize(width: 0, height: 1.0)
        cell.layer.shadowRadius = 4.0
        cell.layer.shadowOpacity = 1.0
        cell.layer.masksToBounds = false
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: cell.contentView.layer.cornerRadius).cgPath

        return cell
    }

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {

        taskViewController.dismiss(animated: true, completion: nil)

        switch reason {
        case .completed:
            // todo mark the task completed by showing the check mark

            // todo change below variables that are set equal as constant e.g., participantID
            var answer = AnswerResearchKit(questionIdentifier: taskViewController.result.identifier,
                    Timestamp: GetDateTimeISOString(),
                    participantID: "test999", responses: [:])

            let result = taskViewController.result

            if let stepResult = result.stepResult(forStepIdentifier: "ConsentReviewStep"),
               let signatureResult = stepResult.results?.first as? ORKConsentSignatureResult {

                let consentDocument = ConsentForm
                signatureResult.apply(to: consentDocument)

                consentDocument.makePDF { (data, error) -> Void in
                    _ = NSTemporaryDirectory() as NSString

                    let path = getDocumentsDirectory().appendingPathComponent("consent.pdf")

                    do {
                        try data?.write(to: path, options: .atomic)
                    } catch {
                        // failed to write file – bad permissions, bad filename, missing permissions
                    }

                    // display to the user the consent form in PDF
                    let taskViewController = ORKTaskViewController(task: consentPDFViewerTask(), taskRun: nil)
                    taskViewController.delegate = self
                    self.present(taskViewController, animated: true, completion: nil)
                }
            } else {

                if let results = taskViewController.result.results as? [ORKStepResult] {
                    for stepResult: ORKStepResult in results {
                        for result in stepResult.results! {
                            if let questionResult = result as? ORKQuestionResult {
                                var resp = String(describing: questionResult.answer!).replacingOccurrences(of: "(\n", with: "")
                                resp = resp.replacingOccurrences(of: "\n)", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                answer.responses[questionResult.identifier] = resp
                            }
                        }
                    }
                }

                SendDataDatabase(answer: answer)

            }

            break

        case .discarded, .failed, .saved:
            // Only dismiss task controller
            // (back to onboarding controller)
            break

        }
    }

    private func SendDataDatabase(answer: AnswerResearchKit) {

        var messages = [AnswerResearchKit]()

        // check if answers are stored locally in UserDefaults, the key is answers
        if let data = UserDefaults.standard.value(forKey: "AnswerResearchKit") as? Data {

            // decode the messages stored in the local memory and convert them back to structures
            let storedMessages = try? PropertyListDecoder().decode(Array<AnswerResearchKit>.self, from: data)

            // add the last completed survey
            messages = storedMessages!
        }

        messages += [answer]

        var indexMessagesToDelete = [Int]()

        for (index, message) in messages.enumerated() {
            do {
                let postMessage = try JSONEncoder().encode(message)
                let statusCodeHTTP = PostRequest(message: postMessage)
                if (statusCodeHTTP == 200) {
                    indexMessagesToDelete.append(index)
                }
            } catch let error {
                print(error.localizedDescription)
            }
        }

        // delete the messages that have been sent
        for index in indexMessagesToDelete.reversed() {
            messages.remove(at: index)
        }

        // save the messages to local storage so I replace what was previously there
        UserDefaults.standard.set(try? PropertyListEncoder().encode(messages), forKey: "AnswerResearchKit")
    }
}

class SettingsController: UIViewController, ORKTaskViewControllerDelegate {

    @IBAction func ReviewConsent(_ sender: Any) {

        let taskViewController = ORKTaskViewController(task: consentPDFViewerTask(), taskRun: nil)
        taskViewController.delegate = self
        present(taskViewController, animated: true, completion: nil)
    }

    @IBAction func logOutButton(_ sender: Any) {

        let alertController = UIAlertController(title: nil, message: "Are you sure you want to Log Out?", 
                preferredStyle: .actionSheet)

        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, 
                handler: { (alert: UIAlertAction!) in self.signOut() }))

        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        present(alertController, animated: true, completion: nil)

    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {
        taskViewController.dismiss(animated: true, completion: nil)
    }

    func signOut() {
        do {
            try Auth.auth().signOut()

            let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.startViewController)

            view.window?.rootViewController = homeViewController
            view.window?.makeKeyAndVisible()

        } catch let error {
            print("Failed to sign out with error", error)
        }

    }

}
