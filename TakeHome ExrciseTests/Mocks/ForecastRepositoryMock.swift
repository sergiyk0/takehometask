//
//  ForecastRepositoryMock.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 09.11.2026.
//

import Foundation
@testable import TakeHome_Exrcise

final class ForecastRepositoryMock: ForecastRepository {
    override func forecast(for city: City, options: ForecastOptions = .default) async throws -> WeatherForecast {
        switch city.name {
        case "Null":
            throw NetworkError.invalidURL
        default:
            return WeatherForecast(coordinate: Coordinate(latitude: 0, longitude: 0),
                                   elevation: 0,
                                   timezone: "GMT-5",
                                   utcOffsetSeconds: 5*60*60,
                                   units: .init(temperature: "C", windSpeed: "km/h", precipitation: "%"),
                                   current: nil,
                                   hourly: [],
                                   daily: [DailyConditions(date: Date(),
                                                           weatherCode: 0,
                                                           temperatureMax: 100,
                                                           temperatureMin: nil,
                                                           apparentTemperatureMax: nil,
                                                           apparentTemperatureMin: nil,
                                                           sunrise: nil,
                                                           sunset: nil,
                                                           daylightDuration: nil,
                                                           sunshineDuration: nil,
                                                           uvIndexMax: nil,
                                                           precipitationSum: nil,
                                                           rainSum: nil,
                                                           showersSum: nil,
                                                           snowfallSum: nil,
                                                           precipitationHours: nil,
                                                           precipitationProbabilityMax: nil,
                                                           windSpeedMax: nil,
                                                           windGustsMax: nil,
                                                           windDirectionDominant: nil)
                                   ])
        
        }
    }
}
