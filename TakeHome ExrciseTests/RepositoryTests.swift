//
//  RepositoryTests.swift
//  TakeHome ExrciseTests
//

import Foundation
import Testing
@testable import TakeHome_Exrcise

private func queryValue(_ name: String, in request: URLRequest?) -> String? {
    guard let url = request?.url,
          let items = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems else { return nil }
    return items.first { $0.name == name }?.value
}

/// Mutable clock so cache expiry can be tested deterministically.
private final class TestClock {
    var now = Date(timeIntervalSince1970: 1_000_000)
}

// MARK: - CitiesRepository

struct CitiesRepositoryTests {

    private func makeRepository(_ stub: HTTPClientStub,
                                cache: Cache<String, [City]> = Cache()) -> CitiesRepository {
        CitiesRepository(client: DefaultAPIClient(http: stub), cache: cache)
    }

    @Test func returnsDecodedCities() async throws {
        let stub = HTTPClientStub(body: TestFixtures.citiesJSON)
        let cities = try await makeRepository(stub).searchCities(for: "Ottawa")

        #expect(cities.count == 2)
        #expect(cities.map(\.id) == [6094817, 4117])
    }

    @Test func requestsGeocodingEndpointWithResultLimit() async throws {
        let stub = HTTPClientStub(body: TestFixtures.citiesJSON)
        _ = try await makeRepository(stub).searchCities(for: "Ottawa")

        let request = try #require(stub.requests.first)
        #expect(request.url?.host == "geocoding-api.open-meteo.com")
        #expect(request.url?.path == "/v1/search")
        #expect(queryValue("name", in: request) == "Ottawa")
        #expect(queryValue("count", in: request) == "10")
    }

    @Test func blankQueryReturnsNothingWithoutCallingTheNetwork() async throws {
        let stub = HTTPClientStub(body: TestFixtures.citiesJSON)
        let repository = makeRepository(stub)

        #expect(try await repository.searchCities(for: "").isEmpty)
        #expect(try await repository.searchCities(for: "   \n\t ").isEmpty)
        #expect(stub.requests.isEmpty)
    }

    @Test func queryIsTrimmedBeforeSearching() async throws {
        let stub = HTTPClientStub(body: TestFixtures.citiesJSON)
        _ = try await makeRepository(stub).searchCities(for: "  Ottawa \n")
        #expect(queryValue("name", in: stub.requests.first) == "Ottawa")
    }

    @Test func noResultsReturnsEmptyArray() async throws {
        let stub = HTTPClientStub(body: "{}")
        let cities = try await makeRepository(stub).searchCities(for: "Qwertyuiop")
        #expect(cities.isEmpty)
    }

    @Test func repeatedQueryIsServedFromCache() async throws {
        let stub = HTTPClientStub(body: TestFixtures.citiesJSON)
        let repository = makeRepository(stub)

        let first = try await repository.searchCities(for: "Ottawa")
        let second = try await repository.searchCities(for: "Ottawa")

        #expect(stub.requests.count == 1)
        #expect(first.map(\.id) == second.map(\.id))
    }

    @Test func cacheKeyIgnoresSurroundingWhitespace() async throws {
        let stub = HTTPClientStub(body: TestFixtures.citiesJSON)
        let repository = makeRepository(stub)

        _ = try await repository.searchCities(for: "Ottawa")
        _ = try await repository.searchCities(for: " Ottawa ")

        #expect(stub.requests.count == 1)
    }

    @Test func differentQueriesAreCachedSeparately() async throws {
        let stub = HTTPClientStub(body: TestFixtures.citiesJSON)
        let repository = makeRepository(stub)

        _ = try await repository.searchCities(for: "Ottawa")
        _ = try await repository.searchCities(for: "Toronto")

        #expect(stub.requests.count == 2)
    }

    @Test func expiredCacheEntryIsRefetched() async throws {
        let clock = TestClock()
        let cache = Cache<String, [City]>(dateProvider: { clock.now }, entryLifetime: 60)
        let stub = HTTPClientStub(body: TestFixtures.citiesJSON)
        let repository = makeRepository(stub, cache: cache)

        _ = try await repository.searchCities(for: "Ottawa")
        clock.now.addTimeInterval(61)
        _ = try await repository.searchCities(for: "Ottawa")

        #expect(stub.requests.count == 2)
    }

    @Test func serverErrorsPropagate() async {
        let stub = HTTPClientStub(status: 500, body: #"{"error": true, "reason": "Server exploded"}"#)
        do {
            _ = try await makeRepository(stub).searchCities(for: "Ottawa")
            Issue.record("Expected an error")
        } catch NetworkError.badStatus(let code, let reason) {
            #expect(code == 500)
            #expect(reason == "Server exploded")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func failedRequestsAreNotCached() async throws {
        let stub = HTTPClientStub(status: 500, body: "{}")
        let repository = makeRepository(stub)

        await #expect(throws: (any Error).self) {
            _ = try await repository.searchCities(for: "Ottawa")
        }

        stub.result = .response(status: 200, body: TestFixtures.citiesJSON)
        let cities = try await repository.searchCities(for: "Ottawa")

        #expect(cities.count == 2)
        #expect(stub.requests.count == 2)
    }
}

// MARK: - ForecastRepository

struct ForecastRepositoryTests {

