//
//  WatchSurveyList.swift
//  Cozie
//
//  Created by Denis on 30.03.2023.
//

import SwiftUI

struct WatchSurveyList: View {
    let title: String
    @StateObject var viewModel: QuestionViewModel
    var closeAction: ()->()
    var setAction: (_ selectedId: Int)->()
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.9).blur(radius: 10)
            VStack(alignment: .center) {
                List {
                    QuestionHeaderView(title: title, closeAction: closeAction).padding(.bottom, 15)
                    ForEach(viewModel.list, id: \.id) { question in
                        VStack {
                            QuestionCell(title: question.title,
                                         isSelected: question.id == viewModel.selectedId).onTapGesture {
                                viewModel.selectedId = question.id
                                let _ = print("viewModel id: \(viewModel.selectedId)")
                            }
                        }.padding([.top, .bottom], 3)
                    }

                    Button {
                        setAction(viewModel.selectedId)
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

struct WatchSurveyList_Previews: PreviewProvider {
    static var previews: some View {
        WatchSurveyList(title: "Question Flows",
                        viewModel: QuestionViewModel()) {
            //
        } setAction: { list in
            //
        }

    }
}

struct QuestionHeaderView: View {
    let title: String
    var closeAction: ()->()
    
    var body: some View {
        VStack {
            HStack {
                Text(title).font(.title2.bold())
                Spacer()
                Button {
                    closeAction()
                } label: {
                    Image(systemName: "xmark")
                        .padding(.trailing, 10)
                        .foregroundColor(.black)
                }
            }
        }
    }
}


struct QuestionCell: View {
    let title: String
    var isSelected: Bool
    var body: some View {
        HStack {
            if isSelected {
                Image(systemName: "circle.inset.filled")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.appOrange, .gray)
                
            } else {
                Image(systemName: "circle.inset.filled")
                    .symbolRenderingMode(.palette)
                    .foregroundStyle(Color.white, .gray)
            }
            Text(title).font(.title3.bold())
        }
    }
}
