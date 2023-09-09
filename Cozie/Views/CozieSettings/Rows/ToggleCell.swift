//
//  CozieToggleRow.swift
//  Cozie
//
//  Created by Denis on 13.02.2023.
//

import SwiftUI

struct ToggleCell: View {
    let title: String
    @Binding var isOn: Bool
    var body: some View {
        Toggle(isOn: $isOn) {
            Text(title)
                .font(.callout)
                //.padding(.leading, 10)
                .padding([.top, .bottom], 0)
        }.tint(.appOrange)
    }
}

struct ToggleCell_Previews: PreviewProvider {
    @State static var taggleState = false
    static var previews: some View {
        ToggleCell(title: "Enable Reminders",
                   isOn: $taggleState)
    }
}
