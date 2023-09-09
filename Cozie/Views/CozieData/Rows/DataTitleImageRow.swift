//
//  DataDownloadRow.swift
//  Cozie
//
//  Created by Denis on 13.02.2023.
//

import SwiftUI

struct DataTitleImageRow: View {
    enum ImageType {
        case download, documentations, github
        
        func str() -> String {
            switch self {
            case .download:
                return "tray.and.arrow.down"
            case .documentations:
                return "text.book.closed"
            case .github:
                return "GitImage"
            }
        }
    }
    
    let title: String
    let imageType: ImageType
    var body: some View {
        VStack() {
            Spacer()
            HStack {
                Text(title)
                    .font(.callout)
                    .padding(.leading, 5)
                Spacer()
                if imageType == .github {
                    Image("GitImage")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .padding(.trailing, -15)
                } else {
                    Image(systemName: imageType.str())
                        .resizable()
                        .frame(width: 20, height: 23)
                        .padding(.trailing, -10)
                }
            }
            Spacer()
        }
        .ignoresSafeArea(.all)
    }
}

struct DataTitleImageRow_Previews: PreviewProvider {
    static var previews: some View {
        DataTitleImageRow(title: "Download Data", imageType: .github)
    }
}
