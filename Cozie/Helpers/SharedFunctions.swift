//
// Created by Federico Tartarini on 7/7/20.
// Copyright (c) 2020 Federico Tartarini. All rights reserved.
//

import Foundation

// convert current time in ISO string
public func GetDateTimeISOString() -> String {
    let date = Date()
    return FormatDateISOString(date: date)
}

// convert a date into ISO string
public func FormatDateISOString(date: Date) -> String {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions.insert(.withFractionalSeconds)
    return formatter.string(from: date)
}

// get document directory
public func getDocumentsDirectory() -> URL {
    let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
    return paths[0]
}

// send data via a POST request, the function it is synchronous
public func PostRequest(message: Data) -> Int {
    // create the url with URL
//        let url = URL(string: "https://qepkde7ul7.execute-api.us-east-1.amazonaws.com/default/CozieApple-to-influx")! //change the url
    let url = URL(string: "http://ec2-52-76-31-138.ap-southeast-1.compute.amazonaws.com:1880/cozie-apple")! //change the url

    // create the session object
    let session = URLSession.shared

    // now create the URLRequest object using the url object
    var request = URLRequest(url: url)
    request.httpMethod = "POST" //set http method as POST

    request.httpBody = message

//        request.setValue("3lvUimwWTv3UlSjSct0RS3yxQWIKFG0G7bcWtM10", forHTTPHeaderField: "x-api-key")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    request.addValue("application/json", forHTTPHeaderField: "Accept")

    var responseStatusCode = 0
    // semaphore to wait for the function to complete
    let sem = DispatchSemaphore.init(value: 0)

    //create dataTask using the session object to send data to the server
    let task = session.dataTask(with: request as URLRequest, completionHandler: { data, response, error in

        defer {
            sem.signal()
        }

        guard error == nil else {
            return
        }

        guard let data = data else {
            return
        }

        if let response = response {
            let nsHTTPResponse = response as! HTTPURLResponse
            let statusCode = nsHTTPResponse.statusCode
            responseStatusCode = statusCode
        }

        do {
            //create json object from data
            if let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any] {
                // print(json)
                // handle json...
            }
        } catch let error {
            print(error.localizedDescription)
        }
    })

    // run the async POST request
    task.resume()

    // optimize maybe write not blocking code or show a message or loader to inform user
    // https://github.com/hirokimu/EMTLoadingIndicator
    sem.wait()
    return responseStatusCode
}