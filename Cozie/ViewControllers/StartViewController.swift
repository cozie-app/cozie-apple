//
//  StartViewController.swift
//  Cozie
//
//  Created by Federico Tartarini on 13/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import AVKit
import FirebaseAuth

class StartViewController: UIViewController {

    // to show the video
    var videoPlayer: AVPlayer?
    var videoPlayerLayer: AVPlayerLayer?

    // two buttons in the start page
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // I put the code in the View did appear otherwise it was not working in the viewDidLoad
    override func viewDidAppear(_ animated: Bool) {
        
        // Check if the user has already logged in.
//        if Auth.auth().currentUser == nil {
//
//            setUpVideo()
//            styleButtons()
//
//        } else {
            let homeViewController = storyboard?.instantiateViewController(identifier: ViewControllersNames.Storyboard.homeViewController)
            view.window?.rootViewController = homeViewController
            view.window?.makeKeyAndVisible()
//        }
    }

    override func viewWillAppear(_ animated: Bool) {
    }

    func styleButtons() {

        Utilities.stylePrimaryButton(signUpButton)
        Utilities.styleSecondaryButton(loginButton)

    }

    func setUpVideo() {

        let bundlePathVideo = Bundle.main.path(forResource: "login-video", ofType: "mov")

        guard bundlePathVideo != nil else {
            return
        }

        let url = URL(fileURLWithPath: bundlePathVideo!)

        let item = AVPlayerItem(url: url)

        videoPlayer = AVPlayer(playerItem: item)

        videoPlayerLayer = AVPlayerLayer(player: videoPlayer)

        videoPlayerLayer?.frame = CGRect(x: -self.view.frame.size.width * 1.5,
                y: 0,
                width: self.view.frame.size.width * 4,
                height: self.view.frame.size.height)
        view.layer.insertSublayer(videoPlayerLayer!, at: 0)

        videoPlayer?.playImmediately(atRate: 0.5)

    }

}
