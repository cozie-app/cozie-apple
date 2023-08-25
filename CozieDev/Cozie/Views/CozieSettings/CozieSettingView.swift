//
//  CozieSettingView.swift
//  Cozie
//
//  Created by Denis on 13.02.2023.
//

import SwiftUI

fileprivate extension Int {
    func toWatchType() -> WatchSurveyType {
        switch self {
        case 0:
            return .watchSurvey
        case 1:
            return .watchSurveyResponseGoal
        case 2:
            return .enableReminders
        case 3:
            return .reminderInterval
        case 4:
            return .participationDays
        case 5:
            return .participationTimeStart
        case 6:
            return .participationTimeEnd
        default:
            return .watchSurvey
        }
    }
}
enum WatchSurveyType: CaseIterable {
    case watchSurvey, watchSurveyResponseGoal, enableReminders, reminderInterval, participationDays, participationTimeStart, participationTimeEnd
    
    func toString() -> String {
        switch self {
        case .watchSurvey:
            return "Watch Survey"
        case .watchSurveyResponseGoal:
            return "Watch Survey Response Goal"
        case .enableReminders:
            return "Enable Reminders"
        case .reminderInterval:
            return "Reminder Interval"
        case .participationDays:
            return "Participation Days"
        case .participationTimeStart:
            return "Participation Time Start"
        case .participationTimeEnd:
            return "Participation Time End"
        }
    }
}

struct CozieSettingView: View {
    private let cellHeight: CGFloat = 35
    
    @ObservedObject var viewModel: SettingViewModel
    
    // MARK: States
    @State var showError = false
    let updateTrigger = NotificationCenter.default.publisher(for: HomeCoordinator.updateNorification)
    
    init(viewModel: SettingViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        ZStack {
            VStack {
                Spacer()
                    .frame(height: 1)
                List {
                    experimentSection()
                    watchSurveySection()
                    phoneSurveySection()
                }
                .padding([.leading, .trailing], -5)
                .listStyle(.insetGrouped)
                Spacer()
                    .frame(height: 1)
            }
            .alert(viewModel.errorString, isPresented: $showError) {
                Button("OK", role: .cancel) { }
            }
            .onAppear{
                viewModel.getUserInfo()
                viewModel.configureSettins()
            }
            .onReceive(updateTrigger) { _ in
                viewModel.resetSyncInfo()
                viewModel.getUserInfo()
                viewModel.configureSettins()
            }
            
            switch viewModel.showingState {
            case .watchSurvey:
                WatchSurveyList(title: "Question Flows",
                                viewModel: viewModel.questionViewModel) {
                    viewModel.clearState()
                } setAction: { selectedId in
                    viewModel.questionViewModel.selectedId = selectedId
                    viewModel.updateQuestionTitle()
                    viewModel.clearState()
                }
            case .watchGoal:
                TextFieldPopUp(title: "Set Goal",
                               subtitle: "Please enter the study goal",
                               text: viewModel.goal) {
                    viewModel.clearState()
                } setAction: { goal in
                    viewModel.goal = goal
                    viewModel.updateWSSGoal(Int(goal) ?? 0)
                    viewModel.clearState()
                }
            case .watchReminderInterval:
                TimerPicker(title: "Reminder Frequency",
                            subtitle: "Notify me every...",
                            selectedHour: viewModel.reminderInterval.hour,
                            selectedMinutes: viewModel.reminderInterval.minute,
                            stepInterval: 5,
                            closeAction: {
                    viewModel.clearState()
                }, setAction: { hour, minutes in
                    viewModel.reminderInterval.minute = minutes
                    viewModel.reminderInterval.hour = hour
                    viewModel.updateReminderInterval()
                    viewModel.clearState()
                })
            case .watchParticipation:
                DaysListView(list: viewModel.dayList) {
                    viewModel.clearState()
                } setAction: { list in
                    viewModel.clearState()
                    viewModel.updatePartisipants(list: list)
                }
            case .watchParticipationTimeStart:
                TimerPicker(title:"Daily Participation Time Start",
                            subtitle: "Notify me only after this time",
                            selectedHour: viewModel.timeStart.hour,
                            selectedMinutes: viewModel.timeStart.minute,
                            stepInterval: 5,
                            closeAction: {
                    viewModel.clearState()
                }, setAction: { hour, minutes in
                    viewModel.timeStart.hour = hour
                    viewModel.timeStart.minute = minutes
                    viewModel.updateWSSReminderStartTime()
                    viewModel.clearState()
                }
                )
            case .watchParticipationTimeEnd:
                TimerPicker(title:"Daily Participation Time End",
                            subtitle: "Notify me only before this time",
                            selectedHour: viewModel.timeEnd.hour,
                            selectedMinutes: viewModel.timeEnd.minute,
                            stepInterval: 5,
                            closeAction: {
                    viewModel.clearState()
                }, setAction: { hour, minutes in
                    viewModel.timeEnd.hour = hour
                    viewModel.timeEnd.minute = minutes
                    viewModel.updateWSSReminderEndTime()
                    viewModel.clearState()
                }
                )
            case .clear:
                let _ = print("do nothing")
            case .participantId:
                TextFieldPopUp(title: "Participant ID",
                               subtitle: "Please fill your specified Participant ID",
                               text: viewModel.participantID) {
                    viewModel.clearState()
                } setAction: { participantID in
                    viewModel.participantID = participantID
                    viewModel.updateParticipantID(participantID)
                    viewModel.clearState()
                }
            case .experimentId:
                TextFieldPopUp(title: "Experiment ID",
                               subtitle: "Please fill your specified Experiment ID",
                               text: viewModel.experimentID) {
                    viewModel.clearState()
                } setAction: { experimentID in
                    viewModel.experimentID = experimentID
                    viewModel.updateExperimentID(experimentID)
                    viewModel.clearState()
                }
            case .phoneReminderInterval:
                TimerPicker(title: "Phone Survey Reminder Time",
                            subtitle: "Notify me at...",
                            selectedHour: viewModel.phoneReminderInterval.hour,
                            selectedMinutes: viewModel.phoneReminderInterval.minute,
                            stepInterval: 5,
                            closeAction: {
                    viewModel.clearState()
                }, setAction: { hour, minutes in
                    viewModel.phoneReminderInterval.hour = hour
                    viewModel.phoneReminderInterval.minute = minutes
                    viewModel.updatePSSReminderTime()
                    viewModel.clearState()
                }
                )
            case .phoneParticipation:
                DaysListView(list: viewModel.phoneParticipationDays) {
                    viewModel.clearState()
                } setAction: { list in
                    viewModel.clearState()
                    viewModel.updatePhonePartisipants(list: list)
                }
            }
        }
    }
    
