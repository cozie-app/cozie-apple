//
//  SettingWatchCell.swift
//  Cozie
//
//  Created by Denis on 15.03.2023.
//

import SwiftUI

struct SettingWatchCell: View {
    let title: String
    let subtitle: String
    let isActive: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
//                .padding(.leading, 10)
            Spacer()
            Text(subtitle).font(.subheadline).lineLimit(1)
            Image(systemName: "applewatch")
                .padding(.trailing, -10)
                .foregroundColor(isActive ? .orange : .gray)
        }
    }
}

struct SettingWatchCell_Previews: PreviewProvider {
    static var previews: some View {
        SettingWatchCell(title: "Participant ID",
                         subtitle: "Participant_Ge9VxH5iP",
                         isActive: true)
    }
}
