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
            Text("Please press the sync button in the Cozie app.")
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 8)
                .onAppear {
                    viewModel.prepare()
                }
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
