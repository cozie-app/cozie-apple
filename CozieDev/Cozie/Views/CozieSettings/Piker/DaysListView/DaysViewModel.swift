//
//  DaysViewModel.swift
//  Cozie
//
//  Created by Denis on 20.03.2023.
//

import Foundation

enum DayIndex {
    case sunday, monday, tuesday, wednesday, thursday, friday, saturday
    
    func string() -> String {
        switch self {
        case .sunday:
            return "Sunday"
        case .monday:
            return "Monday"
        case .tuesday:
            return "Tuesday"
        case .wednesday:
            return "Wednesday"
        case .thursday:
            return "Thursday"
        case .friday:
            return "Friday"
        case .saturday:
            return "Saturday"
        }
    }
}

class DayModel: Identifiable, ObservableObject {
    let id: Int
    let title: DayIndex
    @Published var isSelected: Bool = false
    
    init(id: Int, title: DayIndex, isSelected: Bool) {
        self.id = id
        self.title = title
        self.isSelected = isSelected
    }
    
    func titleShort() -> String {
        return String(title.string().prefix(2))
    }
    
    func dayIndex() -> Int {
        switch title {
        case .sunday:
            return 1
        case .monday:
            return 2
        case .tuesday:
            return 3
        case .wednesday:
            return 4
        case .thursday:
            return 5
        case .friday:
            return 6
        case .saturday:
            return 7
        }
    }
}

class DaysViewModel: ObservableObject {
    @Published var list: [DayModel] = [DayModel(id: 1, title: .monday, isSelected: false),
                                       DayModel(id: 2, title: .tuesday, isSelected:  false),
                                       DayModel(id: 3, title: .wednesday, isSelected:  false),
                                       DayModel(id: 4, title: .thursday, isSelected:  false),
                                       DayModel(id: 5, title: .friday, isSelected:  false),
                                       DayModel(id: 6, title: .saturday, isSelected:  false),
                                       DayModel(id: 7, title: .sunday, isSelected:  false)]
}
