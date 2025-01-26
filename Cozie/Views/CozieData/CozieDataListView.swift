//
//  DataView.swift
//  Cozie
//
//  Created by Denis on 10.02.2023.
//

import SwiftUI

struct CozieDataListView: View {
    
    private let cellHeight: CGFloat = 40
    private let sectionInset: CGFloat = -20
    private let cellInset: CGFloat = 20
    
    @StateObject private var watchSurveyViewModel = WatchSurveyViewModel()
    @Environment(\.openURL) var openURL
    
    @FetchRequest(sortDescriptors: []) var syncInfo: FetchedResults<SyncInfo>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.index)]) var summaryList: FetchedResults<SummaryInfoData>
    @FetchRequest(sortDescriptors: []) var settings: FetchedResults<SettingsData>
    
    // MARK: States
    @State var showError = false
    @State var presentingModal = false
    
    let updateTrigger = NotificationCenter.default.publisher(for: HomeCoordinator.updateNorification)
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                    .frame(height: 1)
                List {
                    Section(content: {
                        if summaryList.count == 0 {
                            WatchSurveyRow(info: WatchSurveyInfo(title: "Valid Survey Count",
                                                                 subtitle: (syncInfo.first?.validCount ?? "0") + "/\(settings.first?.wss_goal ?? 0)",
                                                                 state: watchSurveyViewModel.dataSynced ? .remote : .local))
                            WatchSurveyRow(info: WatchSurveyInfo(title: "Invalid Survey Count",
                                                                 subtitle: syncInfo.first?.invalidCount ?? "0",
                                                                 state: watchSurveyViewModel.dataSynced ? .remote : .local))
                            WatchSurveyRow(info: WatchSurveyInfo(title: "Last Watch Survey",
                                                                 subtitle: syncInfo.first?.date ?? "0",
                                                                 state: watchSurveyViewModel.dataSynced ? .remote : .local))
                        } else {
                            ForEach(summaryList) { summary in
                                WatchSurveyRow(info: WatchSurveyInfo(title: summary.label ?? "",
                                                                     subtitle: summary.data ?? "" ,
                                                                     state: watchSurveyViewModel.dataSynced ? .remote : .local))
                            }
                        }
                    }, header: {
                        CozieAnimatedSyncHeader(title: "Summary", action: {
                            watchSurveyViewModel.updateData(sendHealthData: true) {
                                debugPrint("finish update data!")
                            }
                        }, animated: $watchSurveyViewModel.loading)
                    })
                    
                    Section(content: {
                        DataTitleImageRow(title: "Download",
                                          imageType: .download)
                        .padding(.top, cellInset)
                        .onTapGesture {
                            watchSurveyViewModel.loadData { success in
                                if success {
                                    presentingModal = success
                                } else {
                                    showError = !success
                                }
                            }
                        }
                    }, header: {
                        CozieHeaderView(title: "Download")
                    })
                    .frame(height: cellHeight)
                    .padding(.top, sectionInset)
                    
                    Section(content: {
                        DataTitleImageRow(title: "Cozie Github Repository", imageType: .github).onTapGesture {
                            if let url = URL(string: AppLink.githubRepo.rawValue) {
                                openURL(url)
                            }
                        }.padding(.top, cellInset)
                        DataTitleImageRow(title: "Cozie Documentation", imageType: .documentations).onTapGesture {
                            if let url = URL(string: AppLink.documentation.rawValue) {
                                openURL(url)
                            }
                        }.padding(.top, cellInset)
                    }, header: {
                        CozieHeaderView(title: "About")
                    })
                    .frame(height: cellHeight)
                    .padding(.top, sectionInset)
                }
                .listStyle(.insetGrouped)
                .padding([.leading, .trailing], -5)
                Spacer(minLength: 16)
                HStack {
                    Button {
                        if let urlStr = watchSurveyViewModel.phoneSurveyLink(), let url = URL(string: urlStr) {
                            openURL(url)
                        }
                    } label: {
                        Text("Phone survey")
                            .font(.headline)
                            .padding([.top, .bottom], 20)
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .background(Color("AccentColor"))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .padding([.leading, .trailing], 8)
                }
                .padding(.bottom, 21)
            }
            .background(Color.appBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                CozieToolbarContent(title: "Cozie - Data")
            })
        }
        .background(Color.appBackground)
        .onAppear {
            watchSurveyViewModel.updateData(completion: {})
        }
        .sheet(isPresented: $presentingModal) {
            ActivityView(url: watchSurveyViewModel.fileDataURL!)
        }
        .alert(watchSurveyViewModel.errorString, isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
        .onReceive(updateTrigger) { _ in
            watchSurveyViewModel.updateData(completion: {})
        }
    }
}

struct CozieDataListView_Previews: PreviewProvider {
    static var previews: some View {
        CozieDataListView()
    }
}

struct CozieToolbarContent: ToolbarContent {
    let title: String
    var body: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text(title)
                .font(.headline)
                .foregroundColor(Color("AccentColor"))
        }
    }
}

struct CozieHeaderView: View {
    let title: String
    var body: some View {
        Text(title)
            .font(.headline.bold())
            .foregroundColor(.black)
            .textCase(nil)
    }
}

struct CozieSyncHeader: View {
    let title: String
    var action: () -> Void
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .textCase(nil)
            Spacer()
            Button(action: action,
                   label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .foregroundColor(.black)
                    .padding(.trailing, -15)
            })
        }
    }
}

struct CozieAnimatedSyncHeader: View {
    let title: String
    var action: () -> Void
    @Binding var animated: Bool
    @State var animaiton: Bool = false
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.black)
                .textCase(nil)
            Spacer()
            Button(action: action,
                   label: {
                if animated {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.black)
                        .rotationEffect(Angle.degrees(animaiton ? 360 : 0))
                        .animation(.linear(duration: 0.8)
                            .repeatForever(autoreverses: false), value: animaiton)
                        .padding(.trailing, -15)
                        .onAppear{
                            animaiton = true
                        }
                } else {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .foregroundColor(.black)
                        .padding(.trailing, -15)
                        .onAppear{
                            animaiton = false
                        }
                }
            })
        }
    }
}

// MARK: UIKit Representable
struct ActivityView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityView>) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityView>) {}
}

struct ActivityIndicator: UIViewRepresentable {
    
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}
