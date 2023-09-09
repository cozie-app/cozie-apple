//
//  DataViewRow.swift
//  Cozie
//
//  Created by Denis on 10.02.2023.
//

import SwiftUI

struct WatchSurveyInfo {
    
    enum State {
        case local, remote
    }
    
    let title: String
    let subtitle: String
    let state: State
    
    static func generateRandomData() -> WatchSurveyInfo {
        let info = WatchSurveyInfo(title: "Valid Survey Count",
                                   subtitle: "45 / 100",
                                   state: .remote)
        return info
    }
}

struct WatchSurveyRow: View {
    let info: WatchSurveyInfo
    
    var body: some View {
        VStack() {
            //Spacer()
            HStack {
                Text(info.title)
                    .font(.callout)
                    .padding(.leading, -10)
                Spacer()
                Text(info.subtitle)
                    .font(.custom("OpenSans-Regular",
                                  size: 16))
                Image(systemName: "cloud")
                    .foregroundColor(info.state == .local ? Color.gray : Color("CozieOrange"))
                    .padding(.trailing, -10)
            }.padding(.leading)
            //Spacer()
        }.padding([.top, .bottom], 1)
    }
}

extension WatchSurveyRow {

}

struct WatchSurveyRow_Previews: PreviewProvider {
    static var previews: some View {
        WatchSurveyRow(info: WatchSurveyInfo.generateRandomData())
    }
}
