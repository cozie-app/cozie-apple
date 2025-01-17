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

class SettingViewModel: ObservableObject {
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
    @Published var participationDays: String = ""
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
    
    let udStorage: UserDefaultsStoregeProtocol
    let dbStorage: DataBaseStorageProtocol
    let backendInteractor: BackendInteractorProtocol
    
    let userIntaractor = UserInteractor()
    let settingsIntaractor = SettingsInteractor()
    let logsSystemInteractor = LogsSystemInteractor()
    let comManager = WatchConnectivityManagerPhone.shared
    let watchSurveyInteractor = WatchSurveyInteractor()
    let healthKitInteractor = HealthKitInteractor(storage: CozieStorage.shared, userData: UserInteractor(), backendData: BackendInteractor(), loger: LoggerInteractor.shared)
    
    init(reminderManager: ReminderManager,
         storage: UserDefaultsStoregeProtocol = CozieStorage(),
         dbStorage: DataBaseStorageProtocol = PersistenceController.shared,
         backendInteractor: BackendInteractorProtocol = BackendInteractor()) {
        
        self.reminderManager = reminderManager
        self.udStorage = storage
        self.dbStorage = dbStorage
        self.backendInteractor = backendInteractor
    }
    
    // MARK: System Logs
    func sendInfo(completion: ((_ success: Bool)->())?) {
        if !loading, let user = userIntaractor.currentUser {
            // reset images for watch sync status
            resetSyncInfo()
            
            loading = true
            // post setting data
            settingsIntaractor.logSettingsData(name: user.participantID ?? "",
                                               expiriment: user.experimentID ?? "",
                                               logs: logsSystemInteractor.logsData(), completion: nil)
            
            // sync with watch
            syncWatchData { [weak self] error in
                DispatchQueue.main.async {
                    // show error when clock synchronization fails
                    if let error = error {
                        self?.errorString = error.localizedDescription
                        completion?(false)
                    }
                    
                    self?.loading = false
                }
            }
            
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
    
    /// Prepare WS Link user interface
    ///
    /// Backend behavior:
    ///
    ///    Behavior 1:
    ///    The 1st one (external or internal) is selected. If user update the link (from Advanced tab) we update selected link and setting tab to new link info.
    ///
    ///    Behavior 2:
    ///    If the user selects the 3rd one from internal and updates the external one in Advanced tab, we update the first link (external) in the settings list (external + 6 internal), but the 3rd one is selected.
    ///
    ///    DeepLink/QR-Code behavior:
    ///
    ///    Behavior 1: same as behavior 1 Advanced tab.
    ///
    ///    Behavior 2:
    ///    If the user selects the 3rd one from internal and updates from DeepLink/QR-Code we make the external link (from Advanced tab) selected.
    /// - Parameter settingsTitle: wss_title from settings model.
    /// - Parameter updateExternalSurvey: Indicates that the function was called via Deep Link/QR code.
    @MainActor
    func prepareSelectedWSLinkUI(_ settingsTitle: String, updateExternalSurvey: Bool = false) {
        let (selectedLink, selectedWSTitle) = udStorage.selectedWSLink()
        let (externalLink, externalWSTitle) = udStorage.externalWSLink()
        let backendLink = backendInteractor.currentBackendSettings?.watch_survey_link ?? ""
        
        if !selectedLink.isEmpty {
            if selectedLink != backendLink {
                // update from QR/DeepLink
                if updateExternalSurvey {
                    udStorage.saveWSLink(link: (backendLink, settingsTitle))
                    questionViewModel.updateWithBackendSurvey(title: settingsTitle, link: backendLink)
                    questionViewModel.selectedId = questionViewModel.selectedIDForTitle(selectedWSTitle)
                } else {
                    // selected link is internal
                    if let id = questionViewModel.selectedIDForLink(selectedLink), id > 0 {
                        questionViewModel.selectedId = id
                        // update external ws link in ws links list
                        if !backendLink.isEmpty && (externalLink != backendLink || questionViewModel.firstWSInfoLink()?.title != externalWSTitle){
                            udStorage.saveExternalWSLink(link: (backendLink, externalWSTitle))
                            questionViewModel.updateWithBackendSurvey(title: externalWSTitle, link: backendLink)
                        } else {
                            questionViewModel.updateToDefaultState()
                        }
                        
                        updateQuestionTitle()
                    } else {
                        do {
                            if let model = try dbStorage.externalWatchSurvey() {
                                if selectedLink != externalLink, model.surveyName == externalWSTitle {
                                    // update selected ws link
                                    udStorage.saveWSLink(link: (externalLink, externalWSTitle))
                                }
                                // seved model was not updated
                                var modelTitle = model.surveyName ?? ""
                                if modelTitle != externalWSTitle {
                                    modelTitle = externalWSTitle
                                }
                                
                                updateWSLinkView(title: modelTitle, link: backendLink, id: questionViewModel.selectedIDForTitle(modelTitle))
                            } else {
                                if !backendLink.isEmpty {
                                    udStorage.saveWSLink(link: (backendLink, ""))
                                    // update selected ws link without synced ws
                                    updateWSLinkView(link: backendLink, id: self.questionViewModel.defaultSelectedID())
                                } else {
                                    // if ws link was removed or not filled in backend tab it should be set to default state
                                    setToDefaulsWSLink()
                                }
                            }
                        } catch let error {
                            debugPrint(error.localizedDescription)
                        }
                    }
                }
            // selected and backend link is the same
            // first load of app
            } else {
                ///
                if questionViewModel.selectedId == 0 {
                    let title = selectedWSTitle.isEmpty ? externalWSTitle : selectedWSTitle
                    updateWSLinkView(title: title, link: selectedLink, id: questionViewModel.selectedIDForTitle(title))
                } else {
                    updateWSLinkView(title: selectedWSTitle, link: selectedLink, id: questionViewModel.selectedIDForTitle(selectedWSTitle))
                }
            }
        } else {
            // first load if user has ws-link in backend config
            if !backendLink.isEmpty {
                updateWSLinkView(title: settingsTitle, link: backendLink, id: questionViewModel.selectedIDForTitle(settingsTitle))
            // first load with default ws link
            } else {
                // if ws link was removed or not filled in backend tab it should be set to default state
                setToDefaulsWSLink()
            }
        }
    }
    
    /// Set the default link state. The internal link is empty.
    @MainActor
    private func setToDefaulsWSLink() {
        questionViewModel.updateToDefaultState()
        questionViewModel.selectedId = questionViewModel.defaultSelectedID()
    }
    
    /// Update selected ws link.
    /// The first default/internal element will be replaced by an external link from the backend tab.
    /// - Parameter title: Empty string by default or survey name.
    /// - Parameter link: WS link.
    /// - Parameter id: The selected identifier from the list of links.
    @MainActor
    private func updateWSLinkView(title: String = "", link: String, id: Int) {
        questionViewModel.updateWithBackendSurvey(title: title, link: link)
        questionViewModel.selectedId = id
        updateQuestionTitle()
    }
    
    @MainActor
    func configureSettings(updateExternalSurvey: Bool = false) {
        if let settings = settingsIntaractor.currentSettings {
            subscriptions.removeAll()
            prepareSelectedWSLinkUI(settings.wss_title ?? "", updateExternalSurvey: updateExternalSurvey)

            goal = "\(settings.wss_goal)"
            isReminderEnabled = settings.wss_reminder_enabled
            $isReminderEnabled.eraseToAnyPublisher().dropFirst().sink { [weak self] value in
                self?.updateInterval()
                self?.updateReminderState(isEnabled: value)
            }
            .store(in: &subscriptions)
            
            if let daysValues = settings.wss_participation_days {
                // reset all selected
                dayList.forEach({ $0.isSelected = false })
                daysValues.components(separatedBy: ",").forEach { dayPrefix in
                    dayList.first(where: { $0.titleShort() == dayPrefix })?.isSelected = true
                }
                participationDays =  daysValues
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
            
            participentIDSynced = udStorage.pIDSynced()
            experimentIDSynced = udStorage.expIDSynced()
            surveySynced = udStorage.surveySynced()
        }
    }
    
    func updateParticipantID(_ pID: String) {
        if let user = userIntaractor.currentUser {
            if pID != user.participantID {
                user.participantID = pID
                updateStateForParticipentID(enabled: false)
                try? dbStorage.saveViewContext()
            }
        }
    }
    
    private func updateStateForParticipentID(enabled: Bool) {
        participentIDSynced = enabled
        udStorage.savePIDSynced(enabled)
    }
    
    func updateExperimentID(_ eID: String) {
        if let user = userIntaractor.currentUser {
            if eID != user.experimentID {
                user.experimentID = eID
                updateStateForExperimentID(enabled: false)
                try? dbStorage.saveViewContext()
            }
        }
    }
    
    private func updateStateForExperimentID(enabled: Bool) {
        experimentIDSynced = enabled
        udStorage.saveExpIDSynced(enabled)
    }
    
    func updateQuestionTitle() {
        if let settings = settingsIntaractor.currentSettings {
            let selectedTitle = questionViewModel.selectedTitle()
            if selectedTitle != settings.wss_title {
                settings.wss_title = questionViewModel.selectedTitle()
                try? dbStorage.saveViewContext()
                
                // update selected link
                udStorage.saveWSLink(link: (questionViewModel.selectedLink(), selectedTitle))
                updateStateForSurveySynced(enabled: false)
            }
        }
    }
    
    private func updateStateForSurveySynced(enabled: Bool) {
        surveySynced = enabled
        udStorage.saveSurveySynced(enabled)
    }
    
    func updateWSSGoal(_ goal: Int) {
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_goal = Int16(goal)
            try? dbStorage.saveViewContext()
        }
    }
    
    func updateReminderInterval() {
        updateInterval()
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_reminder_interval = Int16(reminderInterval.timeInMinutes())
            try? dbStorage.saveViewContext()
        }
    }
    
    func updateWSSReminderStartTime() {
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_participation_time_start = timeStart.formattedHourMinString()
            try? dbStorage.saveViewContext()
        }
        updateInterval()
        configureWatchReminders(enabled: isReminderEnabled)
    }
    
