//
//  ForecastDayDetails.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 09.11.2026.
//

import Foundation

struct ForecastDayDetails: Identifiable {
    let id = UUID()
    let dateString: String
    let skiingLikelihoodString: String
    let surfingLikelihoodString: String
    let outdoorSightseeingLikelihoodString: String
    let indoorSightseeingLikelihoodString: String
}
