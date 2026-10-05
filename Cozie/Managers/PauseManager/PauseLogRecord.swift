//
//  PauseLogRecord.swift
//  Cozie

/*
 Pause log format follows the existing time/measurement/tags/fields structure.

 Client-requested fields:
 - config_pause_datetime_start
 - config_pause_datetime_end
 - config_pause_reason

 Additional config_pause_* fields capture event IDs, event types,
 previous values, actual end times, and resume triggers.
 These preserve the history of changes without overwriting the
 planned end time when a pause ends early.

 Event IDs identify individual events; backend deduplication is
 not guaranteed by this model.
 */

import Foundation

struct PauseLogRecord: Codable {
    let time: String
    let measurement: String
    let tags: PauseLogTags
    let fields: PauseLogFields

    init(
        event: PauseEvent,
        experimentID: String,
        participantID: String,
        passwordID: String,
        oneSignalID: String
    ) {
        time = Self.dateString(event.occurredAt)
        measurement = experimentID

        tags = PauseLogTags(
            participantID: participantID,
            passwordID: passwordID,
            oneSignalID: oneSignalID
        )

        fields = PauseLogFields(
            eventID: event.eventID.uuidString,
            pauseID: event.pauseID.uuidString,
            eventType: event.eventType.rawValue,
            startDate: Self.dateString(event.pauseStartDate),
            endDate: event.plannedEndDate.map { Self.dateString($0) },
            reason: event.reason,
            previousStartDate: event.previousStartDate.map {
                Self.dateString($0)
            },
            previousEndDate: event.previousEndDate.map {
                Self.dateString($0)
            },
            previousReason: event.previousReason,
            actualEndDate: event.actualEndDate.map {
                Self.dateString($0)
            },
            resumeTrigger: event.resumeTrigger?.rawValue
        )
    }

    private static func dateString(_ date: Date) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [
            .withInternetDateTime,
            .withFractionalSeconds
        ]
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        return formatter.string(from: date)
    }
}

struct PauseLogTags: Codable {
    let participantID: String
    let passwordID: String
    let oneSignalID: String

    enum CodingKeys: String, CodingKey {
        case participantID = "id_participant"
        case passwordID = "id_password"
        case oneSignalID = "id_onesignal"
    }
}

struct PauseLogFields: Codable {
    let eventID: String
    let pauseID: String
    let eventType: String

    let startDate: String
    let endDate: String?
    let reason: String

    let previousStartDate: String?
    let previousEndDate: String?
    let previousReason: String?
    let actualEndDate: String?
    let resumeTrigger: String?

    enum CodingKeys: String, CodingKey {
        case eventID = "config_pause_event_id"
        case pauseID = "config_pause_id"
        case eventType = "config_pause_event_type"

        case startDate = "config_pause_datetime_start"
        case endDate = "config_pause_datetime_end"
        case reason = "config_pause_reason"

        case previousStartDate = "config_pause_previous_datetime_start"
        case previousEndDate = "config_pause_previous_datetime_end"
        case previousReason = "config_pause_previous_reason"
        case actualEndDate = "config_pause_datetime_end_actual"
        case resumeTrigger = "config_pause_resume_trigger"
    }
}
