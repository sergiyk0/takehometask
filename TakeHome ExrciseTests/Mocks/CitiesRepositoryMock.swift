//
//  CitiesRepositoryMock.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 09.11.2026.
//

@testable import TakeHome_Exrcise

final class CitiesRepositoryMock: CitiesRepository {
    
    override func searchCities(for query: String) async throws -> [City] {
        switch query {
        case "Ottawa":
            var results = [City]()
            for i in 0..<5 {
                results.append(City(id: i, name: "Ottawa", latitude: 0, longitude: 0, elevation: 0, country: "Canada", countryCode: "CA", admin1: "Ontario", timezone: "GMT-5", population: 0))
            }
            return results
        case "Null":
            throw NetworkError.invalidURL
        default:
            return []
        }
    }
}
