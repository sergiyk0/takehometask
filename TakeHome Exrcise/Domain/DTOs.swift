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

struct ForecastResponseDTO: Decodable {
    struct Current: Decodable {
        let time: Int
        let temperature2M: Double?
        let relativeHumidity2M: Double?
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
        let windSpeed10M: Double?
        let windDirection10M: Double?
        let windGusts10M: Double?
    }

    // Open-Meteo returns hourly/daily data column-wise: one array per variable.
    struct Hourly: Decodable {
        let time: [Int]
        let temperature2M: [Double?]?
        let relativeHumidity2M: [Double?]?
        let dewPoint2M: [Double?]?
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
        let windSpeed10M: [Double?]?
        let windDirection10M: [Double?]?
        let windGusts10M: [Double?]?
        let uvIndex: [Double?]?
        let isDay: [Int?]?
    }

    struct Daily: Decodable {
        let time: [Int]
        let weatherCode: [Int?]?
        let temperature2MMax: [Double?]?
        let temperature2MMin: [Double?]?
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
        let windSpeed10MMax: [Double?]?
        let windGusts10MMax: [Double?]?
        let windDirection10MDominant: [Double?]?
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
                    temperature: c.temperature2M,
                    apparentTemperature: c.apparentTemperature,
                    relativeHumidity: c.relativeHumidity2M,
                    isDay: c.isDay.map { $0 == 1 },
                    precipitation: c.precipitation,
                    rain: c.rain,
                    showers: c.showers,
                    snowfall: c.snowfall,
                    cloudCover: c.cloudCover,
                    pressureMSL: c.pressureMsl,
                    surfacePressure: c.surfacePressure,
                    windSpeed: c.windSpeed10M,
                    windDirection: c.windDirection10M,
                    windGusts: c.windGusts10M,
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
                temperature: value(temperature2M, i),
                apparentTemperature: value(apparentTemperature, i),
                relativeHumidity: value(relativeHumidity2M, i),
                dewPoint: value(dewPoint2M, i),
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
                windSpeed: value(windSpeed10M, i),
                windDirection: value(windDirection10M, i),
                windGusts: value(windGusts10M, i),
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
                temperatureMax: value(temperature2MMax, i),
                temperatureMin: value(temperature2MMin, i),
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
                windSpeedMax: value(windSpeed10MMax, i),
                windGustsMax: value(windGusts10MMax, i),
                windDirectionDominant: value(windDirection10MDominant, i)
            )
        }
    }
}
