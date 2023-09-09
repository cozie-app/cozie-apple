//
//  NotificationView.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 03.05.23.
//

import SwiftUI

struct NotificationView: View {
    let message: String
    
    var body: some View {
        VStack {
            HStack {
                Text(message)
                    .font(.caption)
                Spacer()
            }
        }
    }
}

struct NotificationView_Previews: PreviewProvider {
    static var previews: some View {
        NotificationView(message: "Some Text, Some Text, Some Text, Some Text, Some Text, Some Text, long long Some Text")
    }
}
