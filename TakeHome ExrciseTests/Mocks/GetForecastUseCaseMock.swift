//
//  GetForecastUseCaseMock.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 09.11.2026.
//

@testable import TakeHome_Exrcise

final class GetForecastUseCaseMock: GetForecastUseCase {
    private let repository = ForecastRepositoryMock()
    
    func run(_ city: City) async throws -> WeatherForecast {
        try await repository.forecast(for: city)
    }
}
