//
//  TimeOutView.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import SwiftUI

struct TimeOutView: View {
    @EnvironmentObject var viewModel: WatchSurveyViewModel
    @ObservedObject var timeOutViewModel = TimeOutViewModel()
    @Environment(\.scenePhase) private var scenePhase
    var body: some View {
        ZStack {
            Color.red
                .ignoresSafeArea()
            VStack(spacing: 8) {
                Text("You cannot submit a watch survey now. Please try again in \(timeOutViewModel.leftTime) \(timeOutViewModel.leftTime > 1 ? "minutes": "minute").")
                    .multilineTextAlignment(.center)
                    .font(.caption2)
                    .padding(.horizontal, 8)
                
                Text("Thank you.")
                    .font(.subheadline)
                
                Image(systemName: "digitalcrown.press.fill")
                    .font(.system(size: 35))
            }
        }
        .onAppear {
            timeOutViewModel.updateLeftTime()
        }
        .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillEnterForegroundNotification)) { _ in
            timeOutViewModel.updateLeftTime()
            
            if timeOutViewModel.leftTime < 0 {
                viewModel.restart()
            }
        }
    }
}

struct TimeOutView_Previews: PreviewProvider {
    static var previews: some View {
        TimeOutView()
    }
}
