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
        GeometryReader { render in
            ZStack {
                VStack {
                    Text("Thank you.")
                        .multilineTextAlignment(.center)
                        .padding([.leading, .trailing], 8)
                    
                    Spacer()
                    HStack {
                        Button {
                            viewModel.sendWatchSurvey()
                        } label: {
                            HStack {
                                Image("send_green")
                                    .resizable()
                                    .frame(width: 28,height: 28)
                                Text("Submit survey")
                            }
                            .frame(width: render.size.width, height: UICommon.buttonHeight)
                            .background {
                                RoundedRectangle(cornerRadius: UICommon.cornerRadius)
                                    .foregroundColor(UICommon.buttonColor)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    
                    Spacer()
                    HStack {
                        Button {
                            viewModel.backAction()
                        } label: {
                            Text("Back")
                                .frame(width: render.size.width/2-UICommon.cornerRadius/2, height: UICommon.buttonHeight)
                                .background {
                                    RoundedRectangle(cornerRadius: UICommon.cornerRadius)
                                        .foregroundColor(UICommon.buttonColor)
                                }
                        }
                        .buttonStyle(.plain)
                        Spacer()
                        Button {
                            viewModel.restart()
                        } label: {
                            Text("Reset")
                                .frame(width: render.size.width/2-UICommon.cornerRadius/2, height: UICommon.buttonHeight)
                                .background {
                                    RoundedRectangle(cornerRadius: UICommon.cornerRadius)
                                        .foregroundColor(UICommon.buttonColor)
                                }
                        }
                        .buttonStyle(.plain)
                    }
                }
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
