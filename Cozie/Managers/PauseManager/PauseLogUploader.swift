//
//  PauseLogUploader.swift
//  Cozie
//


import Foundation

@MainActor
final class PauseLogUploader {
    private var isUploading = false
    private var nextAttempt = Date.distantPast

    @discardableResult
    func uploadPending(from store: PauseLogStore) async throws -> Int {
        guard !isUploading, Date() >= nextAttempt else {
            return 0
        }

        guard let user = UserInteractor().currentUser,
              let participantID = user.participantID,
              let experimentID = user.experimentID,
              let backend = BackendInteractor().currentBackendSettings else {
            return 0
        }

        let destination = (backend.api_write_url ?? "")
            .trimmingCharacters(in: .whitespacesAndNewlines)

        let apiKey = backend.api_write_key ?? ""

        // Keep records locally when no backend is configured.
        guard !destination.isEmpty, !apiKey.isEmpty else {
            return 0
        }

        guard let url = URL(string: destination),
              let scheme = url.scheme?.lowercased(),
              ["https", "http"].contains(scheme),
              url.host != nil else {
            throw PauseValidationError(
                message: "The pause log upload URL is invalid."
            )
        }

        let passwordID = user.passwordID ?? ""

        // Never send another participant's records to the current backend.
        let pending = Array(
            store.pendingEntries.filter {
                $0.destinationURL == destination
                    && $0.record.measurement == experimentID
                    && $0.record.tags.participantID == participantID
                    && $0.record.tags.passwordID == passwordID
            }.prefix(20)
        )

        guard !pending.isEmpty else {
            return 0
        }

        isUploading = true
        defer { isUploading = false }

        var uploadedCount = 0

        do {
            for entry in pending {
                // Recheck configuration before each request.
                let currentUser = UserInteractor().currentUser
                let currentBackend = BackendInteractor()
                    .currentBackendSettings

                let currentDestination = (currentBackend?.api_write_url ?? "")
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                guard currentUser?.participantID == participantID,
                      currentUser?.experimentID == experimentID,
                      (currentUser?.passwordID ?? "") == passwordID,
                      currentDestination == destination,
                      currentBackend?.api_write_key == apiKey else {
                    break
                }

                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.timeoutInterval = 30

                request.setValue(
                    "application/json",
                    forHTTPHeaderField: "Content-Type"
                )
                request.setValue(
                    "application/json",
                    forHTTPHeaderField: "Accept"
                )
                request.setValue(
                    apiKey,
                    forHTTPHeaderField: "x-api-key"
                )

                // Existing settings uploads use an array of records.
                request.httpBody = try JSONEncoder().encode([
                    entry.record
                ])

                let (_, response) = try await URLSession.shared.data(
                    for: request
                )

                guard let response = response as? HTTPURLResponse else {
                    throw PauseValidationError(
                        message: "The pause log server returned an invalid response."
                    )
                }

                guard (200...299).contains(response.statusCode) else {
                    throw PauseValidationError(
                        message:
                            "Pause log upload failed "
                            + "(HTTP \(response.statusCode))."
                    )
                }

                try store.markUploaded(
                    eventID: entry.record.fields.eventID
                )

                uploadedCount += 1
            }

            nextAttempt = Date().addingTimeInterval(60)
            return uploadedCount
        } catch {
            // Keep unsuccessful records for a later retry.
            nextAttempt = Date().addingTimeInterval(60)
            throw error
        }
    }
}
