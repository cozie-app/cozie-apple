//
//  DaysListView.swift
//  Cozie
//
//  Created by Denis on 17.03.2023.
//

import SwiftUI

struct DaysListView: View {
    @State var list: [DayModel]
    var closeAction: ()->()
    var setAction: ([DayModel])->()

    var body: some View {
        ZStack {
            Color.white.opacity(0.9).blur(radius: 10)
            VStack(alignment: .center) {
                List {
                    PopUpHeaderView(title: "Participation Days",
                                    subtitle: "Days I would like to get notified",
                                    closeAction: closeAction)

                    ForEach($list, id: \.id) { $day in
                        VStack {
                            Toggle(isOn: $day.isSelected) {
                                Text(day.title.string()).font(.title3.bold())
                            }.tint(.appOrange)
                        }.padding([.top, .bottom], 0)
                    }

                    Button {
                        setAction(list)
                    } label: {
                        HStack(alignment: .center) {
                            Spacer()
                            SetButtonLabel()
                            Spacer()
                        }
                    }.buttonStyle(PlainButtonStyle())
                     .padding([.top, .bottom], 20)
                }
                .listStyle(.insetGrouped)
            }
        }
    }
}

struct DaysListView_Previews: PreviewProvider {
    static var previews: some View {
        let viewModel = DaysViewModel()
        DaysListView(list: viewModel.list) {
            print("close button")
        } setAction: { dayList in
            print("set action")

        }
    }
}

struct PopUpHeaderView: View {
    let title: String
    let subtitle: String
    var closeAction: ()->()
    
    var body: some View {
        VStack {
            HStack {
                Text(title)
                Spacer()
                Button {
                    closeAction()
                } label: {
                    Image(systemName: "xmark")
                        .padding(.trailing, 10)
                        .foregroundColor(.black)
                }
            }
            
            HStack {
                Text(subtitle)
                Spacer()
            }
        }
    }
}

struct SetButtonLabel: View {
    var body: some View {
        Text("SET")
            .font(.title2.bold())
            .padding(.all, 10)
            .padding([.leading, .trailing], 40)
            .background(Color("ButtonGreen"))
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
