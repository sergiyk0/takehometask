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

    static let hourlyVariables = [
        "temperature_2m", "snow_depth", "visibility",
    ]

    static let dailyVariables = [
        "temperature_2m_max",
        "precipitation_probability_max", "wind_speed_10m_max"
    ]

    static func forecast(for coordinate: Coordinate, options: ForecastOptions) -> Endpoint {
        Endpoint(
            host: "api.open-meteo.com",
            path: "/v1/forecast",
            queryItems: [
                URLQueryItem(name: "latitude", value: String(coordinate.latitude)),
                URLQueryItem(name: "longitude", value: String(coordinate.longitude)),
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
