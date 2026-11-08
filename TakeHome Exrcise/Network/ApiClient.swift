//
//  ApiClient.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import Foundation

/// Sends an endpoint and decodes the JSON body.
protocol APIClient: Sendable {
    func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T
}

struct DefaultAPIClient: APIClient {
    private let http: HTTPClient

    init(http: HTTPClient = URLSessionHTTPClient()) {
        self.http = http
    }

    func send<T: Decodable>(_ endpoint: Endpoint, as type: T.Type) async throws -> T {
        let request = try endpoint.makeRequest()
        let (data, response) = try await http.send(request)

        guard (200..<300).contains(response.statusCode) else {
            // Open-Meteo reports errors as {"error": true, "reason": "..."}
            let reason = (try? JSONDecoder().decode(OpenMeteoErrorBody.self, from: data))?.reason
            throw NetworkError.badStatus(code: response.statusCode, reason: reason)
        }

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding(error)
        }
    }
}

private struct OpenMeteoErrorBody: Decodable {
    let reason: String?
}
