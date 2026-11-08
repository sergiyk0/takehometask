//
//  Units.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

enum TemperatureUnit: String, Sendable, CaseIterable {
    case celsius, fahrenheit
    var symbol: String { self == .celsius ? "°C" : "°F" }
}

enum WindSpeedUnit: String, Sendable, CaseIterable {
    case kmh, ms, mph, kn
    var symbol: String {
        switch self {
        case .kmh: return "km/h"
        case .ms: return "m/s"
        case .mph: return "mph"
        case .kn: return "kn"
        }
    }
}

enum PrecipitationUnit: String, Sendable, CaseIterable {
    case mm, inch
    var symbol: String { self == .mm ? "mm" : "in" }
}

struct ForecastOptions: Sendable, Equatable {
    var forecastDays: Int = 7          // Open-Meteo allows 1...16
    var temperatureUnit: TemperatureUnit = .celsius
    var windSpeedUnit: WindSpeedUnit = .kmh
    var precipitationUnit: PrecipitationUnit = .mm

    static let `default` = ForecastOptions()
}

/// Units the values in a `WeatherForecast` are expressed in.
struct WeatherUnits: Sendable, Equatable {
    let temperature: String
    let windSpeed: String
    let precipitation: String
    let pressure = "hPa"
    let visibility = "m"
    let percentage = "%"
}