    private func makeRepository(_ stub: HTTPClientStub,
                                cache: Cache<City, WeatherForecast> = Cache()) -> ForecastRepository {
        ForecastRepository(client: DefaultAPIClient(http: stub), cache: cache)
    }

    @Test func returnsMappedForecast() async throws {
        let stub = HTTPClientStub(body: TestFixtures.forecastJSON)
        let forecast = try await makeRepository(stub).forecast(for: TestFixtures.city())

        #expect(forecast.timezone == "America/Toronto")
        #expect(forecast.hourly.count == 2)
        #expect(forecast.daily.count == 1)
        #expect(forecast.daily[0].temperatureMax == 3.2)
    }

    @Test func requestsForecastForTheCityCoordinates() async throws {
        let stub = HTTPClientStub(body: TestFixtures.forecastJSON)
        let city = TestFixtures.city(latitude: 52.5, longitude: 13.25)
        _ = try await makeRepository(stub).forecast(for: city)

        let request = try #require(stub.requests.first)
        #expect(request.url?.host == "api.open-meteo.com")
        #expect(request.url?.path == "/v1/forecast")
        #expect(queryValue("latitude", in: request) == "52.5")
        #expect(queryValue("longitude", in: request) == "13.25")
        #expect(queryValue("timeformat", in: request) == "unixtime")
    }

    @Test func defaultOptionsProduceMetricUnits() async throws {
        let stub = HTTPClientStub(body: TestFixtures.forecastJSON)
        let forecast = try await makeRepository(stub).forecast(for: TestFixtures.city())

        #expect(forecast.units.temperature == "°C")
        #expect(forecast.units.windSpeed == "km/h")
        #expect(forecast.units.precipitation == "mm")
    }

    @Test func customOptionsAreSentAndReflectedInUnits() async throws {
        let stub = HTTPClientStub(body: TestFixtures.forecastJSON)
        let options = ForecastOptions(forecastDays: 3, temperatureUnit: .fahrenheit,
                                      windSpeedUnit: .mph, precipitationUnit: .inch)
        let forecast = try await makeRepository(stub).forecast(for: TestFixtures.city(), options: options)

        #expect(queryValue("forecast_days", in: stub.requests.first) == "3")
        #expect(queryValue("temperature_unit", in: stub.requests.first) == "fahrenheit")
        #expect(forecast.units.temperature == "°F")
        #expect(forecast.units.windSpeed == "mph")
        #expect(forecast.units.precipitation == "in")
    }

    @Test func repeatedRequestForSameCityIsServedFromCache() async throws {
        let stub = HTTPClientStub(body: TestFixtures.forecastJSON)
        let repository = makeRepository(stub)
        let city = TestFixtures.city()

        _ = try await repository.forecast(for: city)
        _ = try await repository.forecast(for: city)

        #expect(stub.requests.count == 1)
    }

    @Test func differentCitiesAreCachedSeparately() async throws {
        let stub = HTTPClientStub(body: TestFixtures.forecastJSON)
        let repository = makeRepository(stub)

        _ = try await repository.forecast(for: TestFixtures.city(id: 1, name: "Ottawa"))
        _ = try await repository.forecast(for: TestFixtures.city(id: 2, name: "Toronto"))

        #expect(stub.requests.count == 2)
    }

    @Test func expiredCacheEntryIsRefetched() async throws {
        let clock = TestClock()
        let cache = Cache<City, WeatherForecast>(dateProvider: { clock.now }, entryLifetime: 60)
        let stub = HTTPClientStub(body: TestFixtures.forecastJSON)
        let repository = makeRepository(stub, cache: cache)
        let city = TestFixtures.city()

        _ = try await repository.forecast(for: city)
        clock.now.addTimeInterval(61)
        _ = try await repository.forecast(for: city)

        #expect(stub.requests.count == 2)
    }

    @Test func errorsPropagateAndAreNotCached() async throws {
        let stub = HTTPClientStub(status: 429, body: #"{"error": true, "reason": "Too many requests"}"#)
        let repository = makeRepository(stub)
        let city = TestFixtures.city()

        do {
            _ = try await repository.forecast(for: city)
            Issue.record("Expected an error")
        } catch NetworkError.badStatus(let code, let reason) {
            #expect(code == 429)
            #expect(reason == "Too many requests")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }

        stub.result = .response(status: 200, body: TestFixtures.forecastJSON)
        let forecast = try await repository.forecast(for: city)
        #expect(forecast.daily.count == 1)
        #expect(stub.requests.count == 2)
    }

    @Test func malformedPayloadSurfacesAsDecodingError() async {
        let stub = HTTPClientStub(body: #"{"unexpected": true}"#)
        do {
            _ = try await makeRepository(stub).forecast(for: TestFixtures.city())
            Issue.record("Expected an error")
        } catch NetworkError.decoding {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
