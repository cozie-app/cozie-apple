//
//  HomeViewController.swift
//  Cozie
//
//  Created by Federico Tartarini on 25/5/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import ResearchKit
import FirebaseAuth
import WatchConnectivity
import FirebaseFirestore

// temp dictionary to store the answers and for testing purposes
struct AnswerResearchKit: Codable {
    let questionIdentifier: String
    let Timestamp: String
    let uid: String
    let deviceUUID: String
    var responses: [String: String]

    // convert the structure into dictionary that can be sent to Firebase
    var asDictionary : [String:Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label:String?, value:Any) -> (String, Any)? in
            guard let label = label else { return nil }
            return (label, value)
        }).compactMap { $0 })
        return dict
    }
}

var participantID = "undefined"

class ViewController: UIViewController, ORKTaskViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    var tasksToCompleteLabels = ["Consent", "Eligibility", "Survey", "On-boarding"]
    var tasksImages = [UIImage(named: "consentForm"), UIImage(named: "eligibility"), UIImage(named: "survey"), UIImage(named: "onBoarding")]
    var tasksToPerform = [TaskConsent, TaskEligibility, TaskSurvey, TaskOnBoarding]
    var tasksCompleted = [false, false, false, false]
    var taskPerformed = 0

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let user = Auth.auth().currentUser
        if let user = user {
            participantID = user.uid
        }

        // when task is completed this notification center fires and reload the collection View
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollection(notification:)), name: NSNotification.Name(rawValue: "taskCompleted"), object: nil)

    }

    @objc func reloadCollection(notification: NSNotification) {
        self.collectionView.reloadData()
    }

    // calculates how many cards to display
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tasksToCompleteLabels.count
    }

    // perform an action when a card was pressed
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // keep track of which task was performed
        taskPerformed = indexPath.row

        let taskViewController = ORKTaskViewController(task: tasksToPerform[indexPath.row], taskRun: nil)
        taskViewController.delegate = self

        present(taskViewController, animated: true, completion: nil)
    }

    // populate the card programmatically
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell

        cell.TaskImage.image = tasksImages[indexPath.row]
        cell.TaskLabel.text = tasksToCompleteLabels[indexPath.row]
        if (tasksCompleted[indexPath.row]) {
            cell.TaskCompletedIndicator.alpha = 1
        } else {
            cell.TaskCompletedIndicator.alpha = 0
        }

        // This creates the shadows and modifies the cards a little bit
//        cell.contentView.backgroundColor = UIColor.white
        // improvement programmatically resize the card size
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

    // handles the responses to the tasks from ResearchKit
    func taskViewController(_ taskViewController: ORKTaskViewController, didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {

        taskViewController.dismiss(animated: true, completion: nil)

        switch reason {
        case .completed:

            var answer = AnswerResearchKit(questionIdentifier: taskViewController.result.identifier,
                    Timestamp: GetDateTimeISOString(), uid: participantID,
                    deviceUUID: UUID().uuidString, responses: [:])

            // improvement the code is poorly written
            // improvement save this on Firebase and locally
            // improvement show red cross if the user is not eligible
            // improvement I may not want to add green checkmark to survey
            tasksToCompleteLabels = rearrange(array: tasksToCompleteLabels, fromIndex: taskPerformed, toIndex: tasksToCompleteLabels.count - 1)
            tasksImages = rearrange(array: tasksImages, fromIndex: taskPerformed, toIndex: tasksToCompleteLabels.count - 1)
            tasksToPerform = rearrange(array: tasksToPerform, fromIndex: taskPerformed, toIndex: tasksToCompleteLabels.count - 1)
            tasksCompleted[taskPerformed] = true
            tasksCompleted = rearrange(array: tasksCompleted, fromIndex: taskPerformed, toIndex: tasksToCompleteLabels.count - 1)

            NotificationCenter.default.post(name: NSNotification.Name("taskCompleted"), object: nil)

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
                                if (questionResult.answer != nil){
                                    var resp = String(describing: questionResult.answer!).replacingOccurrences(of: "(\n", with: "")
                                    resp = resp.replacingOccurrences(of: "\n)", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                    answer.responses[questionResult.identifier] = resp
                                }
                            }
                        }
                    }
                }

                // User was created successfully, now also store name and surname
                let db = Firestore.firestore()

                // Storing the document in Firebase
                var ref: DocumentReference? = nil
                ref = db.collection("tasksResponses").addDocument(data: 
                    answer.asDictionary
                ) { err in
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added.")
                    }
                }

                // sending the data into Influx
                SendDataDatabase(answer: answer)

            }

            break

        case .discarded, .failed, .saved:
            // Only dismiss task controller
            // (back to onboarding controller)
            break

        }
    }

    func rearrange<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T>{
        var arr = array
        let element = arr.remove(at: fromIndex)
        arr.insert(element, at: toIndex)

        return arr
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
