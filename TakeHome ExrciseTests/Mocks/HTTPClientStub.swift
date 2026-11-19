//
//  HTTPClientStub.swift
//  TakeHome ExrciseTests
//

import Foundation
@testable import TakeHome_Exrcise

/// Scriptable `HTTPClient` that records every request it receives.
final class HTTPClientStub: HTTPClient, @unchecked Sendable {
    enum Reply {
        case response(status: Int, body: String)
        case failure(Error)
    }

    var result: Reply
    private(set) var requests: [URLRequest] = []

    init(status: Int = 200, body: String = "{}") {
        self.result = .response(status: status, body: body)
    }

    init(failure: Error) {
        self.result = .failure(failure)
    }

    func send(_ request: URLRequest) async throws -> (Data, HTTPURLResponse) {
        requests.append(request)
        switch result {
        case .failure(let error):
            throw error
        case .response(let status, let body):
            let url = request.url ?? URL(string: "https://example.com")!
            let response = HTTPURLResponse(url: url, statusCode: status, httpVersion: nil, headerFields: nil)!
            return (Data(body.utf8), response)
        }
    }
}

enum TestFixtures {
    /// Open-Meteo style forecast payload (snake_case, unix timestamps, column-wise arrays).
    static let forecastJSON = """
    {
      "latitude": 45.4,
      "longitude": -75.7,
      "elevation": 70.0,
      "timezone": "America/Toronto",
      "utc_offset_seconds": -18000,
      "hourly": {
        "time": [1700000000, 1700003600],
        "temperature_2m": [1.5, null],
        "snow_depth": [0.4, 0.6],
        "visibility": [24140.0, 10000.0]
      },
      "daily": {
        "time": [1700000000],
        "temperature_2m_max": [3.2],
        "precipitation_probability_max": [15],
        "wind_speed_10m_max": [12.5]
      }
    }
    """

    static let citiesJSON = """
    {
      "results": [
        {"id": 6094817, "name": "Ottawa", "latitude": 45.41117, "longitude": -75.69812,
         "elevation": 70.0, "country": "Canada", "country_code": "CA",
         "admin1": "Ontario", "timezone": "America/Toronto", "population": 812129},
        {"id": 4117, "name": "Ottawa", "latitude": 38.61, "longitude": -95.27,
         "country": "United States", "country_code": "US", "admin1": "Kansas"}
      ]
    }
    """

    static func city(id: Int = 1,
                     name: String = "Ottawa",
                     latitude: Double = 45.4,
                     longitude: Double = -75.7,
                     country: String? = "Canada",
                     admin1: String? = "Ontario") -> City {
        City(id: id, name: name, latitude: latitude, longitude: longitude, elevation: nil,
             country: country, countryCode: nil, admin1: admin1, timezone: nil, population: nil)
    }

    static func hourly(_ date: Date,
                       snowDepth: Double? = nil,
                       visibility: Double? = nil) -> HourlyConditions {
        HourlyConditions(date: date, temperature: nil, apparentTemperature: nil, relativeHumidity: nil,
                         dewPoint: nil, precipitationProbability: nil, precipitation: nil, rain: nil,
                         showers: nil, snowfall: nil, snowDepth: snowDepth, weatherCode: nil,
                         pressureMSL: nil, surfacePressure: nil, cloudCover: nil, visibility: visibility,
                         windSpeed: nil, windDirection: nil, windGusts: nil, uvIndex: nil, isDay: nil)
    }

    static func daily(_ date: Date,
                      temperatureMax: Double? = nil,
                      precipitationProbabilityMax: Double? = nil,
                      windSpeedMax: Double? = nil) -> DailyConditions {
        DailyConditions(date: date, weatherCode: nil, temperatureMax: temperatureMax, temperatureMin: nil,
                        apparentTemperatureMax: nil, apparentTemperatureMin: nil, sunrise: nil, sunset: nil,
                        daylightDuration: nil, sunshineDuration: nil, uvIndexMax: nil, precipitationSum: nil,
                        rainSum: nil, showersSum: nil, snowfallSum: nil, precipitationHours: nil,
                        precipitationProbabilityMax: precipitationProbabilityMax, windSpeedMax: windSpeedMax,
                        windGustsMax: nil, windDirectionDominant: nil)
    }

    static func forecast(hourly: [HourlyConditions] = [],
                         daily: [DailyConditions] = []) -> WeatherForecast {
        WeatherForecast(coordinate: Coordinate(latitude: 0, longitude: 0), elevation: nil, timezone: "UTC",
                        utcOffsetSeconds: 0,
                        units: WeatherUnits(temperature: "°C", windSpeed: "km/h", precipitation: "mm"),
                        current: nil, hourly: hourly, daily: daily)
    }
}
