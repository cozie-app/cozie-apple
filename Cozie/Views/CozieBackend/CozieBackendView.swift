//
//  CozieBackendView.swift
//  Cozie
//
//  Created by Denis on 13.02.2023.
//

import SwiftUI

struct CozieBackendView: View {
    @StateObject var viewModel = BackendViewModel(storage: CozieStorage.shared)
    @EnvironmentObject var coordinator: HomeCoordinator
    
    // MARK: States
    @State var isSelected: Bool = false
    @State var showError = false
    @State var disabled: Bool = false
    
    let updateTrigger = NotificationCenter.default.publisher(for: HomeCoordinator.didReceiveDeeplink)
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Spacer()
                        .frame(height: 1)
                    List {
                        ForEach($viewModel.section) { sectionData in
                            switch sectionData.id {
                            case BackendViewModel.BackendSectionType.surveys.rawValue:
                                backendSection(title: "Surveys", sectionData.list.wrappedValue, true)
                            case BackendViewModel.BackendSectionType.data.rawValue:
                                backendSection(title: "Data", sectionData.list.wrappedValue)
                            default:
                                backendSection(title: "Backend", sectionData.list.wrappedValue)
                            }
                        }
                        
                    }
                    .padding([.leading, .trailing], -5)
                    .headerProminence(.increased)
                    .listStyle(.insetGrouped)
                    Spacer()
                        .frame(height: 1)
                }
                
                if viewModel.showingState != .clear {
                    didSelectCell(itemID: viewModel.showingState.rawValue)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                CozieToolbarContent(title: "Cozie - Advanced")
            })
            .background(Color.appBackground)
            .onAppear{
                //??? Global
                viewModel.appDelegate = coordinator.appDelegate
                //
                viewModel.prepareData { progress in
                    coordinator.disableUI = progress
                }
            }
            .alert(viewModel.errorString, isPresented: $showError) {
                Button("OK", role: .cancel) { }
            }
            .onReceive(updateTrigger) { _ in
                viewModel.prepareData(active: nil)
            }
        }
    }
    
    // MARK: Did Selected
    func didSelectCell(itemID: Int) -> some View {
        let selectedItems = viewModel.section
            .flatMap{ $0.list }
            .filter{ $0.id == itemID }.first
        
        guard let item = selectedItems else {
            return TextFieldPopUp(title: "", text: "") {
                viewModel.showingState = .clear
            } setAction: { text in
                viewModel.showingState = .clear
            }
        }

        return TextFieldPopUp(title: item.title, text: item.subtitle) {
            viewModel.showingState = .clear
        } setAction: { text in
            item.subtitle = text
            viewModel.updateValue(state: BackendViewModel.BackendState(rawValue: itemID) ?? .clear, value: text)
            viewModel.showingState = .clear
        }
    }
    
    func backendSection(title: String, _ list: [BackendData], _ syncHeader: Bool = false) -> some View {
        Section(content: {
            ForEach(list,
                    id: \.id) { data in
                Button {
                    
                    viewModel.showingState = BackendViewModel.BackendState(rawValue: data.id) ?? .clear
                } label: {
                    BackendCell(title: data.title, subtitle: data.subtitle)
                }
            }
        },
                header: {
            if syncHeader {
                CozieAnimatedSyncHeader(title: title, action: {
                    viewModel.loadWatchSurveyJSON { success in
                        showError = !success
                        if success {
                            viewModel.syncWatchData()
                        }
                    }
                }, animated: $viewModel.loading)
            } else {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
                    .textCase(nil)
            }
        })
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
