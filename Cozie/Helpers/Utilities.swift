//
//  Utilities.swift
//  Cozie
//
//  Created by Federico Tartarini on 13/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

class Utilities {
    static func styledTextField(_ textField: UITextField) {
        let bottomLine = CALayer()

        bottomLine.frame = CGRect(x: 0, y: textField.frame.height - 2, width: textField.frame.width, height: 2)

        bottomLine.backgroundColor = UIColor.init(red: 255 / 255, green: 98 / 255, blue: 20 / 255, alpha: 1).cgColor

        textField.borderStyle = .none

        textField.layer.addSublayer(bottomLine)
    }

    static func stylePrimaryButton(_ button: UIButton) {
        
        button.backgroundColor = UIColor.init(red: 255 / 255, green: 98 / 255, blue: 20 / 255, alpha: 1)

        button.layer.cornerRadius = 25

        button.tintColor = UIColor.black
    }

    static func styleSecondaryButton(_ button: UIButton) {
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.cornerRadius = 25
        button.tintColor = UIColor.black
        button.backgroundColor = UIColor.init(red: 13 / 255, green: 165 / 255, blue: 255 / 255, alpha: 1)
    }

    static func alert(url: URL, title: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: "Are you sure you want to open this page in a new tab? This might take a few moments", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: {
            (alert: UIAlertAction) in
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        return alert
    }

    static func isValidPassword(_ password: String) -> Bool {
        let passwordTest = NSPredicate(format: "SELF MATCHES %@", "^(?=.*[a-z])(?=.*[$@$#!%*?&])[A-Za-z\\d$@$#!%*?&]{8,}")

        return passwordTest.evaluate(with: password)
    }

    static func isValidEmail(testStr: String) -> Bool {
        print("validate emilId: \(testStr)")
        let emailRegEx = "^(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?(?:(?:(?:[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+(?:\\.[-A-Za-z0-9!#$%&’*+/=?^_'{|}~]+)*)|(?:\"(?:(?:(?:(?: )*(?:(?:[!#-Z^-~]|\\[|\\])|(?:\\\\(?:\\t|[ -~]))))+(?: )*)|(?: )+)\"))(?:@)(?:(?:(?:[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)(?:\\.[A-Za-z0-9](?:[-A-Za-z0-9]{0,61}[A-Za-z0-9])?)*)|(?:\\[(?:(?:(?:(?:(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))\\.){3}(?:[0-9]|(?:[1-9][0-9])|(?:1[0-9][0-9])|(?:2[0-4][0-9])|(?:25[0-5]))))|(?:(?:(?: )*[!-Z^-~])*(?: )*)|(?:[Vv][0-9A-Fa-f]+\\.[-A-Za-z0-9._~!$&'()*+,;=:]+))\\])))(?:(?:(?:(?: )*(?:(?:(?:\\t| )*\\r\\n)?(?:\\t| )+))+(?: )*)|(?: )+)?$"
        let emailTest = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    
    static func createJSON(dic: [Response]) {
        var jsonString = ""
        do {
            let encoder = JSONEncoder()
            let encoded = try encoder.encode(dic)
            jsonString = String(decoding: encoded, as: UTF8.self)
        } catch {
            print(error)
        }
        self.saveJSON(jsonString: jsonString)
    }
    
    static func saveJSON(jsonString: String) {
        if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
            let pathWithFilename = documentDirectory.appendingPathComponent("data.json")
            do {
                try jsonString.write(to: pathWithFilename,
                                     atomically: true,
                                     encoding: .utf8)
            } catch {
                print("failed to write JSON file :\(error.localizedDescription)")
            }
        }
    }
    
    static func downloadData(_ sender: UIViewController) {
        let alert = UIAlertController(title: nil, message: "Please wait...", preferredStyle: .alert)

        let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.style = UIActivityIndicatorView.Style.medium
        loadingIndicator.startAnimating();

        alert.view.addSubview(loadingIndicator)
        sender.present(alert, animated: true, completion: nil)
        
        self.getData(isForDownload: true) { (isSuccess, data) in
            sender.dismiss(animated: false, completion: nil)
            if isSuccess {
                if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                    let pathWithFilename = documentDirectory.appendingPathComponent("data.json")
                    let activityItems = [pathWithFilename]
                    let vc = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
                    vc.popoverPresentationController?.sourceView = sender.view
                    sender.present(vc, animated: true, completion: nil)
                }
            }
        }
    }
    
    static func getData(isForDownload: Bool = false, completion: @escaping (Bool, [Response]) -> Void) {
        
        let param = ["user_id":UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "","weeks":"100"]
        
        let headers = ["x-api-key":"k6iy7nxkBn9hTvScq2vHV8qhXMLl95oA2zlNdA8h",
                       "Accept":"application/json",
                       "Content-Type":"application/json"]
        
        let req = Alamofire.request("https://0iecjae656.execute-api.us-east-1.amazonaws.com/default/CozieApple_Read_Influx", method: .get, parameters: param, headers: headers).responseJSON { (response) in
            if let responseCode = response.response?.statusCode {
                if responseCode == 200 {
                    if let values = response.result.value as? NSArray, let dictionary = values.lastObject as? NSDictionary, let data = dictionary["data"] as? String {
                        if isForDownload {
                            self.saveJSON(jsonString: data)
                            completion(true, [Response]())
                        } else {
                            if let ana = (try? JSONSerialization.jsonObject(with: Data(data.utf8), options: .fragmentsAllowed) as? NSDictionary) {
                                var totalData = [Response]()
                                ana.forEach { element in
                                    do {
                                        let data = try JSONSerialization.data(withJSONObject:element.value , options: .prettyPrinted)
                                        let responseData = try JSONDecoder().decode(Response.self, from: data)
                                        totalData.append(responseData)
                                    } catch {
                                        print(error)
                                    }
                                }
                                completion(true, totalData)
                            }
                        }
                    } else {
                        print("error")
                    }
                } else {
                    completion(false, [])
                }
            }
        }
        debugPrint(req)
    }
    
    static func sendHealthData(data: [String:String]) {
        do {
            let postMessage = try JSONEncoder().encode(APIFormate(locationTimestamp: GetDateTimeISOString(), startTimestamp: GetDateTimeISOString(), endTimestamp: GetDateTimeISOString(), participantID: UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys.participantID.rawValue) as? String ?? "", responses: data))
            PostRequest(message: postMessage)
        } catch let error {
            print(error.localizedDescription)
        }
    }
}

struct Response: Codable {
    let startTimestamp: String
    let endTimestamp: String
    let locationTimestamp: String
    let latitude: Double?
    let longitude: Double?
    let user_id: String
    let voteLog: Int?
    
    func encode(to encoder: Encoder) throws {
        var val = encoder.container(keyedBy: CodingKeys.self)
        try val.encode(startTimestamp, forKey: .startTimestamp)
        try val.encode(endTimestamp, forKey: .endTimestamp)
        try val.encode(locationTimestamp, forKey: .locationTimestamp)
        try val.encode(latitude, forKey: .latitude)
        try val.encode(longitude, forKey: .longitude)
        try val.encode(user_id, forKey: .user_id)
        try val.encode(voteLog, forKey: .voteLog)
    }
}

struct APIFormate: Codable {
    let locationTimestamp: String
    let startTimestamp: String
    let endTimestamp: String
    let participantID: String
    let responses: [String:String]
}
