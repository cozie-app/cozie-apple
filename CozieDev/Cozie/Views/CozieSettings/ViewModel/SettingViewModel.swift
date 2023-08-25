//
//  SettingWatchSurveyViewModel.swift
//  Cozie
//
//  Created by Denis on 16.03.2023.
//
import Foundation
import SwiftUI
import Combine

enum SettingState {
    case clear, watchSurvey, watchGoal, watchReminderInterval, watchParticipation, watchParticipationTimeStart, watchParticipationTimeEnd, participantId, experimentId,
         phoneReminderInterval, phoneParticipation
}

struct TimeModel {
    var hour: Int = 0
    var minute: Int = 0
    
    init() {
        self.minute = 0
        self.hour = 0
    }
    
    init(hour: Int, minute: Int) {
        self.minute = minute
        self.hour = hour
    }
    
    init(minute: Int) {
        if minute >= 60 {
            hour = Int(minute/60)
            self.minute = minute%60
        } else {
            hour = 0
            self.minute = minute
        }
    }
    
    func formattedMinString() -> String {
        let result = (hour * 60) + minute
        return "\(result) min"
    }
    
    func formattedHourMinString() -> String {
        let result = hour.toTimeString() + ":" + minute.toTimeString()
        return result
    }
    
    func timeInMinutes() -> Int {
        return (hour * 60) + minute
    }
}

class SettingViewModel: ObservableObject {
    let persistenceController = PersistenceController.shared
    let storage = CozieStorage()
    // State Property
    @Published var showingState: SettingState = .clear {
        didSet {
            updateSettingState(state: showingState)
        }
    }
    @Published var isReminderEnabled: Bool = false
    
    // Experiment Settings
    @Published var participantID: String = "Participant_Ge9VxH5iP"
    @Published var experimentID: String = "App Store"
    
    // Watch Survey
    @Published var partisipans: String = ""
    @Published var goal: String = "100"
    @Published var reminderInterval: TimeModel = TimeModel()
    @Published var timeStart: TimeModel = TimeModel()
    @Published var timeEnd: TimeModel = TimeModel(hour: 23, minute: 0)
    @Published var questionViewModel = QuestionViewModel()
    var dayList = DaysViewModel().list
    
    // Phone Survey
    @Published var phoneReminderState: Bool = false
    @Published var phoneParticipation: String = ""
    @Published var phoneReminderInterval: TimeModel = TimeModel()
    
    @Published var reminderManager: ReminderManager
    
    @Published var loading: Bool = false
    
    @Published var showError: Bool = false
    
    @Published var participentIDSynced: Bool = false
    @Published var experimentIDSynced: Bool = false
    @Published var surveySynced: Bool = false
    
    var errorString: String = ""
    
    var phoneParticipationDays = DaysViewModel().list
    
    private var settingState: SettingState = .clear
    private var subscriptions = Set<AnyCancellable>()
    
