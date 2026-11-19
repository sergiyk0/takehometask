//
//  DTOTests.swift
//  TakeHome ExrciseTests
//

import Foundation
import Testing
@testable import TakeHome_Exrcise

private let units = WeatherUnits(temperature: "°C", windSpeed: "km/h", precipitation: "mm")

private func decodeForecast(_ json: String) throws -> ForecastResponseDTO {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return try decoder.decode(ForecastResponseDTO.self, from: Data(json.utf8))
}

// MARK: - Helpers

struct DTOHelperTests {

    @Test func valueReturnsElementAtIndex() {
        let array: [Int?]? = [10, 20, 30]
        #expect(value(array, 0) == 10)
        #expect(value(array, 2) == 30)
    }

    @Test func valueIsNilWhenIndexIsOutOfRange() {
        let array: [Int?]? = [10, 20]
        #expect(value(array, 2) == nil)
        #expect(value(array, -1) == nil)
    }

    @Test func valueIsNilWhenArrayIsNil() {
        let array: [Int?]? = nil
        #expect(value(array, 0) == nil)
    }

    @Test func valueIsNilWhenElementIsNil() {
        let array: [Int?]? = [1, nil, 3]
        #expect(value(array, 1) == nil)
    }

    @Test func dateConvertsUnixTimestamps() {
        #expect(date(nil) == nil)
        #expect(date(0) == Date(timeIntervalSince1970: 0))
        #expect(date(1_700_000_000) == Date(timeIntervalSince1970: 1_700_000_000))
    }
}

// MARK: - Decoding

struct ForecastDecodingTests {

    @Test func decodesTopLevelFields() throws {
        let dto = try decodeForecast(TestFixtures.forecastJSON)
        #expect(dto.latitude == 45.4)
        #expect(dto.longitude == -75.7)
        #expect(dto.elevation == 70.0)
        #expect(dto.timezone == "America/Toronto")
        #expect(dto.utcOffsetSeconds == -18000)
        #expect(dto.current == nil)
    }

    @Test func decodesColumnWiseHourlyAndDailyData() throws {
        let dto = try decodeForecast(TestFixtures.forecastJSON)
        #expect(dto.hourly?.time == [1_700_000_000, 1_700_003_600])
        #expect(dto.hourly?.snowDepth == [0.4, 0.6])
        #expect(dto.daily?.time == [1_700_000_000])
        #expect(dto.daily?.temperature2MMax == [3.2])
        #expect(dto.daily?.windSpeed10MMax == [12.5])
    }

    @Test func nullEntriesAreDecodedAsNil() throws {
        let dto = try decodeForecast(TestFixtures.forecastJSON)
        let temperatures = try #require(dto.hourly?.temperature2M)
        #expect(temperatures.count == 2)
        #expect(temperatures[0] == 1.5)
        #expect(temperatures[1] == nil)
    }

    @Test func missingSectionsAreNil() throws {
        let dto = try decodeForecast("""
        {"latitude": 1, "longitude": 2, "timezone": "UTC", "utc_offset_seconds": 0}
        """)
        #expect(dto.hourly == nil)
        #expect(dto.daily == nil)
        #expect(dto.elevation == nil)
    }

    @Test func missingRequiredFieldFails() {
        #expect(throws: (any Error).self) {
            _ = try decodeForecast(#"{"latitude": 1, "longitude": 2}"#)
        }
    }
}

// MARK: - toDomain

struct ForecastMappingTests {

    @Test func mapsTopLevelFields() throws {
        let forecast = try decodeForecast(TestFixtures.forecastJSON).toDomain(units: units)
        #expect(forecast.coordinate == Coordinate(latitude: 45.4, longitude: -75.7))
        #expect(forecast.elevation == 70.0)
        #expect(forecast.timezone == "America/Toronto")
        #expect(forecast.utcOffsetSeconds == -18000)
        #expect(forecast.units == units)
        #expect(forecast.current == nil)
    }

