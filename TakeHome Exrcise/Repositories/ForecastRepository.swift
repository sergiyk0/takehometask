//
//  ForecastRepository.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 08.11.2026.
//

class ForecastRepository {
    private let client: APIClient
    private var cache: Cache<City, WeatherForecast>

    init(client: APIClient = DefaultAPIClient(),
         cache: Cache<City, WeatherForecast> = Cache()) {
        self.client = client
        self.cache = cache
    }
    
    func forecast(for city: City, options: ForecastOptions = .default) async throws -> WeatherForecast {
        if let forecast = cache.value(forKey: city) {
            return forecast
        }
        let endpoint = OpenMeteoEndpoint.forecast(for: city.coordinate, options: options)
        let dto = try await client.send(endpoint, as: ForecastResponseDTO.self)
        let units = WeatherUnits(
            temperature: options.temperatureUnit.symbol,
            windSpeed: options.windSpeedUnit.symbol,
            precipitation: options.precipitationUnit.symbol
        )
        let forecast = dto.toDomain(units: units)
        cache[city] = forecast
        return forecast
    }
}
