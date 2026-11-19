//
//  EndpointTests.swift
//  TakeHome ExrciseTests
//

import Foundation
import Testing
@testable import TakeHome_Exrcise

private func queryDictionary(_ endpoint: Endpoint) -> [String: String] {
    Dictionary(uniqueKeysWithValues: endpoint.queryItems.map { ($0.name, $0.value ?? "") })
}

// MARK: - Endpoint.makeRequest

struct EndpointTests {

    @Test func buildsHTTPSGetRequest() throws {
        let endpoint = Endpoint(host: "example.com", path: "/v1/thing",
                                queryItems: [URLQueryItem(name: "a", value: "1")])
        let request = try endpoint.makeRequest()

        #expect(request.url?.absoluteString == "https://example.com/v1/thing?a=1")
        #expect(request.httpMethod == "GET")
        #expect(request.timeoutInterval == 20)
        #expect(request.value(forHTTPHeaderField: "Accept") == "application/json")
    }

    @Test func omitsQuestionMarkWithoutQueryItems() throws {
        let request = try Endpoint(host: "example.com", path: "/ping").makeRequest()
        #expect(request.url?.absoluteString == "https://example.com/ping")
    }

    @Test func percentEncodesQueryValues() throws {
        let endpoint = Endpoint(host: "example.com", path: "/s",
                                queryItems: [URLQueryItem(name: "name", value: "New York")])
        let request = try endpoint.makeRequest()
        #expect(request.url?.absoluteString.contains("name=New%20York") == true)
    }

    @Test func pathWithoutLeadingSlashThrowsInvalidURL() {
        // URLComponents.url is nil when a host is set and the path doesn't start with "/".
        let endpoint = Endpoint(host: "example.com", path: "no-leading-slash")
        do {
            _ = try endpoint.makeRequest()
            Issue.record("Expected makeRequest to throw")
        } catch NetworkError.invalidURL {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

// MARK: - OpenMeteoEndpoint

struct OpenMeteoEndpointTests {

    @Test func searchCitiesEndpoint() {
        let endpoint = OpenMeteoEndpoint.searchCities(name: "Ottawa", count: 10)
        #expect(endpoint.host == "geocoding-api.open-meteo.com")
        #expect(endpoint.path == "/v1/search")
        #expect(queryDictionary(endpoint) == ["name": "Ottawa", "count": "10", "format": "json"])
    }

    @Test func searchCitiesRequestEncodesSpaces() throws {
        let request = try OpenMeteoEndpoint.searchCities(name: "New York", count: 5).makeRequest()
        #expect(request.url?.absoluteString.contains("name=New%20York") == true)
    }

    @Test func forecastEndpointUsesCoordinateAndDefaults() {
        let endpoint = OpenMeteoEndpoint.forecast(for: Coordinate(latitude: 45.5, longitude: -75.25),
                                                  options: .default)
        let query = queryDictionary(endpoint)

        #expect(endpoint.host == "api.open-meteo.com")
        #expect(endpoint.path == "/v1/forecast")
        #expect(query["latitude"] == "45.5")
        #expect(query["longitude"] == "-75.25")
        #expect(query["timezone"] == "auto")
        #expect(query["timeformat"] == "unixtime")
        #expect(query["forecast_days"] == "7")
        #expect(query["temperature_unit"] == "celsius")
        #expect(query["wind_speed_unit"] == "kmh")
        #expect(query["precipitation_unit"] == "mm")
    }

    @Test func forecastEndpointRequestsTheVariablesTheAppUses() {
        let query = queryDictionary(OpenMeteoEndpoint.forecast(for: Coordinate(latitude: 0, longitude: 0),
                                                              options: .default))
        #expect(query["hourly"] == "temperature_2m,snow_depth,visibility")
        #expect(query["daily"] == "temperature_2m_max,precipitation_probability_max,wind_speed_10m_max")
    }

    @Test func forecastEndpointHonoursCustomUnits() {
        let options = ForecastOptions(forecastDays: 3, temperatureUnit: .fahrenheit,
                                      windSpeedUnit: .mph, precipitationUnit: .inch)
        let query = queryDictionary(OpenMeteoEndpoint.forecast(for: Coordinate(latitude: 1, longitude: 2),
                                                              options: options))
        #expect(query["forecast_days"] == "3")
        #expect(query["temperature_unit"] == "fahrenheit")
        #expect(query["wind_speed_unit"] == "mph")
        #expect(query["precipitation_unit"] == "inch")
    }

    @Test func forecastDaysAreClampedToOneThroughSixteen() {
        func forecastDays(_ days: Int) -> String? {
            var options = ForecastOptions()
            options.forecastDays = days
            let endpoint = OpenMeteoEndpoint.forecast(for: Coordinate(latitude: 0, longitude: 0), options: options)
            return queryDictionary(endpoint)["forecast_days"]
        }
        #expect(forecastDays(-3) == "1")
        #expect(forecastDays(0) == "1")
        #expect(forecastDays(1) == "1")
        #expect(forecastDays(16) == "16")
        #expect(forecastDays(17) == "16")
        #expect(forecastDays(1000) == "16")
    }
}

// MARK: - NetworkError

struct NetworkErrorTests {

    @Test func descriptions() {
        #expect(NetworkError.invalidURL.errorDescription == "The request URL is invalid.")
        #expect(NetworkError.invalidResponse.errorDescription == "The server response was not valid.")
        #expect(NetworkError.cancelled.errorDescription == "The request was cancelled.")
        #expect(NetworkError.decoding(URLError(.cannotParseResponse)).errorDescription
                == "The server response could not be read.")
    }

    @Test func badStatusPrefersServerReason() {
        let error = NetworkError.badStatus(code: 400, reason: "Latitude must be in range")
        #expect(error.errorDescription == "Latitude must be in range")
    }

    @Test func badStatusFallsBackToStatusCode() {
        let error = NetworkError.badStatus(code: 503, reason: nil)
        #expect(error.errorDescription == "The server responded with status 503.")
    }

    @Test func transportUsesUnderlyingDescription() {
        let urlError = URLError(.notConnectedToInternet)
        #expect(NetworkError.transport(urlError).errorDescription == urlError.localizedDescription)
    }

    @Test func localizedDescriptionUsesErrorDescription() {
        #expect(NetworkError.invalidURL.localizedDescription == "The request URL is invalid.")
    }
}
