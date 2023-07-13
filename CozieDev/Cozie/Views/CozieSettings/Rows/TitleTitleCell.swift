//
//  TitleTitleCell.swift
//  Cozie
//
//  Created by Denis on 24.03.2023.
//

import SwiftUI

struct TitleTitleCell: View {
    @State var date: Date = Date()
    var body: some View {
        HStack {
            Text("Hello, World!")
            Spacer()
            DatePicker("", selection: $date, displayedComponents: .hourAndMinute).pickerStyle(.inline)
        }
    }
}

struct TitleTitleCell_Previews: PreviewProvider {
    static var previews: some View {
        TitleTitleCell()
    }
}
