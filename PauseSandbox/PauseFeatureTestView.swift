//
//  PauseFeatureTestView.swift
//  Cozie
//

import SwiftUI
import UserNotifications
import OneSignalFramework
import Combine

struct PauseFeatureTestView: View {
    
    @StateObject private var pauseService: PauseService

    private var pauseManager: PauseManager {
        pauseService.pauseManager
    }

    private var reminderManager: ReminderManager {
        pauseService.reminderManager
    }
    
    @State private var pauseEndDate = Date().addingTimeInterval(5 * 60)
    @State private var pauseReason = ""
    @State private var pendingCount = 0
    @State private var pushOptedIn = false
    @State private var logLines: [String] = []
    
    @State private var startNow = true
    @State private var pauseStartDate = Date()
    
    @State private var currentTime = Date()
    
    @State private var isSavingPause = false
    
    @Environment(\.scenePhase) private var scenePhase
    
    private var pauseStatus: PauseStatus {
        pauseManager.status(at: currentTime)
    }
    
    @MainActor
    init() {
        _pauseService = StateObject(
            wrappedValue: PauseService(
                pauseManager: PauseManager(),
                reminderManager: ReminderManager()
            )
        )
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Notification Permission") {
                    Button("Request Permission") {
                        reminderManager.askForPermission { result in
                            DispatchQueue.main.async {
                                switch result {
                                case .success(let granted):
                                    log(granted ? "Permission granted" : "Permission denied")
                                case .failure(let error):
                                    log("Permission error: \(error.localizedDescription)")
                                }
                            }
                        }
                    }
                }
                
