//
//  DomainTests.swift
//  TakeHome ExrciseTests
//

import Foundation
import Testing
@testable import TakeHome_Exrcise

// MARK: - City

struct CityTests {

    @Test func displayNameJoinsNameRegionAndCountry() {
        let city = TestFixtures.city(name: "Wrocław", country: "Poland", admin1: "Lower Silesia")
        #expect(city.displayName == "Wrocław, Lower Silesia, Poland")
    }

    @Test func displayNameSkipsMissingParts() {
        #expect(TestFixtures.city(country: "Canada", admin1: nil).displayName == "Ottawa, Canada")
        #expect(TestFixtures.city(country: nil, admin1: "Ontario").displayName == "Ottawa, Ontario")
        #expect(TestFixtures.city(country: nil, admin1: nil).displayName == "Ottawa")
    }

    @Test func displayNameSkipsEmptyParts() {
        let city = TestFixtures.city(country: "Canada", admin1: "")
        #expect(city.displayName == "Ottawa, Canada")
    }

    @Test func displayNameRemovesDuplicates() {
        let city = TestFixtures.city(name: "Singapore", country: "Singapore", admin1: "Singapore")
        #expect(city.displayName == "Singapore")

        let cityStateSame = TestFixtures.city(name: "New York", country: "United States", admin1: "New York")
        #expect(cityStateSame.displayName == "New York, United States")
    }

    @Test func coordinateMatchesLatitudeAndLongitude() {
        let city = TestFixtures.city(latitude: 12.5, longitude: -34.25)
        #expect(city.coordinate == Coordinate(latitude: 12.5, longitude: -34.25))
    }

    @Test func citiesWithDifferentIdsAreNotEqual() {
        #expect(TestFixtures.city(id: 1) != TestFixtures.city(id: 2))
        #expect(TestFixtures.city(id: 1) == TestFixtures.city(id: 1))
    }
}

// MARK: - WeatherCondition

struct WeatherConditionTests {

    @Test func mapsWMOCodes() {
        let cases: [(Int, WeatherCondition)] = [
            (0, .clear), (1, .mainlyClear), (2, .partlyCloudy), (3, .overcast),
            (45, .fog), (48, .fog),
            (51, .drizzle), (53, .drizzle), (55, .drizzle),
            (56, .freezingDrizzle), (57, .freezingDrizzle),
            (61, .rain), (63, .rain), (65, .rain),
            (66, .freezingRain), (67, .freezingRain),
            (71, .snow), (73, .snow), (75, .snow),
            (77, .snowGrains),
            (80, .rainShowers), (81, .rainShowers), (82, .rainShowers),
            (85, .snowShowers), (86, .snowShowers),
            (95, .thunderstorm),
            (96, .thunderstormWithHail), (99, .thunderstormWithHail)
        ]
        for (code, expected) in cases {
            #expect(WeatherCondition(code: code) == expected, "code \(code)")
        }
    }

    @Test func unknownCodesAreKept() {
        #expect(WeatherCondition(code: 42) == .unknown(42))
        #expect(WeatherCondition(code: -1) == .unknown(-1))
        #expect(WeatherCondition(code: 100) == .unknown(100))
    }

    @Test func descriptions() {
        #expect(WeatherCondition.clear.description == "Clear sky")
        #expect(WeatherCondition.thunderstormWithHail.description == "Thunderstorm with hail")
        #expect(WeatherCondition.unknown(42).description == "Unknown (42)")
    }

    @Test func symbolsDependOnDayAndNightWhereRelevant() {
        #expect(WeatherCondition.clear.symbolName(isDay: true) == "sun.max")
        #expect(WeatherCondition.clear.symbolName(isDay: false) == "moon.stars")
        #expect(WeatherCondition.partlyCloudy.symbolName(isDay: true) == "cloud.sun")
        #expect(WeatherCondition.mainlyClear.symbolName(isDay: false) == "cloud.moon")
    }

    @Test func symbolsAreStableForOtherConditions() {
        #expect(WeatherCondition.overcast.symbolName() == "cloud")
        #expect(WeatherCondition.snow.symbolName(isDay: false) == "cloud.snow")
        #expect(WeatherCondition.rain.symbolName() == "cloud.rain")
        #expect(WeatherCondition.unknown(7).symbolName() == "questionmark.circle")
    }

    @Test func daySymbolIsTheDefault() {
        #expect(WeatherCondition.clear.symbolName() == "sun.max")
    }

    @Test func forecastEntriesExposeTheirCondition() {
        let daily = TestFixtures.daily(.now)
        #expect(daily.condition == nil)

        let current = CurrentConditions(date: .now, temperature: nil, apparentTemperature: nil,
                                        relativeHumidity: nil, isDay: nil, precipitation: nil, rain: nil,
                                        showers: nil, snowfall: nil, cloudCover: nil, pressureMSL: nil,
                                        surfacePressure: nil, windSpeed: nil, windDirection: nil,
                                        windGusts: nil, weatherCode: 71)
        #expect(current.condition == .snow)
    }
}

// MARK: - Units

struct UnitsTests {

    @Test func temperatureSymbols() {
        #expect(TemperatureUnit.celsius.symbol == "°C")
        #expect(TemperatureUnit.fahrenheit.symbol == "°F")
    }

    @Test func windSpeedSymbols() {
        #expect(WindSpeedUnit.kmh.symbol == "km/h")
        #expect(WindSpeedUnit.ms.symbol == "m/s")
        #expect(WindSpeedUnit.mph.symbol == "mph")
        #expect(WindSpeedUnit.kn.symbol == "kn")
    }

    @Test func precipitationSymbols() {
        #expect(PrecipitationUnit.mm.symbol == "mm")
        #expect(PrecipitationUnit.inch.symbol == "in")
    }

    @Test func rawValuesMatchOpenMeteoQueryValues() {
        #expect(TemperatureUnit.fahrenheit.rawValue == "fahrenheit")
        #expect(WindSpeedUnit.kmh.rawValue == "kmh")
        #expect(PrecipitationUnit.inch.rawValue == "inch")
    }

    @Test func defaultForecastOptions() {
        let options = ForecastOptions.default
        #expect(options.forecastDays == 7)
        #expect(options.temperatureUnit == .celsius)
        #expect(options.windSpeedUnit == .kmh)
        #expect(options.precipitationUnit == .mm)
        #expect(options == ForecastOptions())
    }

    @Test func fixedWeatherUnits() {
        let units = WeatherUnits(temperature: "°C", windSpeed: "km/h", precipitation: "mm")
        #expect(units.pressure == "hPa")
        #expect(units.visibility == "m")
        #expect(units.percentage == "%")
    }
}
