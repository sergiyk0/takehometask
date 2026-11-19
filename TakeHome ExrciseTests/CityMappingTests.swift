//
//  CityMappingTests.swift
//  TakeHome ExrciseTests
//

import Foundation
import Testing
@testable import TakeHome_Exrcise

/// Tests for the activity-likelihood rules documented on `CityMapping`.
struct CityMappingTests {

    private let calendar = Calendar.current
    /// Midnight (local time) of a fixed day, so hourly samples always land on the same calendar day.
    private var day1: Date { calendar.startOfDay(for: Date(timeIntervalSince1970: 1_700_000_000)) }
    private var day2: Date { calendar.date(byAdding: .day, value: 1, to: day1)! }

    private func hour(_ hour: Int, of day: Date, snowDepth: Double? = nil, visibility: Double? = nil) -> HourlyConditions {
        let date = calendar.date(byAdding: .hour, value: hour, to: day)!
        return TestFixtures.hourly(date, snowDepth: snowDepth, visibility: visibility)
    }

    private func details(temperature: Double? = nil,
                         precipitation: Double? = nil,
                         wind: Double? = nil,
                         snowDepth: Double? = nil,
                         visibility: Double? = nil) -> CityDetails {
        let forecast = TestFixtures.forecast(
            hourly: [hour(12, of: day1, snowDepth: snowDepth, visibility: visibility)],
            daily: [TestFixtures.daily(day1, temperatureMax: temperature,
                                       precipitationProbabilityMax: precipitation, windSpeedMax: wind)])
        return CityMapping.cityDetails(for: TestFixtures.city(), with: forecast)
    }

    // MARK: Skiing — max temperature < 5 and snow depth > 0.3 (0.5 each)

    @Test func skiingIsCertainWhenColdWithDeepSnow() {
        #expect(details(temperature: 0, snowDepth: 0.5).skiingLikelihoods == [1.0])
    }

    @Test func skiingIsHalfLikelyWhenColdWithoutSnow() {
        #expect(details(temperature: 0, snowDepth: 0).skiingLikelihoods == [0.5])
    }

    @Test func skiingIsHalfLikelyWhenSnowyButWarm() {
        #expect(details(temperature: 10, snowDepth: 0.5).skiingLikelihoods == [0.5])
    }

    @Test func skiingIsImpossibleWhenWarmWithoutSnow() {
        #expect(details(temperature: 10, snowDepth: 0).skiingLikelihoods == [0.0])
    }

    @Test func skiingTemperatureThresholdIsExclusive() {
        #expect(details(temperature: 5, snowDepth: 0).skiingLikelihoods == [0.0])
        #expect(details(temperature: 4.9, snowDepth: 0).skiingLikelihoods == [0.5])
    }

    @Test func skiingSnowThresholdIsExclusive() {
        #expect(details(temperature: 10, snowDepth: 0.3).skiingLikelihoods == [0.0])
        #expect(details(temperature: 10, snowDepth: 0.31).skiingLikelihoods == [0.5])
    }

    // MARK: Surfing — max temperature > 20, wind > 5, precipitation probability < 20 (0.33 each)

    @Test func surfingIsMostLikelyWhenAllConditionsMet() throws {
        let value = try #require(details(temperature: 25, precipitation: 10, wind: 10).surfingLikelihoods.first)
        #expect(abs(value - 0.99) < 0.0001)
    }

    @Test func surfingIsZeroWhenNoConditionIsMet() {
        #expect(details(temperature: 10, precipitation: 50, wind: 1).surfingLikelihoods == [0.0])
    }

    @Test func eachSurfingConditionContributesAThird() throws {
        let warmOnly = try #require(details(temperature: 25, precipitation: 50, wind: 1).surfingLikelihoods.first)
        let windyOnly = try #require(details(temperature: 10, precipitation: 50, wind: 10).surfingLikelihoods.first)
        let dryOnly = try #require(details(temperature: 10, precipitation: 10, wind: 1).surfingLikelihoods.first)
        for value in [warmOnly, windyOnly, dryOnly] {
            #expect(abs(value - 0.33) < 0.0001)
        }
    }

    @Test func surfingThresholdsAreExclusive() {
        #expect(details(temperature: 20, precipitation: 20, wind: 5).surfingLikelihoods == [0.0])
    }

    // MARK: Sightseeing — precipitation probability < 40 and visibility > 10 km (0.5 each)

    @Test func outdoorSightseeingIsCertainWhenDryAndClear() {
        let result = details(precipitation: 10, visibility: 20_000)
        #expect(result.outdoorSightseeingLikelihoods == [1.0])
        #expect(result.indoorSightseeingLikelihoods == [0.0])
    }

    @Test func indoorSightseeingIsCertainWhenWetAndMisty() {
        let result = details(precipitation: 80, visibility: 5_000)
        #expect(result.outdoorSightseeingLikelihoods == [0.0])
        #expect(result.indoorSightseeingLikelihoods == [1.0])
    }

    @Test func mixedConditionsSplitSightseeingEvenly() {
        let dryButMisty = details(precipitation: 10, visibility: 5_000)
        #expect(dryButMisty.outdoorSightseeingLikelihoods == [0.5])
        #expect(dryButMisty.indoorSightseeingLikelihoods == [0.5])

        let clearButWet = details(precipitation: 80, visibility: 20_000)
        #expect(clearButWet.outdoorSightseeingLikelihoods == [0.5])
        #expect(clearButWet.indoorSightseeingLikelihoods == [0.5])
    }

