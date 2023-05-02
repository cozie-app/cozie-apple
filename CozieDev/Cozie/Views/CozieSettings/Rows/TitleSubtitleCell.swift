//
//  CozieTitleSubtitleRow.swift
//  Cozie
//
//  Created by Denis on 13.02.2023.
//

import SwiftUI

struct TitleSubtitleCell: View {
    let title: String
    let subtitle: String
    var body: some View {
        HStack {
            Text(title)
                .font(.callout)
            Spacer()
            Text(subtitle).font(.callout)
        }//.padding(10)
    }
}

struct TitleSubtitleCell_Previews: PreviewProvider {
//    @State static var subtitle: String = "100"
    static var previews: some View {
        TitleSubtitleCell(title: "Watch survay", subtitle: "100")
    }
}
