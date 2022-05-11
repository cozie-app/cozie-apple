//
//  StartViewController.swift
//  Cozie
//
//  Created by Federico Tartarini on 13/7/20.
//  Copyright © 2020 Federico Tartarini. All rights reserved.
//

import UIKit
import AVKit

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

        let homeViewController = storyboard?.instantiateViewController(identifier: ViewControllersNames.Storyboard.homeViewController)
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }

    override func viewWillAppear(_ animated: Bool) {
    }

}
