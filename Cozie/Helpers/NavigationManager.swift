//
//  NavigationManager.swift
//  Cozie
//
//  Created by Square Infosoft on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

final class NavigationManager {
    
    static func openNotificationFrequency(_ sender: UIViewController, for type: NotificationFrequency.TimePickerType) {
        let nib = UINib(nibName: "NotificationFrequency", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! NotificationFrequency
        myCustomView.viewType = type
        myCustomView.setupFilledData()
        sender.addChild(myCustomView)
        myCustomView.view.frame = sender.view.bounds
        sender.view.addSubview(myCustomView.view)
        myCustomView.didMove(toParent: sender)
    }
    
    static func openParticipationDays(_ sender: UIViewController) {
        let nib = UINib(nibName: "ParticipationDays", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! ParticipationDays
        sender.addChild(myCustomView)
        myCustomView.view.frame = sender.view.bounds
        sender.view.addSubview(myCustomView.view)
        myCustomView.didMove(toParent: sender)
    }
    
    static func openDailyParticipation(_ sender: UIViewController) {
        let nib = UINib(nibName: "DailyParticipation", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! DailyParticipation
        sender.addChild(myCustomView)
        myCustomView.view.frame = sender.view.bounds
        sender.view.addSubview(myCustomView.view)
        myCustomView.didMove(toParent: sender)
    }
    
    static func openQuestionFlow(_ sender: UIViewController) {
        let nib = UINib(nibName: "QuestionFlow", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! QuestionFlow
        sender.addChild(myCustomView)
        myCustomView.view.frame = sender.view.bounds
        sender.view.addSubview(myCustomView.view)
        myCustomView.didMove(toParent: sender)
    }
    
    static func openTextView(_ sender: UIViewController, isParticipantID: Bool) {
        let nib = UINib(nibName: "TextView", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! TextView
        myCustomView.isParticipantID = isParticipantID
        myCustomView.fillUpData()
        sender.addChild(myCustomView)
        myCustomView.view.frame = sender.view.bounds
        sender.view.addSubview(myCustomView.view)
        myCustomView.didMove(toParent: sender)
    }
    
    static func openPermissions(_ sender: UIViewController) {
        let nib = UINib(nibName: "Permissions", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! Permissions
        sender.addChild(myCustomView)
        myCustomView.view.frame = sender.view.bounds
        sender.view.addSubview(myCustomView.view)
        myCustomView.didMove(toParent: sender)
    }
    
    static func dismiss(_ sender: UIViewController) {
        sender.view.removeFromSuperview()
        sender.removeFromParent()
    }
}
