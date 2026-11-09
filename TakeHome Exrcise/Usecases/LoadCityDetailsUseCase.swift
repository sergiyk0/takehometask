//
//  LoadCityDetailsUseCase.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

protocol LoadCityDetailsUseCase {
    func run(city: City) async throws -> CityDetails
}

class LoadCityDetailsUseCaseImpl: LoadCityDetailsUseCase {
    func run(city: City) async throws -> CityDetails {
        let forecast = try await UseCases.getForecastUseCase().run(city)
        let details = CityMapping.cityDetails(for: city, with: forecast)
        return details
    }
}