    @Test func mapsHourlyConditions() throws {
        let forecast = try decodeForecast(TestFixtures.forecastJSON).toDomain(units: units)

        #expect(forecast.hourly.count == 2)
        #expect(forecast.hourly[0].date == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(forecast.hourly[0].temperature == 1.5)
        #expect(forecast.hourly[0].snowDepth == 0.4)
        #expect(forecast.hourly[0].visibility == 24140.0)
        #expect(forecast.hourly[1].date == Date(timeIntervalSince1970: 1_700_003_600))
        #expect(forecast.hourly[1].temperature == nil)
        #expect(forecast.hourly[1].snowDepth == 0.6)
        #expect(forecast.hourly[1].visibility == 10000.0)
    }

    @Test func variablesThatWereNotRequestedAreNil() throws {
        let forecast = try decodeForecast(TestFixtures.forecastJSON).toDomain(units: units)
        #expect(forecast.hourly[0].windSpeed == nil)
        #expect(forecast.hourly[0].uvIndex == nil)
        #expect(forecast.hourly[0].isDay == nil)
        #expect(forecast.daily[0].sunrise == nil)
        #expect(forecast.daily[0].weatherCode == nil)
        #expect(forecast.daily[0].condition == nil)
    }

    @Test func mapsDailyConditions() throws {
        let forecast = try decodeForecast(TestFixtures.forecastJSON).toDomain(units: units)

        #expect(forecast.daily.count == 1)
        #expect(forecast.daily[0].date == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(forecast.daily[0].temperatureMax == 3.2)
        #expect(forecast.daily[0].precipitationProbabilityMax == 15)
        #expect(forecast.daily[0].windSpeedMax == 12.5)
    }

    @Test func missingSectionsMapToEmptyArrays() throws {
        let dto = try decodeForecast("""
        {"latitude": 1, "longitude": 2, "timezone": "UTC", "utc_offset_seconds": 0}
        """)
        let forecast = dto.toDomain(units: units)
        #expect(forecast.hourly.isEmpty)
        #expect(forecast.daily.isEmpty)
    }

    @Test func columnsShorterThanTimeYieldNilForMissingRows() throws {
        let dto = try decodeForecast("""
        {"latitude": 1, "longitude": 2, "timezone": "UTC", "utc_offset_seconds": 0,
         "hourly": {"time": [100, 200, 300], "temperature_2m": [5.0]}}
        """)
        let hourly = dto.toDomain(units: units).hourly
        #expect(hourly.count == 3)
        #expect(hourly[0].temperature == 5.0)
        #expect(hourly[1].temperature == nil)
        #expect(hourly[2].temperature == nil)
    }

    @Test func mapsCurrentConditions() throws {
        let dto = try decodeForecast("""
        {"latitude": 1, "longitude": 2, "timezone": "UTC", "utc_offset_seconds": 0,
         "current": {"time": 1700000000, "temperature_2m": 4.5, "is_day": 1,
                     "weather_code": 61, "wind_speed_10m": 9.0}}
        """)
        let current = try #require(dto.toDomain(units: units).current)

        #expect(current.date == Date(timeIntervalSince1970: 1_700_000_000))
        #expect(current.temperature == 4.5)
        #expect(current.windSpeed == 9.0)
        #expect(current.isDay == true)
        #expect(current.weatherCode == 61)
        #expect(current.condition == .rain)
        #expect(current.rain == nil)
    }

    @Test func isDayZeroMapsToFalse() throws {
        let dto = try decodeForecast("""
        {"latitude": 1, "longitude": 2, "timezone": "UTC", "utc_offset_seconds": 0,
         "current": {"time": 0, "is_day": 0}}
        """)
        #expect(dto.toDomain(units: units).current?.isDay == false)
    }
}

// MARK: - Geocoding

struct GeocodingDecodingTests {

    @Test func decodesCitiesWithOptionalFieldsMissing() throws {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let dto = try decoder.decode(GeocodingResponseDTO.self, from: Data(TestFixtures.citiesJSON.utf8))

        let kansas = try #require(dto.results?.last)
        #expect(kansas.name == "Ottawa")
        #expect(kansas.admin1 == "Kansas")
        #expect(kansas.countryCode == "US")
        #expect(kansas.population == nil)
        #expect(kansas.displayName == "Ottawa, Kansas, United States")
    }
}
