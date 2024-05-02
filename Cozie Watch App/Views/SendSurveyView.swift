//
//  SendSurveyView.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 08.05.23.
//

import SwiftUI

struct SendSurveyView: View {
    @EnvironmentObject var viewModel: WatchSurveyViewModel
    @State var sendingProgress = false
    var body: some View {
        ZStack {
            VStack {
                Text("Thank you.")
                    .multilineTextAlignment(.center)
                    .padding([.leading, .trailing], 8)
                
                Spacer()
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 0.15))
                        
                        HStack {
                            Image("send_green")
                                .resizable()
                                .frame(width: 28,height: 28)
                            Text("Submit survey")
                        }
                    }
                    .onTapGesture {
                        viewModel.sendWatchSurvey()
                    }
                }
                .frame(height: 45)
                
                Spacer()
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 0.15))
                        
                        Text("Back")
                        
                    }
                    .onTapGesture {
                        viewModel.backAction()
                    }
                    Spacer()
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .foregroundColor(Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 0.15))
                        
                        Text("Reset")
                        
                    }
                    .onTapGesture {
                        viewModel.restart()
                    }
                }
                .frame(height: 45)
            }
            
            if viewModel.sendSurveyProgress {
                ProgressView()
            }
            
        }
        
    }
}

struct SendSurveyView_Previews: PreviewProvider {
    static var previews: some View {
        SendSurveyView()
    }
}
