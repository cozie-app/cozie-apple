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

    var videoPlayer: AVPlayer?

    var videoPlayerLayer: AVPlayerLayer?

    @IBOutlet weak var signUpButton: UIButton!

    @IBOutlet weak var loginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setUpElements()
    }

    override func viewWillAppear(_ animated: Bool) {
        setUpVideo()
    }

    func setUpElements() {

        Utilties.stylePrimaryButton(signUpButton)
        Utilties.styleSecondaryButton(loginButton)

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
