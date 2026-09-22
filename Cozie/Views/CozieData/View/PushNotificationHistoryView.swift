//
//  PushNotificationHistoryView.swift
//  Cozie
//
//  Created by Lingting on 22/9/2026.
//

import SwiftUI

struct PushNotificationHistoryView: View {

    @State var history: [PushNotificationHistory]
    let closeAction: () -> Void

    var body: some View {
        ZStack {
            Color.white.opacity(0.9)
                .blur(radius: 10)

            VStack {
                HStack {
                    Spacer()

                    Text("Notification History")
                        .font(.title2.bold())

                    Spacer()

                    Button {
                        closeAction()
                    } label: {
                        Image(systemName: "xmark")
                            .padding(.trailing, 10)
                            .foregroundColor(.black)
                    }
                }
                .padding([.leading, .trailing], 10)
                .padding(.bottom, 20)

                if history.isEmpty {
                    Spacer()

                    Text("No notification history")
                        .foregroundColor(.gray)

                    Spacer()
                } else {
                    List(history) { item in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(item.title)
                                .font(.headline)

                            if !item.subtitle.isEmpty {
                                Text(item.subtitle)
                                    .font(.subheadline)
                            }

                            Text(item.body)
                                .font(.body)

                            Text(item.receivedAt.formatted(date: .abbreviated,
                                                           time: .shortened))
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 6)
                        .swipeActions {
                            Button(role: .destructive) {
                                PushNotificationHistoryRepository().delete(item)
                                history.removeAll { $0.id == item.id }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                    .listStyle(.plain)
                }
            }
            .background(.white)
        }
    }
}
