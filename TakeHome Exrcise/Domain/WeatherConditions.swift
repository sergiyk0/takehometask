//
//  WeatherConditions.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

/// WMO weather interpretation codes used by Open-Meteo.
enum WeatherCondition: Sendable, Equatable {
    case clear, mainlyClear, partlyCloudy, overcast
    case fog
    case drizzle, freezingDrizzle
    case rain, freezingRain, rainShowers
    case snow, snowGrains, snowShowers
    case thunderstorm, thunderstormWithHail
    case unknown(Int)

    init(code: Int) {
        switch code {
        case 0: self = .clear
        case 1: self = .mainlyClear
        case 2: self = .partlyCloudy
        case 3: self = .overcast
        case 45, 48: self = .fog
        case 51, 53, 55: self = .drizzle
        case 56, 57: self = .freezingDrizzle
        case 61, 63, 65: self = .rain
        case 66, 67: self = .freezingRain
        case 71, 73, 75: self = .snow
        case 77: self = .snowGrains
        case 80, 81, 82: self = .rainShowers
        case 85, 86: self = .snowShowers
        case 95: self = .thunderstorm
        case 96, 99: self = .thunderstormWithHail
        default: self = .unknown(code)
        }
    }

    var description: String {
        switch self {
        case .clear: return "Clear sky"
        case .mainlyClear: return "Mainly clear"
        case .partlyCloudy: return "Partly cloudy"
        case .overcast: return "Overcast"
        case .fog: return "Fog"
        case .drizzle: return "Drizzle"
        case .freezingDrizzle: return "Freezing drizzle"
        case .rain: return "Rain"
        case .freezingRain: return "Freezing rain"
        case .rainShowers: return "Rain showers"
        case .snow: return "Snow"
        case .snowGrains: return "Snow grains"
        case .snowShowers: return "Snow showers"
        case .thunderstorm: return "Thunderstorm"
        case .thunderstormWithHail: return "Thunderstorm with hail"
        case .unknown(let code): return "Unknown (\(code))"
        }
    }

    /// SF Symbol name.
    func symbolName(isDay: Bool = true) -> String {
        switch self {
        case .clear: return isDay ? "sun.max" : "moon.stars"
        case .mainlyClear, .partlyCloudy: return isDay ? "cloud.sun" : "cloud.moon"
        case .overcast: return "cloud"
        case .fog: return "cloud.fog"
        case .drizzle, .freezingDrizzle: return "cloud.drizzle"
        case .rain, .freezingRain: return "cloud.rain"
        case .rainShowers: return "cloud.heavyrain"
        case .snow, .snowGrains, .snowShowers: return "cloud.snow"
        case .thunderstorm: return "cloud.bolt.rain"
        case .thunderstormWithHail: return "cloud.bolt.rain.fill"
        case .unknown: return "questionmark.circle"
        }
    }
}
