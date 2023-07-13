//
//  ThankYouView.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import SwiftUI

struct ThankYouView: View {
    @EnvironmentObject var viewModel: WatchSurveyViewModel
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Thank you.")
                .font(.subheadline)
            Text("Please close the survey by pressing the watch crown.")
                .multilineTextAlignment(.center)
                .font(.caption2)
            Image(systemName: "digitalcrown.press.fill")
                .font(.system(size: 25))
            Button {
                viewModel.backAction()
            } label: {
                Text("Back")
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillEnterForegroundNotification)) { _ in
            viewModel.restart()
        }
        .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationDidEnterBackgroundNotification)) { _ in
            viewModel.sendWatchSurvey()
        }
    }
}

struct ThankYouView_Previews: PreviewProvider {
    static var previews: some View {
        ThankYouView()
    }
}
