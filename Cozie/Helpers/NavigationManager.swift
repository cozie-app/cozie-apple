//
//  NavigationManager.swift
//  Cozie
//
//  Created by Square Infosoft on 17/12/21.
//  Copyright © 2021 Federico Tartarini. All rights reserved.
//

import UIKit

final class NavigationManager {
    
    static func openNotificationFrequency(_ sender: UIViewController, for type: NotificationFrequency.TimePickerType, view: UIViewController, isForSubview:Bool = false) {
        let nib = UINib(nibName: "NotificationFrequency", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! NotificationFrequency
        myCustomView.viewType = type
        myCustomView.delegate = view as? timeSetDelegate
        myCustomView.setupFilledData()
        myCustomView.isForSubview = isForSubview
        if isForSubview {
            sender.addChild(myCustomView)
            myCustomView.view.frame = sender.view.bounds
            sender.view.addSubview(myCustomView.view)
            myCustomView.didMove(toParent: sender)
        } else {
            myCustomView.modalPresentationStyle = .overFullScreen
            sender.present(myCustomView, animated: true, completion: nil)
        }
    }
    
    static func openParticipationDays(_ sender: UIViewController) {
        let nib = UINib(nibName: "ParticipationDays", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! ParticipationDays
        myCustomView.modalPresentationStyle = .overFullScreen
        sender.present(myCustomView, animated: true, completion: nil)
    }
    
    static func openWeeklySurvey(_ sender: UIViewController){
        let nib = UINib(nibName: "WeeklySurvey", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! WeeklySurvey
        myCustomView.modalPresentationStyle = .overFullScreen
        sender.present(myCustomView, animated: true, completion: nil)
    }
    
    static func openDailyParticipation(_ sender: UIViewController) {
        let nib = UINib(nibName: "DailyParticipation", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! DailyParticipation
        myCustomView.delegate = sender as? TimePickerDelegate
        myCustomView.modalPresentationStyle = .overFullScreen
        sender.present(myCustomView, animated: true, completion: nil)
    }
    
    static func openQuestionFlow(_ sender: UIViewController) {
        let nib = UINib(nibName: "QuestionFlow", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! QuestionFlow
        myCustomView.modalPresentationStyle = .overFullScreen
        sender.present(myCustomView, animated: true, completion: nil)
    }
    
    static func openTextView(_ sender: UIViewController, isParticipantID: Bool) {
        let nib = UINib(nibName: "TextView", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! TextView
        myCustomView.isParticipantID = isParticipantID
        myCustomView.fillUpData()
        myCustomView.modalPresentationStyle = .overFullScreen
        sender.present(myCustomView, animated: true, completion: nil)
    }
    
    static func openPermissions(_ sender: UIViewController) {
        let nib = UINib(nibName: "Permissions", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! Permissions
        myCustomView.modalPresentationStyle = .overFullScreen
        sender.present(myCustomView, animated: true, completion: nil)
    }
    
    static func openReminder(_ sender: UIViewController) {
        let nib = UINib(nibName: "Reminder", bundle: nil)
        let myCustomView = nib.instantiate(withOwner: sender, options: nil).first as! Reminder
        myCustomView.modalPresentationStyle = .overFullScreen
        sender.present(myCustomView, animated: true, completion: nil)
    }
    
    static func dismiss(_ sender: UIViewController, isForSubview:Bool = false) {
        if isForSubview {
            sender.view.removeFromSuperview()
            sender.removeFromParent()
        } else {
            sender.dismiss(animated: true, completion: nil)            
        }
    }
}
