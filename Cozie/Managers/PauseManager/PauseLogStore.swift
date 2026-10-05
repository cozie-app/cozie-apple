//
//  PauseLogStore.swift
//  Cozie
//


import Foundation

struct StoredPauseLog: Codable {
    let record: PauseLogRecord

    // Remember the intended backend without storing its API key.
    let destinationURL: String?

    var uploadedAt: Date?
}

@MainActor
final class PauseLogStore {
    private let fileURL: URL

    private(set) var entries: [StoredPauseLog]

    var pendingEntries: [StoredPauseLog] {
        entries.filter { $0.uploadedAt == nil }
    }

    init() throws {
        let directory = try FileManager.default.url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )

        fileURL = directory.appendingPathComponent(
            "pause-event-history-v1.json"
        )

        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            entries = try JSONDecoder().decode(
                [StoredPauseLog].self,
                from: data
            )
        } else {
            entries = []
        }
    }

    func append(
        _ record: PauseLogRecord,
        destinationURL: String?
    ) throws {
        let eventID = record.fields.eventID

        guard !entries.contains(where: {
            $0.record.fields.eventID == eventID
        }) else {
            return
        }

        let entry = StoredPauseLog(
            record: record,
            destinationURL: destinationURL,
            uploadedAt: nil
        )

        var updated = entries
        updated.append(entry)

        try persist(updated)
        entries = updated
    }

    func markUploaded(eventID: String) throws {
        guard let index = entries.firstIndex(where: {
            $0.record.fields.eventID == eventID
        }) else {
            throw PauseValidationError(
                message: "The pause event could not be found."
            )
        }

        guard entries[index].uploadedAt == nil else {
            return
        }

        var updated = entries
        updated[index].uploadedAt = Date()

        try persist(updated)
        entries = updated
    }

    private func persist(_ updated: [StoredPauseLog]) throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

        let data = try encoder.encode(updated)
        try data.write(to: fileURL, options: .atomic)
    }
}

