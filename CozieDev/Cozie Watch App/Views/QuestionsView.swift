//
//  QuestionsView.swift
//  Cozie Watch App
//
//  Created by Alexandr Chmal on 20.04.23.
//

import SwiftUI

struct QuestionsView: View {
    @EnvironmentObject var viewModel: WatchSurveyViewModel
    
    var body: some View {
        VStack {
            Text(viewModel.questionsTitle)
                .multilineTextAlignment(.center)
                .padding([.leading, .trailing], 8)
            ScrollViewReader { reader in
                ScrollView {
                    ForEach(viewModel.questionsList, id: \.id) { option in
                        HStack {
                            if option.useSfSymbols {
                                if UIImage(systemName: option.icon) == nil {
                                    Image(systemName: "photo.circle")
                                        .resizable()
                                        .frame(width: 35,height: 35)
                                } else {
                                    Image(systemName: option.icon)
                                        .resizable()
                                        .frame(width: 35,height: 35)
                                        .foregroundColor(Color(hex: option.sfSymbolsColor))
                                }
                            } else {
                                if UIImage(named: option.icon) == nil {
                                    Image(systemName: "photo.circle")
                                        .resizable()
                                        .frame(width: 35,height: 35)
                                        .foregroundColor(.white)
                                } else {
                                    Image(option.icon)
                                        .resizable()
                                        .frame(width: 35,height: 35)
                                }
                            }
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .foregroundColor(Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 0.15))
                                HStack {
                                    Text(option.text)
                                        .foregroundColor(Color.white)
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
                                        .foregroundColor(Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 0.15))
                                    
                                    Text("Back")
                                    
                                }
                                .onTapGesture {
                                    viewModel.backAction()
                                    scrollToTopAnimation(reader: reader, animation: true)
                                }
                                Spacer()
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .foregroundColor(Color(.displayP3, red: 1.0, green: 1.0, blue: 1.0, opacity: 0.15))
                                    
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
        .onAppear {
            viewModel.prepare()
        }
    }
    
    func scrollToTopAnimation(reader: ScrollViewProxy?, animation: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation {
                reader?.scrollTo(viewModel.questionsList.first?.id ?? "", anchor: .top)
            }
        }
    }
}

struct QuestionsView_Previews: PreviewProvider {
    static var previews: some View {
        QuestionsView()
            .environmentObject(WatchSurveyViewModel())
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