                Section("Pause State") {
                    switch pauseStatus {
                    case .noPause:
                        Text("No Pause")
                        
                    case .scheduled:
                        if let plan = pauseManager.plan{
                            Text("Scheduled, starts at \(plan.startDate.formatted())")
                        }
                        
                        Button("Cancel", role: .destructive){
                            cancelPause()
                        }.disabled(isSavingPause)
                        
                    case .active:
                        if let plan = pauseManager.plan{
                            Text("Active, ends at \(plan.endDate.formatted())")
                        }
                        Button("End Now"){
                            endPauseNow()
                        }.disabled(isSavingPause)
                    }
                    
                    TextField("Pause Reason", text: $pauseReason).disabled(pauseStatus == .active)
                    
                    if pauseStatus == .active{
                        // can't change startDate, after active
                        if let plan = pauseManager.plan{
                            Text("Started at \(plan.startDate.formatted())")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }else{
                        Toggle("Start now", isOn: $startNow)
                        
                        if !startNow {
                            DatePicker(
                                "Start time",
                                selection: $pauseStartDate,
                                displayedComponents: [.date, .hourAndMinute]
                            )
                        }
                    }
                    
                    DatePicker(
                        "End time",
                        selection: $pauseEndDate,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    
                    Button("Save pause"){
                        savePause()
                    }.disabled( isSavingPause || pauseManager.storageError != nil)
                    
                    if let error = pauseManager.storageError{
                        Text(error).foregroundColor(.red)
                    }
                }
                
                Section("Test Reminder (Local)") {
                    
                    Button("Create Test Reminder") {
                        createTestReminder()
                    }.disabled(isSavingPause)
                    
                    
                    
                    Button("Refresh Pending Count") {
                        refreshPendingCount()
                    }
                    Text("Pending notifications: \(pendingCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Remote Push (OneSignal)") {
                    Button("Refresh Push Status") {
                        refreshPushStatus()
                    }
                    Text(pushOptedIn ? "Push subscription: ON" : "Push subscription: OFF")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Section("Log") {
                    ForEach(logLines.reversed(), id: \.self) { line in
                        Text(line).font(.system(size: 12, design: .monospaced))
                    }
                }
            }
            .navigationTitle("Pause Sandbox")
            .onAppear {
                UserInteractor().prepareUser()
                loadPauseDraft()
                
                initializeOneSignalIfNeeded()
                refreshPendingCount()
                refreshPushStatus()
                
            }
            .onReceive(
                Timer.publish(every: 1, on: .main, in: .common).autoconnect()
            ) { date in
                guard !isSavingPause else { return }
                
                let previousStatus = pauseManager.status(at: currentTime)
                currentTime = date
                let newStatus = pauseManager.status(at: date)
                
                if previousStatus != newStatus {
                    loadPauseDraft()
                }
                restoreExpiredPauseIfNeeded()
            }
            .onChange(of: scenePhase) { phase in
                if phase == .active {
                    restoreExpiredPauseIfNeeded()
                }
            }
        }
    }
    
    // get the pause status to initial Onesignal push
    private func initializeOneSignalIfNeeded() {
        OneSignal.initialize(CommunicationKeys.oneSignalAppID.rawValue, withLaunchOptions: nil)
    }
    
    private func loadPauseDraft() {
        let now = Date()
        currentTime = now
        
        guard let plan = pauseManager.plan,
              plan.status(at: now) != .noPause else {
            startNow = true
            pauseStartDate = now
            pauseEndDate = now.addingTimeInterval(5 * 60)
            pauseReason = ""
            return
        }
        
        startNow = false
        pauseStartDate = plan.startDate
        pauseEndDate = plan.endDate
        pauseReason = plan.reason
    }
    
    @MainActor
    private func savePause() {
        guard !isSavingPause, !pauseService.isBusy else {
            return
        }

        let requestedStart: Date?

        if pauseService.status() == .active {
            requestedStart = pauseService.plan?.startDate
        } else {
            requestedStart = startNow ? nil : pauseStartDate
        }

        let requestedEnd = pauseEndDate
        let requestedReason = pauseReason

        isSavingPause = true

        Task { @MainActor in
            defer {
                isSavingPause = false
                refreshPendingCount()
            }

            do {
                let changed = try await pauseService.savePause(
                    startDate: requestedStart,
                    endDate: requestedEnd,
                    reason: requestedReason
                )

                if changed {
                    log("Pause plan saved and reminder schedule updated.")
                } else {
                    log("No changes to save.")
                }

                loadPauseDraft()
            } catch {
                log("Could not save pause: \(error.localizedDescription)")
            }
        }
    }

    @MainActor
    private func cancelPause() {
        finishPause(expectedStatus: .scheduled)
    }

    @MainActor
    private func endPauseNow() {
        finishPause(expectedStatus: .active)
    }
    
    @MainActor
    private func finishPause(expectedStatus: PauseStatus) {
        guard !isSavingPause, !pauseService.isBusy else {
            return
        }

        isSavingPause = true

        Task { @MainActor in
            defer {
                isSavingPause = false
                refreshPendingCount()
            }

            do {
                switch expectedStatus {
                case .scheduled:
                    try await pauseService.cancelPause()
                    log("Pause cancelled. Original reminder schedule restored.")

                case .active:
                    try await pauseService.endPauseNow()
                    log("Pause ended early. Original reminder schedule restored.")

                case .noPause:
                    log("There is no pause to finish.")
                }

                loadPauseDraft()
            } catch {
                log(error.localizedDescription)
                loadPauseDraft()
            }
        }
    }
    
    @MainActor
    private func restoreExpiredPauseIfNeeded() {
        guard !isSavingPause, !pauseService.isBusy else {
            return
        }

        guard let plan = pauseService.plan,
              plan.endDate <= Date() else {
            return
        }

        isSavingPause = true

        Task { @MainActor in
            defer {
                isSavingPause = false
                refreshPendingCount()
            }

            do {
                let restored = try await pauseService
                    .restoreExpiredPauseIfNeeded()

                if restored {
                    log("Pause expired. Original reminder schedule restored.")
                    loadPauseDraft()
                }
            } catch {
                log("Could not restore reminders: \(error.localizedDescription)")
            }
        }
    }
    

    private func createTestReminder() {
        guard pauseManager.status() == .noPause else {
            log("Skipped: a pause plan is scheduled or active")
            return
        }

        let today = DayModel(id: 0, title: currentWeekday(), isSelected: true)
        let now = Date()
        let minutesNow = Calendar.current.component(.hour, from: now) * 60 + Calendar.current.component(.minute, from: now)

        let reminder = Reminder(identifier: "sandbox-test",
                                 day: today,
                                 timeStart: minutesNow + 1,
                                 timeEnd: minutesNow + 10,
                                 interval: 1)

        reminderManager.createReminderNotification(list: [reminder])
        
        let phoneReminder = PhoneReminder(
            identifier: "sandbox-phone-test",
            day: today,
            timeStart: reminder.timeStart
        )
        reminderManager.createPhoneReminder(list: [phoneReminder])
        
        log("Test reminder created")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { refreshPendingCount() }
    }

    private func refreshPendingCount() {
        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in
                DispatchQueue.main.async {
                    pendingCount = requests.count

                    #if DEBUG
                    let pauseRequests = requests.filter {
                        $0.identifier.hasPrefix("watch-pause-")
                            || $0.identifier.hasPrefix("phone-pause-")
                    }

                    let scheduled: [(id: String, date: Date)] =
                        pauseRequests.compactMap { request in
                            guard let trigger = request.trigger
                                as? UNCalendarNotificationTrigger,
                                  let date = trigger.nextTriggerDate() else {
                                return nil
                            }

                            return (id: request.identifier, date: date)
                        }
                        .sorted { $0.date < $1.date }

                    log("Pause requests with future dates: \(scheduled.count)")

                    // only show top 5
                    for item in scheduled.prefix(5) {
                        log("\(item.id): \(item.date.formatted())")
                    }

                    if let plan = pauseManager.plan {
                        let insidePause = scheduled.filter {
                            $0.date >= plan.startDate
                                && $0.date < plan.endDate
                        }

                        log("Requests inside pause: \(insidePause.count)")
                    }
                    #endif
                }
            }
    }

    private func refreshPushStatus() {
        pushOptedIn = OneSignal.User.pushSubscription.optedIn
    }

    private func currentWeekday() -> DayIndex {
        switch Calendar.current.component(.weekday, from: Date()) {
        case 1: return .sunday
        case 2: return .monday
        case 3: return .tuesday
        case 4: return .wednesday
        case 5: return .thursday
        case 6: return .friday
        default: return .saturday
        }
    }

    private func log(_ text: String) {
        let time = DateFormatter.localizedString(from: Date(), dateStyle: .none, timeStyle: .medium)
        logLines.append("[\(time)] \(text)")
    }
}

#Preview {
    PauseFeatureTestView()
}
