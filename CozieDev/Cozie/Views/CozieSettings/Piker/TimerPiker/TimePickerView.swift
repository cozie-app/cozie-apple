//
//  TimePickerView.swift
//  Cozie
//
//  Created by Denis on 16.03.2023.
//

import SwiftUI

struct TimePickerView: View {
    let title: String
    let data: ClosedRange<Int>
    var stepInterval: Int = 1
    @Binding var selection: Int
    
    var body: some View {
        ZStack {
            Picker(title,
                   selection: $selection) {
                ForEach(Array(stride(from: 0,
                               to: data.upperBound,
                               by: stepInterval)),
                        id: \.self) { timeIncrement in
                    Text("\(timeIncrement)")
                }
            }.pickerStyle(.inline)
            Text(title).padding(.leading, 100)
        }.ignoresSafeArea(.all)
    }
}

struct TimePickerView_Previews: PreviewProvider {
    @State static var selection: Int = 0

    static var previews: some View {
        TimePickerView(title: "hours", data: 0...60, selection: $selection)
    }
}
