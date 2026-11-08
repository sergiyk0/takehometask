//
//  OpenMeteoEndpoint.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import Foundation

enum OpenMeteoEndpoint {
    static func searchCities(name: String, count: Int) -> Endpoint {
        Endpoint(
            host: "geocoding-api.open-meteo.com",
            path: "/v1/search",
            queryItems: [
                URLQueryItem(name: "name", value: name),
                URLQueryItem(name: "count", value: String(count)),
                URLQueryItem(name: "format", value: "json")
            ]
        )
    }

    static let currentVariables = [
        "temperature_2m", "relative_humidity_2m", "apparent_temperature", "is_day",
        "precipitation", "rain", "showers", "snowfall", "weather_code", "cloud_cover",
        "pressure_msl", "surface_pressure", "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m"
    ]

    static let hourlyVariables = [
        "temperature_2m", "relative_humidity_2m", "dew_point_2m", "apparent_temperature",
        "precipitation_probability", "precipitation", "rain", "showers", "snowfall", "snow_depth",
        "weather_code", "pressure_msl", "surface_pressure", "cloud_cover", "visibility",
        "wind_speed_10m", "wind_direction_10m", "wind_gusts_10m", "uv_index", "is_day"
    ]

    static let dailyVariables = [
        "weather_code", "temperature_2m_max", "temperature_2m_min",
        "apparent_temperature_max", "apparent_temperature_min", "sunrise", "sunset",
        "daylight_duration", "sunshine_duration", "uv_index_max",
        "precipitation_sum", "rain_sum", "showers_sum", "snowfall_sum", "precipitation_hours",
        "precipitation_probability_max", "wind_speed_10m_max", "wind_gusts_10m_max",
        "wind_direction_10m_dominant"
    ]

    static func forecast(for coordinate: Coordinate, options: ForecastOptions) -> Endpoint {
        Endpoint(
            host: "api.open-meteo.com",
            path: "/v1/forecast",
            queryItems: [
                URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
                URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
                URLQueryItem(name: "current", value: currentVariables.joined(separator: ",")),
                URLQueryItem(name: "hourly", value: hourlyVariables.joined(separator: ",")),
                URLQueryItem(name: "daily", value: dailyVariables.joined(separator: ",")),
                URLQueryItem(name: "timezone", value: "auto"),
                // Unix timestamps avoid ambiguous local-time string parsing.
                URLQueryItem(name: "timeformat", value: "unixtime"),
                URLQueryItem(name: "forecast_days", value: String(min(max(options.forecastDays, 1), 16))),
                URLQueryItem(name: "temperature_unit", value: options.temperatureUnit.rawValue),
                URLQueryItem(name: "wind_speed_unit", value: options.windSpeedUnit.rawValue),
                URLQueryItem(name: "precipitation_unit", value: options.precipitationUnit.rawValue)
            ]
        )
    }
}
