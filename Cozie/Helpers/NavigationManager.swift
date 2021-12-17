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
        let vc = NotificationFrequency(nibName: "NotificationFrequency", bundle: nil)
        vc.viewType = type
        sender.present(vc, animated: true, completion: nil)
    }
    
    static func openParticipationDays(_ sender: UIViewController) {
        let vc = ParticipationDays(nibName: "ParticipationDays", bundle: nil)
        sender.present(vc, animated: true, completion: nil)
    }
}
