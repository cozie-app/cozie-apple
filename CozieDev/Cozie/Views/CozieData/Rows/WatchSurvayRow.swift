//
//  DataViewRow.swift
//  Cozie
//
//  Created by Denis on 10.02.2023.
//

import SwiftUI

struct WatchSurvayInfo {
    
    enum State {
        case local, remote
    }
    
    let title: String
    let subtitle: String
    let state: State
    
    static func generateRandomData() -> WatchSurvayInfo {
        let info = WatchSurvayInfo(title: "Valid Survey Count",
                                   subtitle: "45 / 100",
                                   state: .remote)
        return info
    }
}

struct WatchSurvayRow: View {
    let info: WatchSurvayInfo
    
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

extension WatchSurvayRow {

}

struct WatchSurvayRow_Previews: PreviewProvider {
    static var previews: some View {
        WatchSurvayRow(info: WatchSurvayInfo.generateRandomData())
    }
}
