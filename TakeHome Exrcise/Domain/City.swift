//
//  City.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

struct City: Identifiable, Hashable, Sendable, Decodable {
    let id: Int
    let name: String
    let latitude: Double
    let longitude: Double
    let elevation: Double?
    let country: String?
    let countryCode: String?
    let admin1: String?       // region / state
    let timezone: String?
    let population: Int?

    var coordinate: Coordinate { Coordinate(latitude: latitude, longitude: longitude) }

    /// e.g. "Wrocław, Lower Silesia, Poland"
    var displayName: String {
        [name, admin1, country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .reduce(into: [String]()) { if !$0.contains($1) { $0.append($1) } }
            .joined(separator: ", ")
    }
}
