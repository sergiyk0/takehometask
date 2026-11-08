//
//  Forecast.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import Foundation

struct CurrentConditions: Sendable {
    let date: Date
    let temperature: Double?
    let apparentTemperature: Double?
    let relativeHumidity: Double?
    let isDay: Bool?
    let precipitation: Double?
    let rain: Double?
    let showers: Double?
    let snowfall: Double?
    let cloudCover: Double?
    let pressureMSL: Double?
    let surfacePressure: Double?
    let windSpeed: Double?
    let windDirection: Double?
    let windGusts: Double?
    let weatherCode: Int?

    var condition: WeatherCondition? { weatherCode.map(WeatherCondition.init(code:)) }
}

struct HourlyConditions: Sendable, Identifiable {
    var id: Date { date }
    let date: Date
    let temperature: Double?
    let apparentTemperature: Double?
    let relativeHumidity: Double?
    let dewPoint: Double?
    let precipitationProbability: Double?
    let precipitation: Double?
    let rain: Double?
    let showers: Double?
    let snowfall: Double?
    let snowDepth: Double?
    let weatherCode: Int?
    let pressureMSL: Double?
    let surfacePressure: Double?
    let cloudCover: Double?
    let visibility: Double?
    let windSpeed: Double?
    let windDirection: Double?
    let windGusts: Double?
    let uvIndex: Double?
    let isDay: Bool?

    var condition: WeatherCondition? { weatherCode.map(WeatherCondition.init(code:)) }
}

struct DailyConditions: Sendable, Identifiable {
    var id: Date { date }
    let date: Date
    let weatherCode: Int?
    let temperatureMax: Double?
    let temperatureMin: Double?
    let apparentTemperatureMax: Double?
    let apparentTemperatureMin: Double?
    let sunrise: Date?
    let sunset: Date?
    let daylightDuration: Double?     // seconds
    let sunshineDuration: Double?     // seconds
    let uvIndexMax: Double?
    let precipitationSum: Double?
    let rainSum: Double?
    let showersSum: Double?
    let snowfallSum: Double?
    let precipitationHours: Double?
    let precipitationProbabilityMax: Double?
    let windSpeedMax: Double?
    let windGustsMax: Double?
    let windDirectionDominant: Double?

    var condition: WeatherCondition? { weatherCode.map(WeatherCondition.init(code:)) }
}

struct WeatherForecast: Sendable {
    let coordinate: Coordinate
    let elevation: Double?
    let timezone: String
    let utcOffsetSeconds: Int
    let units: WeatherUnits
    let current: CurrentConditions?
    let hourly: [HourlyConditions]
    let daily: [DailyConditions]
}
