//
//  GetForecastUseCase.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 06.11.2026.
//

protocol GetForecastUseCase {
    func run(_ city: City) async throws -> WeatherForecast
}

class GetForecastUseCaseImpl: GetForecastUseCase {
    private let repository = ForecastRepository()
    
    func run(_ city: City) async throws -> WeatherForecast {
        try await repository.forecast(for: city)
    }
}
