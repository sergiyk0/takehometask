//
//  FindCityByCoordinateUseCase.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 06.11.2026.
//

protocol FindCityUseCase {
    func run(_ name: String) async throws -> [City]
}

class FindCityUseCaseImpl: FindCityUseCase {
    private let citiesRepository = CitiesRepository()
    
    func run(_ name: String) async throws -> [City] {
        let result = try await citiesRepository.searchCities(for: name)
        return result
    }
}
