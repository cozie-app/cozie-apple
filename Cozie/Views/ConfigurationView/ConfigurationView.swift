//
//  ConfigurationView.swift
//  Cozie
//
//  Created by Alexandr Chmal on 11.05.23.
//

import SwiftUI

struct ConfigurationView: View {
    var body: some View {
        VStack {
            Image(systemName: "info.circle")
                .font(.largeTitle)
                .foregroundColor(.appOrange)
                .padding(.top, 50)
            
            Text("Cosie Dev")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top, 20)
            Text("Please open the URL from the invitation email to set up the app.")
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .padding(18)
            Spacer()
        }
    }
}

struct ConfigurationView_Previews: PreviewProvider {
    static var previews: some View {
        ConfigurationView()
    }
}
