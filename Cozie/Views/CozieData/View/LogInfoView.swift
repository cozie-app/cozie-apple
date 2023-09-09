//
//  LogInfoView.swift
//  Cozie
//
//  Created by Alexandr Chmal on 17.04.23.
//

import SwiftUI

struct LogInfoView: View {
    let text: String
    
    var body: some View {
        RoundedRectangle(cornerRadius: 5)
            .frame(width:50, height: 5)
            .padding(.top, 6)
        Text("Log history")
            .padding(.top, 8)
            .font(.headline)
            .foregroundColor(Color("AccentColor"))
        Spacer()
            .frame(height: 15)
        ScrollView {
            Text(text)
                .font(.footnote)
                .padding()
        }
        
    }
}

struct LogInfoView_Previews: PreviewProvider {
    static var previews: some View {
        LogInfoView(text: """
New simpler and recommended method: Apple recommends using URLs for filehandling and the other solutions here seem deprecated (see comments below). The following is the new simple way of reading and writing with URL's:
""")
    }
}
