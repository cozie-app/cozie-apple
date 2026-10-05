//
//  Untitled.swift
//  Cozie
//
//

import SwiftUI
import Combine

struct PauseSettingsSection: View {
    @ObservedObject var pauseService: PauseService

    @State private var pauseReason = ""
    @State private var startNow = true
    @State private var pauseStartDate = Date()
    @State private var pauseEndDate = Date().addingTimeInterval(3600)
    @State private var currentTime = Date()

    @State private var errorMessage = ""
    @State private var showError = false

    private var pauseStatus: PauseStatus {
        pauseService.status(at: currentTime)
    }

    var body: some View {
        Section {
            
            HStack {
                Text("Status")

                Spacer()

                Text(
                    pauseStatus == .active ? "Active" :
                    pauseStatus == .scheduled ? "Scheduled" :
                    "No Pause"
                )
                .fontWeight(.semibold)
                .foregroundStyle(
                    pauseStatus == .active ? Color.red :
                    pauseStatus == .scheduled ? Color.green :
                    Color.secondary
                )
            }
            
            switch pauseStatus {
            case .noPause:
                EmptyView()

            case .scheduled:
                if let plan = pauseService.plan {
                    Text("Starts at \(plan.startDate.formatted())")
                }

                Button("Cancel", role: .destructive) {
                    perform {
                        try await pauseService.cancelPause()
                    }
                }

            case .active:
                if let plan = pauseService.plan {
                    Text("Ends at \(plan.endDate.formatted())")
                }

                Button("End Now") {
                    perform {
                        try await pauseService.endPauseNow()
                    }
                }
            }

            TextField("Enter Pause Reason", text: $pauseReason)
                .disabled(pauseStatus == .active)

            if pauseStatus == .active {
                if let plan = pauseService.plan {
                    Text("Started at \(plan.startDate.formatted())")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                }
            } else {
                Toggle("Start now", isOn: $startNow)

                if !startNow {
                    DatePicker(
                        "Start time",
                        selection: $pauseStartDate,
                        in: currentTime...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                }
            }

            DatePicker(
                "End time",
                selection: $pauseEndDate,
                in: currentTime...,
                displayedComponents: [.date, .hourAndMinute]
            )

            Button("Save pause") {
                savePause()
            }

            if pauseService.isBusy {
                ProgressView("Updating reminders…")
            }

            if let storageError = pauseService.storageError {
                Text(storageError)
                    .font(.footnote)
                    .foregroundStyle(.red)
            }
        } header: {
            Text("Pause")
        }
        .disabled(
            pauseService.isBusy || pauseService.storageError != nil
        )
        .onAppear {
            loadDraft()
        }
        .onChange(of: pauseService.plan) { _ in
            loadDraft()
        }
        .onReceive(
            Timer.publish(every: 1, on: .main, in: .common).autoconnect()
        ) { now in
            let previousStatus = pauseStatus
            currentTime = now

            if previousStatus != .active,
               pauseStatus == .active,
               let plan = pauseService.plan {
                pauseReason = plan.reason
                pauseStartDate = plan.startDate
                startNow = false
            }
        }
        .alert("Could not update pause", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    @MainActor
    private func loadDraft() {
        currentTime = Date()

        guard let plan = pauseService.plan,
              plan.status(at: currentTime) != .noPause else {
            pauseReason = ""
            startNow = true
            pauseStartDate = currentTime
            pauseEndDate = currentTime.addingTimeInterval(3600)
            return
        }

        pauseReason = plan.reason
        startNow = false
        pauseStartDate = plan.startDate
        pauseEndDate = plan.endDate
    }

    @MainActor
    private func savePause() {
        let requestedStart: Date?

        if pauseService.status() == .active {
            requestedStart = pauseService.plan?.startDate
        } else {
            requestedStart = startNow ? nil : pauseStartDate
        }

        let requestedEnd = pauseEndDate
        let requestedReason: String

        if pauseService.status() == .active,
           let plan = pauseService.plan {
            requestedReason = plan.reason
        } else {
            requestedReason = pauseReason
        }

        perform {
            _ = try await pauseService.savePause(
                startDate: requestedStart,
                endDate: requestedEnd,
                reason: requestedReason
            )
        }
    }

    @MainActor
    private func perform(
        _ operation: @escaping @MainActor () async throws -> Void
    ) {
        guard !pauseService.isBusy else {
            return
        }

        Task { @MainActor in
            do {
                try await operation()
                loadDraft()
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}
