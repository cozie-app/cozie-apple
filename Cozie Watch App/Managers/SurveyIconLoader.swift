//
//  SurveyIconLoader.swift
//  Cozie Watch App
//

import CryptoKit
import Foundation
import SwiftUI

enum SurveyIconLoaderError: LocalizedError {
    case invalidURL
    case insecureURL
    case invalidResponse
    case invalidStatusCode(Int)
    case unsupportedContentType
    case imageTooLarge
    case invalidImageData

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The survey icon URL is invalid."
        case .insecureURL:
            return "Survey icons must use HTTPS."
        case .invalidResponse:
            return "The survey icon response is invalid."
        case .invalidStatusCode(let statusCode):
            return "The survey icon request failed with status code \(statusCode)."
        case .unsupportedContentType:
            return "The survey icon response is not an image."
        case .imageTooLarge:
            return "The survey icon is larger than the allowed size."
        case .invalidImageData:
            return "The downloaded survey icon could not be decoded."
        }
    }
}

actor SurveyIconLoader {
    static let shared = SurveyIconLoader()

    private let maximumImageSize = 512 * 1_024
    private let memoryCache = NSCache<NSString, UIImage>()
    private let cacheDirectory: URL
    private let session: URLSession

    init(fileManager: FileManager = .default) {
        let baseDirectory = fileManager.urls(for: .cachesDirectory,
                                             in: .userDomainMask)[0]
        cacheDirectory = baseDirectory.appendingPathComponent(
            "SurveyIcons",
            isDirectory: true
        )
        try? fileManager.createDirectory(
            at: cacheDirectory,
            withIntermediateDirectories: true
        )

        let configuration = URLSessionConfiguration.default
        configuration.requestCachePolicy = .returnCacheDataElseLoad
        configuration.timeoutIntervalForRequest = 15
        configuration.timeoutIntervalForResource = 30
        session = URLSession(configuration: configuration)
    }

    func image(from urlString: String) async throws -> UIImage {
        guard let url = URL(string: urlString), url.host != nil else {
            throw SurveyIconLoaderError.invalidURL
        }
        guard url.scheme?.lowercased() == "https" else {
            throw SurveyIconLoaderError.insecureURL
        }

        let cacheKey = cacheKey(for: url)
        if let cachedImage = memoryCache.object(forKey: cacheKey as NSString) {
            return cachedImage
        }

        let fileURL = cacheDirectory.appendingPathComponent(cacheKey)
        if let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            memoryCache.setObject(image, forKey: cacheKey as NSString)
            return image
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15
        let (data, response) = try await session.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SurveyIconLoaderError.invalidResponse
        }
        guard (200...299).contains(httpResponse.statusCode) else {
            throw SurveyIconLoaderError.invalidStatusCode(httpResponse.statusCode)
        }
        guard httpResponse.mimeType?.hasPrefix("image/") == true else {
            throw SurveyIconLoaderError.unsupportedContentType
        }
        guard data.count <= maximumImageSize else {
            throw SurveyIconLoaderError.imageTooLarge
        }
        guard let image = UIImage(data: data) else {
            throw SurveyIconLoaderError.invalidImageData
        }

        try data.write(to: fileURL, options: .atomic)
        memoryCache.setObject(image, forKey: cacheKey as NSString)
        return image
    }

    private func cacheKey(for url: URL) -> String {
        let digest = SHA256.hash(data: Data(url.absoluteString.utf8))
        return digest.map { String(format: "%02x", $0) }.joined()
    }
}
