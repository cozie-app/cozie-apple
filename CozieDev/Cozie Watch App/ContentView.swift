//
//  ContentView.swift
//  Cozie Watch Watch App
//
//  Created by Alexandr Chmal on 17.04.23.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @StateObject var viewModel = WatchSurveyViewModel()
    var body: some View {
        switch viewModel.state {
        case .notsynced:
            VStack {
                Text("Please press the sync button in the Settings tab of the Cozie phone app.")
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], 8)
                    .onAppear {
                        viewModel.prepare()
                    }
                Image(systemName: "arrow.triangle.2.circlepath")
                    .font(.system(size: 35))
                    .padding(.top, 6)
            }
        case .sendData:
            SendSurveyView()
                .environmentObject(viewModel)
        case .synced:
           QuestionsView()
                .environmentObject(viewModel)
//        case .timeout:
//            TimeOutView()
//                .environmentObject(viewModel)
        case .finished:
            ThankYouView()
                .environmentObject(viewModel)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