    // MARK: - List Section
    func experimentSection() -> some View {
        return Section(content: {
            SettingWatchCell(title: "Participant ID",
                             subtitle: viewModel.participantID,
                             isActive: viewModel.participentIDSynced).onTapGesture {
                viewModel.showingState = .participantId
            }
            
            SettingWatchCell(title: "Experiment ID ",
                             subtitle: viewModel.experimentID,
                             isActive: viewModel.experimentIDSynced).onTapGesture {
                viewModel.showingState = .experimentId
            }
        },
                       header: {
            CozieAnimatedSyncHeader(title: "Experiment Settings", action: {
                viewModel.sendInfo { success in
                    showError = !success
                }
            }, animated: $viewModel.loading)
        })
    }
    
    func watchSurveySection() -> some View {
        return Section(content: {
            ForEach( 0 ..< WatchSurveyType.allCases.count ) { index in
                createWatchSurveyCell(type: index.toWatchType())
            }
        },
                       header: {
            CozieHeaderView(title: "Watch Survey")
        })
    }
    
    func phoneSurveySection() -> some View {
        return Section(content: {
            ToggleCell(title: "Enable Reminder", isOn: $viewModel.phoneReminderState)
            TitleSubtitleCell(title: "Reminder Time",
                              subtitle: viewModel.phoneReminderInterval.formattedHourMinString()).onTapGesture {
                viewModel.showingState = .phoneReminderInterval
            }
            TitleSubtitleCell(title: "Reminder Days",
                              subtitle: viewModel.phoneParticipation).onTapGesture {
                viewModel.showingState = .phoneParticipation
            }
        },
                       header: {
            CozieHeaderView(title: "Phone Survey")
        })
    }
    
    // MARK: - Watch Survey Count
    func createWatchSurveyCell(type: WatchSurveyType) -> some View {
        switch type{
        case .watchSurvey:
            return AnyView(SettingWatchCell(title: type.toString(),
                                            subtitle: viewModel.watchSurveyTitle(),
                                            isActive: viewModel.surveySynced).onTapGesture {
                viewModel.showingState = .watchSurvey
            })
        case .watchSurveyResponseGoal:
            return AnyView(TitleSubtitleCell(title: type.toString(),
                                             subtitle: viewModel.goal).onTapGesture {
                viewModel.showingState = .watchGoal
            })
        case .enableReminders:
            return AnyView(ToggleCell(title: type.toString(), isOn: $viewModel.isReminderEnabled))
        case .reminderInterval:
            return AnyView(TitleSubtitleCell(title: type.toString(),
                                             subtitle: viewModel.reminderInterval.formattedMinString()).onTapGesture {
                viewModel.showingState = .watchReminderInterval
            })
        case .participationDays:
            return AnyView(TitleSubtitleCell(title: type.toString(), subtitle: viewModel.partisipans).onTapGesture {
                viewModel.showingState = .watchParticipation
            })
        case .participationTimeStart:
            return AnyView(TitleSubtitleCell(title: type.toString(), subtitle: viewModel.timeStart.formattedHourMinString()).onTapGesture {
                viewModel.showingState = .watchParticipationTimeStart
            })
        case .participationTimeEnd:
            return AnyView(TitleSubtitleCell(title: type.toString(), subtitle: viewModel.timeEnd.formattedHourMinString()).onTapGesture {
                viewModel.showingState = .watchParticipationTimeEnd
            })
        }
    }
}

struct CozieSettingView_Previews: PreviewProvider {
    static var previews: some View {
        CozieSettingView(viewModel: SettingViewModel(reminderManager: Session().reminderManager))
    }
}
