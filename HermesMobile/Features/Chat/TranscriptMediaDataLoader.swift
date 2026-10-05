import Foundation

extension APIClient {
    func transcriptMediaData(for reference: TranscriptMediaReference, sessionID: String?) async throws -> Data {
        switch reference.source {
        case let .localPath(path):
            guard let sessionID else { throw TranscriptMediaPreviewError.missingSessionID }
            return try await mediaData(sessionID: sessionID, path: path)
        case let .remoteURL(url):
            return try await remoteTranscriptMediaData(from: url)
        }
    }

    /// Document previews use the same media routes and origin isolation, bounded to 25 MB.
    func transcriptMediaPreviewData(for reference: TranscriptMediaReference, sessionID: String?) async throws -> Data {
        switch reference.source {
        case let .localPath(path):
            guard let sessionID else { throw TranscriptMediaPreviewError.missingSessionID }
            return try await sendBoundedData(
                endpoint: .media(sessionID: sessionID, path: path), limit: BotArtifactBuffer.maximumBytes
            )
        case let .remoteURL(url):
            let sameOrigin = Self.isSameOrigin(url, as: baseURL)
            return try await downloadData(
                from: url, using: sameOrigin ? session : publicMediaSession,
                mapsUnauthorized: sameOrigin, limit: BotArtifactBuffer.maximumBytes
            )
        }
    }
}
