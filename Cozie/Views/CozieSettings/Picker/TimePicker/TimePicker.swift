//
//  TimePicker.swift
//  Cozie
//
//  Created by Denis on 16.03.2023.
//

import SwiftUI

struct TimePicker: View {
    
    let title: String
    let subtitle: String
    
    @State var selectedHour: Int = 0
    @State var selectedMinutes: Int = 0
    @State var stepInterval: Int = 1
    @StateObject var viewModel = TimePickerViewModel()


    var closeAction: ()->()
    var setAction: (_ hour: Int, _ minutes: Int) -> ()
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.opacity(0.9).blur(radius: 10)
                VStack(spacing: 6) {
                    TimePickerHeader(title: title,
                                     subtitle: subtitle,
                                     closeAction: closeAction)
                    .padding([.leading, .trailing], 8)
                    HStack(alignment: .center, spacing: 0) {
                        TimePickerView(title: "hours",
                                       data: viewModel.hourRange,
                                       selection: $selectedHour)
                        .frame(width: geometry.size.width/2 - 8, height: 160)
                        .clipped()
                        
                        TimePickerView(title: "min",
                                       data: viewModel.minutesRange,
                                       stepInterval: stepInterval,
                                       selection: $selectedMinutes)
                        .frame(width: geometry.size.width/2 - 8, height: 160)
                        .clipped()
                    }
                    .frame(width: geometry.size.width)
                    //.padding([.leading, .trailing], 8)
                    
                    Button {
                        setAction(selectedHour, selectedMinutes)
                    } label: {
                        SetButtonLabel()
                    }
                    //.padding(.top, 8)
                    
                }
                .padding([.top, .bottom], 8)
                .background(.white)
            }
        }
    }
}

struct TimePicker_Previews: PreviewProvider {
    static var previews: some View {
        TimePicker(title: "Reminder Frequency",
                    subtitle: "Notify me every...") {
            print("closeAction")
        } setAction: { hour, minutes in
            print("set action")
        }
    }
}

struct TimePickerHeader: View {
    var title: String
    var subtitle: String
    var closeAction: () -> ()
    private let buttonTapArea: CGFloat = 40
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .font(.title3).bold()
                    .foregroundColor(.black)
                    .padding(.leading, 10)
                Spacer()

                Button {
                    closeAction()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundColor(.black)
                }
                .frame(width: 40)
            }
            HStack {
                Text(subtitle)
                Spacer()
            }.padding([.leading, .trailing], 10)
        }
    }
}
