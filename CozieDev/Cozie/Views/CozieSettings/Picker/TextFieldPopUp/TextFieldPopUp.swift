//
//  TestFieldPopUp.swift
//  Cozie
//
//  Created by Denis on 24.03.2023.
//

import SwiftUI

struct TextFieldPopUp: View {
    var title: String = ""
    var subtitle: String = ""
    var text: String

    var closeAction: () -> Void
    var setAction: (String) -> Void
    
    @State private var editText: String = ""

    init(title: String = "",
         subtitle: String = "",
         text: String,
         closeAction: @escaping () -> Void,
         setAction: @escaping (String) -> Void) {
        self.title = title
        self.subtitle = subtitle
        self.text = text
        self.closeAction = closeAction
        self.setAction = setAction
        self._editText = State(initialValue: text)
    }
    
    
    var body: some View {
        ZStack {
            Color.white.opacity(0.9).blur(radius: 10)
            VStack {
                HStack {
                    Spacer()
                    Text(title).font(.title2.bold())
                    Spacer()
                    Button {
                        closeAction()
                    } label: {
                        Image(systemName: "xmark")
                            .padding(.trailing, 10)
                            .foregroundColor(.black)
                    }
                }.padding([.trailing, .leading], 10)
                    .padding(.bottom, 20)

                Text(subtitle)
                TextField("", text: $editText)
                    .padding()
                    .textFieldStyle(.roundedBorder)
                    .padding(.bottom, 20)
                Button {
                    setAction(editText)
                } label: {
                    SetButtonLabel()
                }
            }.background(.white)
        }
    }
}

struct TextFieldPopUp_Previews: PreviewProvider {
    static var previews: some View {
        TextFieldPopUp(text: "100", closeAction: {
            print("closeAction")
        }, setAction: {_ in 
            print("setAction")
        })
    }
}
