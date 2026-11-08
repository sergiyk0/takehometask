//
//  DTOs.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import Foundation

struct GeocodingResponseDTO: Decodable {
    let results: [City]?   // key is omitted entirely when nothing matches
}

struct ForecastResponseDTO: @MainActor Decodable {
    struct Current: Decodable {
        let time: Int
        let temperature2m: Double?
        let relativeHumidity2m: Double?
        let apparentTemperature: Double?
        let isDay: Int?
        let precipitation: Double?
        let rain: Double?
        let showers: Double?
        let snowfall: Double?
        let weatherCode: Int?
        let cloudCover: Double?
        let pressureMsl: Double?
        let surfacePressure: Double?
        let windSpeed10m: Double?
        let windDirection10m: Double?
        let windGusts10m: Double?
    }

    // Open-Meteo returns hourly/daily data column-wise: one array per variable.
    struct Hourly: Decodable {
        let time: [Int]
        let temperature2m: [Double?]?
        let relativeHumidity2m: [Double?]?
        let dewPoint2m: [Double?]?
        let apparentTemperature: [Double?]?
        let precipitationProbability: [Double?]?
        let precipitation: [Double?]?
        let rain: [Double?]?
        let showers: [Double?]?
        let snowfall: [Double?]?
        let snowDepth: [Double?]?
        let weatherCode: [Int?]?
        let pressureMsl: [Double?]?
        let surfacePressure: [Double?]?
        let cloudCover: [Double?]?
        let visibility: [Double?]?
        let windSpeed10m: [Double?]?
        let windDirection10m: [Double?]?
        let windGusts10m: [Double?]?
        let uvIndex: [Double?]?
        let isDay: [Int?]?
    }

    struct Daily: Decodable {
        let time: [Int]
        let weatherCode: [Int?]?
        let temperature2mMax: [Double?]?
        let temperature2mMin: [Double?]?
        let apparentTemperatureMax: [Double?]?
        let apparentTemperatureMin: [Double?]?
        let sunrise: [Int?]?
        let sunset: [Int?]?
        let daylightDuration: [Double?]?
        let sunshineDuration: [Double?]?
        let uvIndexMax: [Double?]?
        let precipitationSum: [Double?]?
        let rainSum: [Double?]?
        let showersSum: [Double?]?
        let snowfallSum: [Double?]?
        let precipitationHours: [Double?]?
        let precipitationProbabilityMax: [Double?]?
        let windSpeed10mMax: [Double?]?
        let windGusts10mMax: [Double?]?
        let windDirection10mDominant: [Double?]?
    }

    let latitude: Double
    let longitude: Double
    let elevation: Double?
    let timezone: String
    let utcOffsetSeconds: Int
    let current: Current?
    let hourly: Hourly?
    let daily: Daily?
}

func value<T>(_ array: [T?]?, _ index: Int) -> T? {
    guard let array, array.indices.contains(index) else { return nil }
    return array[index]
}

func date(_ unix: Int?) -> Date? {
    unix.map { Date(timeIntervalSince1970: TimeInterval($0)) }
}

extension ForecastResponseDTO {
    func toDomain(units: WeatherUnits) -> WeatherForecast {
        WeatherForecast(
            coordinate: Coordinate(latitude: latitude, longitude: longitude),
            elevation: elevation,
            timezone: timezone,
            utcOffsetSeconds: utcOffsetSeconds,
            units: units,
            current: current.map { c in
                CurrentConditions(
                    date: Date(timeIntervalSince1970: TimeInterval(c.time)),
                    temperature: c.temperature2m,
                    apparentTemperature: c.apparentTemperature,
                    relativeHumidity: c.relativeHumidity2m,
                    isDay: c.isDay.map { $0 == 1 },
                    precipitation: c.precipitation,
                    rain: c.rain,
                    showers: c.showers,
                    snowfall: c.snowfall,
                    cloudCover: c.cloudCover,
                    pressureMSL: c.pressureMsl,
                    surfacePressure: c.surfacePressure,
                    windSpeed: c.windSpeed10m,
                    windDirection: c.windDirection10m,
                    windGusts: c.windGusts10m,
                    weatherCode: c.weatherCode
                )
            },
            hourly: hourly?.toDomain() ?? [],
            daily: daily?.toDomain() ?? []
        )
    }
}

extension ForecastResponseDTO.Hourly {
    func toDomain() -> [HourlyConditions] {
        time.indices.map { i in
            HourlyConditions(
                date: Date(timeIntervalSince1970: TimeInterval(time[i])),
                temperature: value(temperature2m, i),
                apparentTemperature: value(apparentTemperature, i),
                relativeHumidity: value(relativeHumidity2m, i),
                dewPoint: value(dewPoint2m, i),
                precipitationProbability: value(precipitationProbability, i),
                precipitation: value(precipitation, i),
                rain: value(rain, i),
                showers: value(showers, i),
                snowfall: value(snowfall, i),
                snowDepth: value(snowDepth, i),
                weatherCode: value(weatherCode, i),
                pressureMSL: value(pressureMsl, i),
                surfacePressure: value(surfacePressure, i),
                cloudCover: value(cloudCover, i),
                visibility: value(visibility, i),
                windSpeed: value(windSpeed10m, i),
                windDirection: value(windDirection10m, i),
                windGusts: value(windGusts10m, i),
                uvIndex: value(uvIndex, i),
                isDay: value(isDay, i).map { $0 == 1 }
            )
        }
    }
}

extension ForecastResponseDTO.Daily {
    func toDomain() -> [DailyConditions] {
        time.indices.map { i in
            DailyConditions(
                date: Date(timeIntervalSince1970: TimeInterval(time[i])),
                weatherCode: value(weatherCode, i),
                temperatureMax: value(temperature2mMax, i),
                temperatureMin: value(temperature2mMin, i),
                apparentTemperatureMax: value(apparentTemperatureMax, i),
                apparentTemperatureMin: value(apparentTemperatureMin, i),
                sunrise: date(value(sunrise, i)),
                sunset: date(value(sunset, i)),
                daylightDuration: value(daylightDuration, i),
                sunshineDuration: value(sunshineDuration, i),
                uvIndexMax: value(uvIndexMax, i),
                precipitationSum: value(precipitationSum, i),
                rainSum: value(rainSum, i),
                showersSum: value(showersSum, i),
                snowfallSum: value(snowfallSum, i),
                precipitationHours: value(precipitationHours, i),
                precipitationProbabilityMax: value(precipitationProbabilityMax, i),
                windSpeedMax: value(windSpeed10mMax, i),
                windGustsMax: value(windGusts10mMax, i),
                windDirectionDominant: value(windDirection10mDominant, i)
            )
        }
    }
}
