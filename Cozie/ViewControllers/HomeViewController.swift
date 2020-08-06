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
import FirebaseFirestore

// structure to store the answers from ResearchKit
struct AnswerResearchKit: Codable {

    let questionIdentifier: String  // researchKit task identifier
    let Timestamp: String
    let uid: String  // user id from Firebase
    var responses: [String: String]

    // convert the structure into dictionary that can be sent to Firebase
    var asDictionary: [String: Any] {
        let mirror = Mirror(reflecting: self)
        let dict = Dictionary(uniqueKeysWithValues: mirror.children.lazy.map({ (label: String?, value: Any) -> (String, Any)? in
            guard let label = label else {
                return nil
            }
            return (label, value)
        }).compactMap {
            $0
        })
        return dict
    }
}

// struct to store ResearchKit tasks to be presented to the user
struct Task: Codable {
    let label: String
    let image: String
    let taskID: Int
    var completed: Bool
}

var userFirebaseUID = "undefined"

class ViewController: UIViewController, ORKTaskViewControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {

    // task id that was performed
    var taskPerformed = 0

    var tasks = [Task]()
    // improvement the following variable should be embedded into tasks and should not be a separate array
    // I am storing it as a separate array at the moment since inside a struct I cannot have an item of type ResearchKit task
    // if I want to save the list of structures in the User Defaults. I need to save it in user defaults so i can keep track of tasks performed
    var tasksToPerform = [TaskConsent, TaskEligibility, TaskSurvey, TaskOnBoarding]

    @IBOutlet weak var collectionView: UICollectionView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // save the uid from firebase
        let user = Auth.auth().currentUser
        if let user = user {
            userFirebaseUID = user.uid
        }

        // if the app loads for the first time define tasks to be presented to the participant alternatively import array stored tasks
        if let data = UserDefaults.standard.value(forKey: "tasks") as? Data {

            let storedValues = try? PropertyListDecoder().decode(Array<Task>.self, from: data)
            tasks = storedValues!

        } else {
            // improvement the code is poorly written since taskID is linked to taskToPerform
            // initialize the tasks to be presented
            tasks += [
                Task(label: "Consent", image: "consentForm", taskID: 0, completed: false),
                Task(label: "Eligibility", image: "eligibility", taskID: 1, completed: false),
                Task(label: "Survey", image: "survey", taskID: 2, completed: false),
                Task(label: "On-boarding", image: "onBoarding", taskID: 3, completed: false)
            ]

        }

        // when a task is completed this notification center fires and reload the collection View
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollection(notification:)),
                name: NSNotification.Name(rawValue: "taskCompleted"), object: nil)

    }

    @objc func reloadCollection(notification: NSNotification) {
        self.collectionView.reloadData()
    }

    // calculates how many cards to display
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tasks.count
    }

    // perform an action when a card was pressed
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {

        // keep track of which task was performed
        taskPerformed = indexPath.row

        let taskViewController = ORKTaskViewController(task: tasksToPerform[tasks[indexPath.row].taskID], taskRun: nil)
        taskViewController.delegate = self

        present(taskViewController, animated: true, completion: nil)
    }

    // populate the card programmatically
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell

        cell.TaskImage.image = UIImage(named: tasks[indexPath.row].image)
        cell.TaskLabel.text = tasks[indexPath.row].label
        if (tasks[indexPath.row].completed) {
            cell.TaskCompletedIndicator.alpha = 1
        } else {
            cell.TaskCompletedIndicator.alpha = 0
        }

        // This creates the shadows and modifies the cards a little bit
        // improvement change from a collection view to a tabular view
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
    func taskViewController(_ taskViewController: ORKTaskViewController,
                            didFinishWith reason: ORKTaskViewControllerFinishReason, error: Error?) {

        taskViewController.dismiss(animated: true, completion: nil)

        switch reason {
        case .completed:

            var answer = AnswerResearchKit(questionIdentifier: taskViewController.result.identifier,
                    Timestamp: GetDateTimeISOString(), uid: userFirebaseUID, responses: [:])

            // improvement show red cross if the user is not eligible
            // improvement I may not want to add green checkmark to survey since the user may need to complete it more than once

            // mark task performed as completed and move its card to the end of the list
            tasks[taskPerformed].completed = true
            tasks = reArrangeArray(array: tasks, fromIndex: taskPerformed, toIndex: tasks.count - 1)

            // save the messages to local storage so I replace what was previously there
            UserDefaults.standard.set(try? PropertyListEncoder().encode(tasks), forKey: "tasks")

            // fire notification center so the view is reloaded and cards are rearranged
            NotificationCenter.default.post(name: NSNotification.Name("taskCompleted"), object: nil)

            let result = taskViewController.result

            // if consent task was performed
            if let stepResult = result.stepResult(forStepIdentifier: "ConsentReviewStep"),
               let signatureResult = stepResult.results?.first as? ORKConsentSignatureResult {

                // save the consent as a PDF
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

                // loop and extract the participant's answers which are nested and store them
                if let results = taskViewController.result.results as? [ORKStepResult] {
                    print(results)
                    for stepResult: ORKStepResult in results {
                        for result in stepResult.results! {
                            if let questionResult = result as? ORKQuestionResult {
                                if (questionResult.answer != nil) {
                                    var resp = String(describing: questionResult.answer!).replacingOccurrences(of: "(\n", with: "")
                                    resp = resp.replacingOccurrences(of: "\n)", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                                    answer.responses[questionResult.identifier] = resp
                                }
                            }
                        }
                    }
                }

                // initiate firestore
                let db = Firestore.firestore()

                // Storing the answer in Firebase
                var ref: DocumentReference? = nil
                ref = db.collection("tasksResponses").addDocument(data:
                answer.asDictionary
                ) { err in
                    // improvement display error to the user
                    if let err = err {
                        print("Error adding document: \(err)")
                    } else {
                        print("Document added.")
                    }
                }

//                // sending the data into Influx
//                SendDataDatabase(answer: answer)

            }

            break

        case .discarded, .failed, .saved:
            // Only dismiss task controller
            // (back to on-boarding controller)
            break

        @unknown default:
            break
        }
    }

    func reArrangeArray<T>(array: Array<T>, fromIndex: Int, toIndex: Int) -> Array<T> {

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
