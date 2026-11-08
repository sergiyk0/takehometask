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
        
        return CityDetails(name: "", skiingLikelihood: 0, surfingLikelihood: 0, outdoorSightseeingLikelihood: 0, indoorSightseeingLikelihood: 0)
    }
}
