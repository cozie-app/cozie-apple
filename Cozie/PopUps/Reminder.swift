//
//  Reminder.swift
//  Cozie
//
//  Created by MAC on 21/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

class Reminder: UIViewController {

    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    @IBOutlet weak var img4: UIImageView!
    @IBOutlet weak var labelEligibility: UILabel!
    @IBOutlet weak var labelConsent: UILabel!
    @IBOutlet weak var labelSurvey: UILabel!
    @IBOutlet weak var labelOnBording: UILabel!
    var reminder:[Bool] = [false,false,false,false]
    var images:[UIImageView] = []
    var labels:[UILabel] = []
    override func viewDidLoad() {
        super.viewDidLoad()
        self.fillUpData()
    }
    
    private func fillUpData(){
        images = [img1,img2,img3,img4]
        labels = [labelEligibility, labelConsent, labelSurvey, labelOnBording]
        //get reminder data from user defaults
        //reminder = UserDefaults.shared.getValue(for: UserDefaults.UserDefaultKeys)
        
        for i in 0...3{
            switch reminder[i] {
            case true:
                //images[i].image = UIImage(named: <#T##String#>)
                images[i].layer.borderWidth = 0
                labels[i].textColor = .lightGray
            case false:
                images[i].layer.borderWidth = 2
                images[i].layer.borderColor = UIColor.red.cgColor
            }
        }
    }

}