    let userIntaractor = UserInteractor()
    let settingsIntaractor = SettingsInteractor()
    let logsSystemInteractor = LogsSystemInteractor()
    let backendInteractor = BackendInteractor()
    let comManager = WatchConnectivityManagerPhone.shared
    let watchSurveyInteractor = WatchSurveyInteractor()
    let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), loger: LoggerInteractor.shared)
    
    init(reminderManager: ReminderManager) {
        self.reminderManager = reminderManager
    }
    
    // MARK: System Logs
    func sendInfo(completion: ((_ success: Bool)->())?) {
        if !loading, let user = userIntaractor.currentUser {
            loading = true
            // post setting data
            settingsIntaractor.logSettingsData(name: user.participantID ?? "",
                                               expiriment: user.experimentID ?? "",
                                               logs: logsSystemInteractor.logsData()) { [weak self] success in
                guard let self = self else {
                    return
                }
                DispatchQueue.main.async {
                    self.loading = false
                    
                    if success {
                        self.errorString = ""
                    } else {
                        self.errorString = "Log settings data error."
                    }
                    completion?(success)
                }
            }
            
            // sync with watch
            syncWatchData()
            
            // send health data
            healthKitInteractor.sendData(trigger: CommunicationKeys.syncSettingsTrigger.rawValue, timeout: HealthKitInteractor.minInterval, completion: nil)
        }
    }
    
    // MARK: User info
    func getUserInfo() {
        if let user = userIntaractor.currentUser {
            participantID = user.participantID ?? "Participant_Ge9VxH5iP"
            experimentID = user.experimentID ?? "App Store"
        }
    }
    
    func configureSettins() {
        if let settings = settingsIntaractor.currentSettings {
            subscriptions.removeAll()
            
            updateSurveyList()
            
            goal = "\(settings.wss_goal)"
            isReminderEnabled = settings.wss_reminder_enabeled
            $isReminderEnabled.eraseToAnyPublisher().dropFirst().sink { [weak self] value in
                self?.updateInterval()
                self?.updateReminderState(isEnabled: value)
            }
            .store(in: &subscriptions)
            questionViewModel.selectedId = questionViewModel.selectedIDForTitle(settings.wss_title ?? "")
            
            if let daysValues = settings.wss_participation_days {
                // reset all selected
                dayList.forEach({ $0.isSelected = false })
                daysValues.components(separatedBy: ",").forEach { dayPrefix in
                    dayList.first(where: { $0.titleShort() == dayPrefix })?.isSelected = true
                }
                partisipans =  daysValues
            }
            let time = TimeModel(minute: Int(settings.wss_reminder_interval))
            reminderInterval = time
            
            if let timeStartString = settings.wss_participation_time_start {
                let temp = Array(timeStartString.components(separatedBy: ":"))
                timeStart = TimeModel(hour: Int(temp.first ?? "0") ?? 0, minute: Int(temp.last ?? "0") ?? 0)
            }
            
            if let timeEndString = settings.wss_participation_time_end {
                let temp = Array(timeEndString.components(separatedBy: ":"))
                timeEnd = TimeModel(hour: Int(temp.first ?? "0") ?? 0, minute: Int(temp.last ?? "0") ?? 0)
            }
            
            phoneReminderState = settings.pss_reminder_enabled
            $phoneReminderState.eraseToAnyPublisher().dropFirst().sink { [weak self] value in
                self?.updateInterval()
                self?.updatePhoneReminderState(isEnabled: value)
            }
            .store(in: &subscriptions)
            
            if let daysValues = settings.pss_reminder_days {
                // reset all selected
                phoneParticipationDays.forEach({ $0.isSelected = false })
                daysValues.components(separatedBy: ",").forEach { dayPrefix in
                    phoneParticipationDays.first(where: { $0.titleShort() == dayPrefix })?.isSelected = true
                }
                phoneParticipation = daysValues
            }
            
            if let pssReminderTime = settings.pss_reminder_time {
                let temp = Array(pssReminderTime.components(separatedBy: ":"))
                phoneReminderInterval = TimeModel(hour: Int(temp.first ?? "0") ?? 0, minute: Int(temp.last ?? "0") ?? 0)
            }
            
            participentIDSynced = storage.pIDSynced()
            experimentIDSynced = storage.expIDSynced()
            surveySynced = storage.surveySynced()
        }
    }
    
    func updateParticipantID(_ pID: String) {
        if let user = userIntaractor.currentUser {
            if pID != user.participantID {
                user.participantID = pID
                updateStateForParticipentID(enabled: false)
                try? persistenceController.container.viewContext.save()
            }
        }
    }
    
    private func updateStateForParticipentID(enabled: Bool) {
        participentIDSynced = enabled
        storage.savePIDSynced(enabled)
    }
    
    func updateExperimentID(_ eID: String) {
        if let user = userIntaractor.currentUser {
            if eID != user.experimentID {
                user.experimentID = eID
                updateStateForExperimentID(enabled: false)
                try? persistenceController.container.viewContext.save()
            }
        }
    }
    
    private func updateStateForExperimentID(enabled: Bool) {
        experimentIDSynced = enabled
        storage.saveExpIDSynced(enabled)
    }
    
    func updateQuestionTitle() {
        if let settings = settingsIntaractor.currentSettings {
            let selectedTitle = questionViewModel.selectedTitle()
            if selectedTitle != settings.wss_title {
                settings.wss_title = questionViewModel.selectedTitle()
                // update selected link
                storage.saveWSLink(link: questionViewModel.selectedLink())
                updateStateForSurveySynced(enabled: false)
                try? persistenceController.container.viewContext.save()
            }
        }
    }
    
    private func updateStateForSurveySynced(enabled: Bool) {
        surveySynced = enabled
        storage.saveSurveySynced(enabled)
    }
    
    func updateWSSGoal(_ goal: Int) {
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_goal = Int16(goal)
            try? persistenceController.container.viewContext.save()
        }
    }
    
    func updateReminderInterval() {
        updateInterval()
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_reminder_interval = Int16(reminderInterval.timeInMinutes())
            try? persistenceController.container.viewContext.save()
        }
    }
    
    func updateWSSReminderStartTime() {
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_participation_time_start = timeStart.formattedHourMinString()
            try? persistenceController.container.viewContext.save()
        }
        updateInterval()
        configureWatchReminders(enabled: isReminderEnabled)
    }
    
    func updateWSSReminderEndTime() {
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_participation_time_end = timeEnd.formattedHourMinString()
            try? persistenceController.container.viewContext.save()
        }
        updateInterval()
        configureWatchReminders(enabled: isReminderEnabled)
    }
    
    func updateInterval() {
        let startMinutes = timeStart.hour * 60 + timeStart.minute
        let endMinutes = timeEnd.hour * 60 + timeEnd.minute
        let daysCount = max(dayList.filter({ $0.isSelected }).count, 1)
        let availableCoundPerDay = Int(54/daysCount)
        if startMinutes < endMinutes {
            var distans = (endMinutes - startMinutes)/availableCoundPerDay
            let ect = distans % 5
            if ect != 0 {
                distans = distans + (5-ect)
            }
            reminderInterval = TimeModel(minute: max(distans, (reminderInterval.hour * 60) + reminderInterval.minute))
        } else {
            reminderInterval = TimeModel()
        }
    }
    
    func updatePSSReminderTime() {
        if let settings = settingsIntaractor.currentSettings {
            settings.pss_reminder_time = phoneReminderInterval.formattedHourMinString()
            try? persistenceController.container.viewContext.save()
        }
        configurePhoneReminders(enabled: phoneReminderState)
    }
    
    // MARK: Watch Action
    func updatePartisipants(list: [DayModel]) {
        let selected = list.filter{ $0.isSelected }
        var content = ""
        for day in selected {
            content = content + day.titleShort() + ","
        }
        dayList = list
        partisipans = String(content.dropLast())
        
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_participation_days = String(content.dropLast())
            try? persistenceController.container.viewContext.save()
        }
        updateInterval()
        configureWatchReminders(enabled: isReminderEnabled)
    }
    
    func updateReminderState(isEnabled: Bool) {
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_reminder_enabeled = isEnabled
            try? persistenceController.container.viewContext.save()
        }
        
        configureWatchReminders(enabled: isEnabled)
    }
    
    private func configureWatchReminders(enabled: Bool) {
        self.reminderManager.removeWatchNotification { [weak self] in
            guard let self = self else { return }
            if enabled {
                var reminders = [Reminder]()
                let selectedDays = self.dayList.filter({ $0.isSelected })
                for day in selectedDays {
                    let model = Reminder(identifier: "watch",
                                         day: day,
                                         timeStart: self.timeStart.timeInMinutes(),
                                         timeEnd: self.timeEnd.timeInMinutes(),
                                         interval: self.reminderInterval.timeInMinutes())
                    reminders.append(model)
                }
                DispatchQueue.main.async {
                    self.reminderManager.createReminderNotification(list: reminders)
                }
            }
        }
    }
    
    func updateSettingState(state: SettingState) {
        if settingState != .clear {
            settingState = .clear
        } else {
            settingState = state
        }
    }
    
    // MARK: Both Action
    func watchSurveyTitle() -> String {
        for question in questionViewModel.list {
            if question.id == questionViewModel.selectedId {
                return question.title
            }
        }
        return ""
    }
    
    func clearState() {
        showingState = .clear
    }
    
    // MARK: Phone Survey Func
    func updatePhoneReminderState(isEnabled: Bool) {
        if let settings = settingsIntaractor.currentSettings {
            settings.pss_reminder_enabled = isEnabled
            try? persistenceController.container.viewContext.save()
        }
        configurePhoneReminders(enabled: isEnabled)
    }
    
    private func configurePhoneReminders(enabled: Bool) {
        reminderManager.removePhoneNotification { [weak self] in
            guard let self = self else { return }
            if enabled {
                var reminders = [PhoneReminder]()
                let selectedDays = self.phoneParticipationDays.filter({ $0.isSelected })
                for day in selectedDays {
                    let model = PhoneReminder(identifier: "phone",
                                              day: day,
                                              timeStart: self.phoneReminderInterval.timeInMinutes())
                    reminders.append(model)
                }
                if !reminders.isEmpty {
                    DispatchQueue.main.async {
                        self.reminderManager.createPhoneReminder(list: reminders)
                    }
                }
            }
        }
    }
    // MARK: Reminders
    
    func prepareRemindersIfNeeded() {
        if let settings = settingsIntaractor.currentSettings {
            configureWatchReminders(enabled: settings.wss_reminder_enabeled)
            configurePhoneReminders(enabled: settings.pss_reminder_enabled)
        }
    }
    
    func updatePhonePartisipants(list: [DayModel]) {
        let selected = list.filter{ $0.isSelected }
        var content = ""
        for day in selected {
            content = content + day.titleShort() + ","
        }
        phoneParticipationDays = list
        phoneParticipation = String(content.dropLast())
        
        if let settings = settingsIntaractor.currentSettings {
            settings.pss_reminder_days = String(content.dropLast())
            try? persistenceController.container.viewContext.save()
        }
        
        configurePhoneReminders(enabled: phoneReminderState)
    }
    
    // MARK: Sync watch survey
    func syncWatchData(completion: (()->())? = nil) {
        watchSurveyInteractor.loadSelectedWatchSurveyJSON { [weak self] success in
            guard let self = self else {
                return
            }
            if success {
                DispatchQueue.main.async {
                    do {
                        let request = WatchSurveyData.fetchRequest()
                        request.predicate = NSPredicate(format: "selected == %d", true)
                        let surveysList = try self.persistenceController.container.viewContext.fetch(request)
                        
                        if let survey = surveysList.first?.toModel(), let backend = self.backendInteractor.currentBackendSettings, let user = self.userIntaractor.currentUser, let settings = self.settingsIntaractor.currentSettings  {
                            let json = try JSONEncoder().encode(survey)
                            self.comManager.sendAll(data: json, writeApiURL: backend.api_write_url ?? "", writeApiKey: backend.api_write_key ?? "", userID: user.participantID ?? "", expID: user.experimentID ?? "", password: user.passwordID ?? "", userOneSignalID: self.storage.playerID(), timeInterval: Int(settings.wss_time_out)) {
                                DispatchQueue.main.async { [weak self] in
                                    self?.updateStateForParticipentID(enabled: true)
                                    self?.updateStateForExperimentID(enabled: true)
                                    self?.updateStateForSurveySynced(enabled: true)
                                    
                                    completion?()
                                }
                            }
                        }
                        
                    } catch let error {
                        debugPrint(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func resetSyncInfo() {
        updateStateForParticipentID(enabled: false)
        updateStateForExperimentID(enabled: false)
        updateStateForSurveySynced(enabled: false)
    }
    
    // MARK: Watch survey list
    func updateSurveyList() {
        if self.questionViewModel.list.first(where: { $0.link == (backendInteractor.currentBackendSettings?.watch_survey_link ?? "link" ) }) == nil {
            do {
                let request = WatchSurveyData.fetchRequest()
                request.predicate = NSPredicate(format: "external == %d", true)
                let surveysList = try self.persistenceController.container.viewContext.fetch(request)
                if let model = surveysList.first {

                    let link = self.backendInteractor.currentBackendSettings?.watch_survey_link ?? ""
                    if self.questionViewModel.selectedId == 0, storage.selectedWSLink() != link {
                        storage.saveWSLink(link: link)
                    }
                    
                    self.questionViewModel.updateWithBackendSurvey(title: model.surveyName ?? "", link: link)
                }
            } catch let error {
                debugPrint(error.localizedDescription)
            }
        }
    }
}
