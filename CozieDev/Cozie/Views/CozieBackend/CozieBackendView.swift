//
//  CozieBackendView.swift
//  Cozie
//
//  Created by Denis on 13.02.2023.
//

import SwiftUI

struct CozieBackendView: View {
    @StateObject var viewModel = BackendViewModel()
    @EnvironmentObject var settingsViewModel: SettingViewModel
    
    // MARK: States
    @State var isSelected: Bool = false
    @State var showError = false
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                        .frame(height: 1)
                    List {
                        Section(content: {
                            ForEach($viewModel.list,
                                    id: \.id) { $data in
                                Button {
                                    
                                    viewModel.showingState = BackendViewModel.BackendState(rawValue: data.id) ?? .clear
                                } label: {
                                    BackendCell(title: data.title, subtitle: data.subtitle)
                                }
                            }
                        },
                                header: {
                            CozieAnimatedSyncHeader(title: "Backend", action: {
                                viewModel.loadWatchSurveyJSON { success in
                                    showError = !success
                                    if success {
                                        settingsViewModel.updateSurveyList()
                                        viewModel.syncWatchData()
                                    }
                                }
                            }, animated: $viewModel.loading)
                        })
                    }
                    .padding([.leading, .trailing], -5)
                    .headerProminence(.increased)
                    .listStyle(.insetGrouped)
                    Spacer()
                        .frame(height: 1)
                }
                
                if viewModel.showingState != .clear {
                    didSelectCell(index: viewModel.showingState.rawValue)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                CozieToolbarContent(title: "Cozie - Backend")
            })
            .background(Color.appBackground)
            .onAppear{
                viewModel.prepareData()
            }
            .alert(viewModel.errorString, isPresented: $showError) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    // MARK: Did Selected
    func didSelectCell(index: Int) -> some View {
        let title = viewModel.list[index].title
        let text = viewModel.list[index].subtitle
        return TextFieldPopUp(title: title, text: text) {
            viewModel.showingState = .clear
        } setAction: { text in
            viewModel.list[index].subtitle = text
            viewModel.updateValue(state: BackendViewModel.BackendState(rawValue: index) ?? .clear, value: text)
            viewModel.showingState = .clear
        }
    }
}

struct CozieBackendView_Previews: PreviewProvider {
    static var previews: some View {
        CozieBackendView()
    }
}

struct BackendCell: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack {
            Text(title)
                .padding(.trailing, 15)
                .foregroundColor(.black)
                .font(.callout)
            Spacer()
            Text(subtitle).lineLimit(1)
                .foregroundColor(.black)
                .font(.callout)
        }
    }
}
