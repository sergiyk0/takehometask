//
//  CitiesRepository.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 08.11.2026.
//

import Foundation

class CitiesRepository {
    var client = DefaultAPIClient()
    private var cache: Cache<String, [City]>
    private let defaultResultLimit = 10
    
    init(client: DefaultAPIClient = DefaultAPIClient(), cache: Cache<String, [City]> = Cache()) {
        self.client = client
        self.cache = cache
    }
    
    func searchCities(for query: String) async throws -> [City] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }
        if let result = cache.value(forKey: trimmed) {
            return result
        }
        let endpoint = OpenMeteoEndpoint.searchCities(name: trimmed, count: defaultResultLimit)
        let response = try await client.send(endpoint, as: GeocodingResponseDTO.self)
        guard let result = response.results else {
            return []
        }
        cache[trimmed] = result
        return result
    }
}
