//
//  CityDetails.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import Foundation

struct CityDetails: Identifiable, Equatable {
    var id: UUID = UUID()
    var name: String
    var skiingLikelihoods: [Float]
    var surfingLikelihoods: [Float]
    var outdoorSightseeingLikelihoods: [Float]
    var indoorSightseeingLikelihoods: [Float]
    var dates: [Date]
}