    func updateWSSReminderEndTime() {
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_participation_time_end = timeEnd.formattedHourMinString()
            try? dbStorage.saveViewContext()
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
            var distance = (endMinutes - startMinutes)/availableCoundPerDay
            let ect = distance % 5
            if ect != 0 {
                distance = distance + (5-ect)
            }
            reminderInterval = TimeModel(minute: max(distance, (reminderInterval.hour * 60) + reminderInterval.minute))
        } else {
            reminderInterval = TimeModel()
        }
    }
    
    func updatePSSReminderTime() {
        if let settings = settingsIntaractor.currentSettings {
            settings.pss_reminder_time = phoneReminderInterval.formattedHourMinString()
            try? dbStorage.saveViewContext()
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
        participationDays = String(content.dropLast())
        
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_participation_days = String(content.dropLast())
            try? dbStorage.saveViewContext()
        }
        updateInterval()
        configureWatchReminders(enabled: isReminderEnabled)
    }
    
    func updateReminderState(isEnabled: Bool) {
        if let settings = settingsIntaractor.currentSettings {
            settings.wss_reminder_enabled = isEnabled
            try? dbStorage.saveViewContext()
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
            try? dbStorage.saveViewContext()
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
            configureWatchReminders(enabled: settings.wss_reminder_enabled)
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
            try? dbStorage.saveViewContext()
        }
        
        configurePhoneReminders(enabled: phoneReminderState)
    }
    
    // MARK: Sync watch survey
    func syncWatchData(completion: ((_ error: Error?)->())? = nil) {
        watchSurveyInteractor.loadSelectedWatchSurveyJSON { [weak self] title, loadError in
            guard let self = self else {
                return
            }
            if loadError == nil {
                DispatchQueue.main.async {
                    do {

                        let selectedWS = try self.dbStorage.selectedWatchSurvey()
                        
                        if let survey = selectedWS?.toModel(), let backend = self.backendInteractor.currentBackendSettings, let user = self.userIntaractor.currentUser, let settings = self.settingsIntaractor.currentSettings  {
                            let json = try JSONEncoder().encode(survey)
                            self.comManager.sendAll(data: json, writeApiURL: backend.api_write_url ?? "", writeApiKey: backend.api_write_key ?? "", userID: user.participantID ?? "", expID: user.experimentID ?? "", password: user.passwordID ?? "", userOneSignalID: self.udStorage.playerID(), timeInterval: Int(settings.wss_time_out), healthCutoffTimeInterval: CozieStorage.shared.maxHealthCutoffInteval()) { error in
                                DispatchQueue.main.async { [weak self] in
                                    
                                    // trigger an error alert
                                    if let error = error {
                                        completion?(error)
                                        return
                                    }
                                    
                                    self?.updateStateForParticipentID(enabled: true)
                                    self?.updateStateForExperimentID(enabled: true)
                                    self?.updateStateForSurveySynced(enabled: true)
                                    
                                    completion?(nil)
                                }
                            }
                        }
                        
                    } catch let error {
                        debugPrint(error.localizedDescription)
                        completion?(error)
                    }
                }
            } else {
                completion?(loadError)
            }
        }
    }
    
    func resetSyncInfo() {
        updateStateForParticipentID(enabled: false)
        updateStateForExperimentID(enabled: false)
        updateStateForSurveySynced(enabled: false)
    }
}