    @Test func sightseeingThresholdsAreExclusive() {
        let result = details(precipitation: 40, visibility: 10_000)
        #expect(result.outdoorSightseeingLikelihoods == [0.0])
    }

    @Test func indoorAndOutdoorAlwaysSumToOne() {
        for precipitation in [0.0, 39.0, 40.0, 100.0] {
            for visibility in [0.0, 10_000.0, 30_000.0] {
                let result = details(precipitation: precipitation, visibility: visibility)
                #expect(result.outdoorSightseeingLikelihoods[0] + result.indoorSightseeingLikelihoods[0] == 1.0)
            }
        }
    }

    // MARK: Aggregation of hourly data

    @Test func hourlyValuesAreAveragedPerDay() {
        let forecast = TestFixtures.forecast(
            hourly: [hour(6, of: day1, snowDepth: 0.0, visibility: 4_000),
                     hour(12, of: day1, snowDepth: 0.5, visibility: 8_000)],
            daily: [TestFixtures.daily(day1, temperatureMax: 0, precipitationProbabilityMax: 100, windSpeedMax: 0)])
        let result = CityMapping.cityDetails(for: TestFixtures.city(), with: forecast)

        // snow depth averages 0.25 (<= 0.3) and visibility 6 km (<= 10 km), so only the cold bonus applies.
        #expect(result.skiingLikelihoods == [0.5])
        #expect(result.outdoorSightseeingLikelihoods == [0.0])
    }

    @Test func missingHourlyReadingsAreIgnoredWhenAveraging() {
        let forecast = TestFixtures.forecast(
            hourly: [hour(6, of: day1, snowDepth: nil, visibility: nil),
                     hour(12, of: day1, snowDepth: 0.5, visibility: 20_000)],
            daily: [TestFixtures.daily(day1, temperatureMax: 0, precipitationProbabilityMax: 0, windSpeedMax: 0)])
        let result = CityMapping.cityDetails(for: TestFixtures.city(), with: forecast)

        #expect(result.skiingLikelihoods == [1.0])
        #expect(result.outdoorSightseeingLikelihoods == [1.0])
    }

    @Test func eachDayUsesOnlyItsOwnHourlyData() {
        let forecast = TestFixtures.forecast(
            hourly: [hour(12, of: day1, snowDepth: 1.0, visibility: 30_000),
                     hour(12, of: day2, snowDepth: 0.0, visibility: 1_000)],
            daily: [TestFixtures.daily(day1, temperatureMax: 0, precipitationProbabilityMax: 0, windSpeedMax: 0),
                    TestFixtures.daily(day2, temperatureMax: 0, precipitationProbabilityMax: 0, windSpeedMax: 0)])
        let result = CityMapping.cityDetails(for: TestFixtures.city(), with: forecast)

        #expect(result.skiingLikelihoods == [1.0, 0.5])
        #expect(result.outdoorSightseeingLikelihoods == [1.0, 0.5])
    }

    // MARK: Output shape

    @Test func producesOneEntryPerForecastDay() {
        let forecast = TestFixtures.forecast(
            daily: [TestFixtures.daily(day1), TestFixtures.daily(day2)])
        let result = CityMapping.cityDetails(for: TestFixtures.city(), with: forecast)

        #expect(result.dates.count == 2)
        #expect(result.skiingLikelihoods.count == 2)
        #expect(result.surfingLikelihoods.count == 2)
        #expect(result.outdoorSightseeingLikelihoods.count == 2)
        #expect(result.indoorSightseeingLikelihoods.count == 2)
    }

    @Test func datesAreNormalisedToStartOfDay() {
        let afternoon = calendar.date(byAdding: .hour, value: 15, to: day1)!
        let forecast = TestFixtures.forecast(daily: [TestFixtures.daily(afternoon)])
        let result = CityMapping.cityDetails(for: TestFixtures.city(), with: forecast)
        #expect(result.dates == [day1])
    }

    @Test func usesTheCitysDisplayName() {
        let city = TestFixtures.city(name: "Wrocław", country: "Poland", admin1: "Lower Silesia")
        let result = CityMapping.cityDetails(for: city, with: TestFixtures.forecast())
        #expect(result.name == "Wrocław, Lower Silesia, Poland")
    }

    @Test func emptyForecastProducesEmptyDetails() {
        let result = CityMapping.cityDetails(for: TestFixtures.city(), with: TestFixtures.forecast())
        #expect(result.dates.isEmpty)
        #expect(result.skiingLikelihoods.isEmpty)
        #expect(result.surfingLikelihoods.isEmpty)
        #expect(result.outdoorSightseeingLikelihoods.isEmpty)
        #expect(result.indoorSightseeingLikelihoods.isEmpty)
    }

    // MARK: Missing data defaults

    /// Missing readings are treated as 0 (0 °C, 0 % precipitation, 0 km/h wind, no snow, no visibility).
    @Test func missingReadingsFallBackToZero() throws {
        let forecast = TestFixtures.forecast(daily: [TestFixtures.daily(day1)])
        let result = CityMapping.cityDetails(for: TestFixtures.city(), with: forecast)

        #expect(result.skiingLikelihoods == [0.5])                 // 0 °C counts as cold, but no snow data
        let surfing = try #require(result.surfingLikelihoods.first)
        #expect(abs(surfing - 0.33) < 0.0001)                      // only "low precipitation" is satisfied
        #expect(result.outdoorSightseeingLikelihoods == [0.5])     // low precipitation, but no visibility data
        #expect(result.indoorSightseeingLikelihoods == [0.5])
    }
}
