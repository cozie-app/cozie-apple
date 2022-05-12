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
