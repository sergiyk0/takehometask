//
//  NetworkError.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import Foundation

enum NetworkError: LocalizedError {
    case invalidURL
    case transport(URLError)
    case badStatus(code: Int, reason: String?)
    case invalidResponse
    case decoding(Error)
    case cancelled

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "The request URL is invalid."
        case .transport(let error):
            return error.localizedDescription
        case .badStatus(let code, let reason):
            return reason ?? "The server responded with status \(code)."
        case .invalidResponse:
            return "The server response was not valid."
        case .decoding:
            return "The server response could not be read."
        case .cancelled:
            return "The request was cancelled."
        }
    }
}
