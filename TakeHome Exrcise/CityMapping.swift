//
//  CityMapping.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 07.11.2026.
//

import Foundation

/// Class for mapping forecast conditions to likelihoods of activities
/// For simplicity we use following mapping
/// `skiing` - temperature below 5 degrees and snow depth above 30 cm
/// `surfing` - temperature above 20, wind speed above 5 km/h and precipitation probability below 20%
/// `oudoor sightseeing` - precipitation probability below 40% and visibility above 10 km
/// `indoor sightseeing` - directly opposite of indoor sightseeing
class CityMapping {
    class func cityDetails(for city: City, with forecast: WeatherForecast) -> CityDetails {
        let dates = forecast.daily.map { Calendar.current.startOfDay(for: $0.date) }
        let hourlyConditionsByDay = hourlyConditionsByDay(hourlyConditions: forecast.hourly)
        let snowDepths = dates.map{ hourlyConditionsByDay[$0]?.compactMap{ $0.snowDepth }.average() ?? 0 }
        let visibilities = dates.map{ hourlyConditionsByDay[$0]?.compactMap{ $0.visibility }.average() ?? 0 }
        let precipitationProbabilities = forecast.daily.map{ $0.precipitationProbabilityMax ?? 0 }
        let maxTemperatures = forecast.daily.map{ $0.temperatureMax ?? 0 }
        let windSpeeds = forecast.daily.map { $0.windSpeedMax ?? 0 }
        var skiingLikelihoods = [Float]()
        var surfingLikelihoods = [Float]()
        var outdoorSightseeingLikelihoods = [Float]()
        var indoorSightseeingLikelihoods = [Float]()
        
        for (i, _) in dates.enumerated() {
            skiingLikelihoods.append(Float((maxTemperatures[i] < 5 ? 0.5 : 0) + (snowDepths[i] > 0.3 ? 0.5 : 0)))
            surfingLikelihoods.append(Float((maxTemperatures[i] > 20 ? 0.33 : 0) + (windSpeeds[i] > 5 ? 0.33 : 0) + (precipitationProbabilities[i] < 20 ? 0.33 : 0)))
            let outdoorsSightseeingLikelihood = (precipitationProbabilities[i] < 40 ? 0.5 : 0) + (visibilities[i] > 10000 ? 0.5 : 0)
            outdoorSightseeingLikelihoods.append(Float(outdoorsSightseeingLikelihood))
            indoorSightseeingLikelihoods.append(Float(1.0 - outdoorsSightseeingLikelihood))
        }
        return CityDetails(name: city.displayName,
                           skiingLikelihoods: skiingLikelihoods,
                           surfingLikelihoods: surfingLikelihoods,
                           outdoorSightseeingLikelihoods: outdoorSightseeingLikelihoods,
                           indoorSightseeingLikelihoods: indoorSightseeingLikelihoods,
                           dates: dates)
    }
    
    private class func hourlyConditionsByDay(hourlyConditions: [HourlyConditions]) -> [Date: [HourlyConditions]] {
        return Dictionary(grouping: hourlyConditions) { Calendar.current.startOfDay(for: $0.date) }
    }
}
