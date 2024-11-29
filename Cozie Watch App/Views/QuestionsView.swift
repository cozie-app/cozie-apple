//
//  QuestionsView.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import SwiftUI

struct QuestionsView: View {
    @EnvironmentObject var viewModel: WatchSurveyViewModel
    @State private var sensoryFeedback: Int = 0
    let questionTopInset: CGFloat = 16
    let buttonColor = Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 0.20)
    let selectedButtonColor = Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 0.12)
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                //
                Rectangle()
                    .foregroundStyle(.clear) // 
                    .frame(height: geometry.safeAreaInsets.top - questionTopInset)
                    .ignoresSafeArea()
                    .zIndex(1)
                //
                ScrollViewReader { reader in
                    ScrollView {
                        Text(.init(viewModel.questionsTitle))  // render markdown using .init()
                            .multilineTextAlignment(.center)
                            .padding([.leading, .trailing], 8)
                            // ScrollView needs an id for questionTitel to scroll
                            .id(viewModel.questionID)
                        
                        ForEach(viewModel.questionsList, id: \.id) { option in
                            HStack {
                                ZStack {
                                    if option.icon != "" {
                                        // Only show background if icon name string is not empty
                                        Image(systemName: "circle.fill")
                                            .resizable()
                                            .frame(width: 35, height: 35)
                                            .foregroundColor(Color(hex: option.iconBackgroundColor))
                                    }
                                    if option.useSfSymbols {
                                        if UIImage(systemName: option.icon) == nil {
                                            Image(systemName: "photo.circle")
                                                .resizable()
                                                .frame(width: 35,height: 35)
                                                .foregroundColor(.black)
                                        } else {
                                            Image(systemName: option.icon)
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width:25, height: 25)
                                                .foregroundColor(Color(hex: option.sfSymbolsColor))
                                        }
                                    } else {
                                        if UIImage(named: option.icon) == nil {
                                            // Show default icon
                                            //Image(systemName: "photo.circle")
                                            //    .resizable()
                                            //    .frame(width: 35,height: 35)
                                            //    .foregroundColor(.black)
                                        } else {
                                            Image(option.icon)
                                                .resizable()
                                                .frame(width: 35,height: 35)
                                        }
                                    }
                                }
                                ZStack {
                
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(viewModel.isOptinSelected(option: option) ? selectedButtonColor : buttonColor)
                                    HStack {
                                        Text(.init(option.text))  // render markdown using .init()
                                            .foregroundColor(viewModel.isOptinSelected(option: option) ? Color.gray: Color.white)
                                            .padding(.leading, 8)
                                        Spacer()
                                    }
                                    .padding(4)
                                }
                            }
                            .frame(minHeight: 45)
                            .padding(.vertical, 1)
                            .onTapGesture {
                                viewModel.selectOptions(option: option)
                                scrollToTopAnimation(reader: reader, animation: true)
                            }
                        }
                        
                        if !viewModel.isFirstQuestion {
                            VStack {
                                HStack {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(buttonColor)
                                        
                                        Text("Back")
                                        
                                    }
                                    .onTapGesture {
                                        viewModel.backAction()
                                        scrollToTopAnimation(reader: reader, animation: true)
                                    }
                                    Spacer()
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 8)
                                            .foregroundColor(buttonColor)
                                        
                                        Text("Reset")
                                        
                                    }
                                    .onTapGesture {
                                        viewModel.restart()
                                        scrollToTopAnimation(reader: reader, animation: true)
                                    }
                                }
                            }
                            .frame(height: 45)
                            .padding(.vertical, 3)
                        }
                        
                    }
                    
                    
                }
                //.animation(.easeIn)
                .foregroundColor(.white)
                .onReceive(NotificationCenter.default.publisher(for: WKExtension.applicationWillEnterForegroundNotification)) { _ in
                    viewModel.restart()
                }
                
            }
            .ignoresSafeArea(edges: .top)
            .onAppear {
                viewModel.prepareLocationAndConnectivityManager()
            }
        }
    }
    
    func scrollToTopAnimation(reader: ScrollViewProxy?, animation: Bool) {
        reader?.scrollTo(viewModel.questionID, anchor: .top)
        // remove scroll animation to question in watch app
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
//            withAnimation {
//                reader?.scrollTo(viewModel.questionID, anchor: .top)
//            }
//        }
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsView()
            .environmentObject(WatchSurveyViewModel()/*WatchSurveyViewModel.test*/)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
