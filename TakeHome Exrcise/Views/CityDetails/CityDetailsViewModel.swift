//
//  CityDetailsViewModel.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import Combine
import SwiftUI

@MainActor
class CityDetailsViewModel: ObservableObject {
    
    @Published var cityName: String = ""
    @Published var forecastDailyDetails: [ForecastDayDetails] = []
    var skiingLikelihoods: [Float] = []
    var surfingLikelihoods: [Float] = []
    var outdoorSightseeingLikelihoods: [Float] = []
    var indoorSightseeingLikelihoods: [Float] = []
    var datesStrings: [String] = []
    @Published var state: ViewModelState = .none
    
    private var loadCityDetailsUseCase: LoadCityDetailsUseCase = UseCases.loadCityDetailsUseCase()
    private var city: City?
    
    func run(_ city: City) {
        self.state = .loading
        Task {
            do {
                let cityDetails = try await loadCityDetailsUseCase.run(city: city)
                self.cityName = cityDetails.name
                self.skiingLikelihoods = cityDetails.skiingLikelihoods
                self.surfingLikelihoods = cityDetails.surfingLikelihoods
                self.outdoorSightseeingLikelihoods = cityDetails.outdoorSightseeingLikelihoods
                self.indoorSightseeingLikelihoods = cityDetails.indoorSightseeingLikelihoods
                let dateFormatter = DateFormatter()
                dateFormatter.dateStyle = .short
                dateFormatter.timeStyle = .none
                self.datesStrings = cityDetails.dates.map { dateFormatter.string(from:$0) }
                var dailyDetails = [ForecastDayDetails]()
                for i in 0..<datesStrings.count {
                    dailyDetails.append(ForecastDayDetails(dateString: datesStrings[i],
                                                           skiingLikelihoodString: "\(Int(skiingLikelihoods[i] * 100))%",
                                                           surfingLikelihoodString: "\(Int(surfingLikelihoods[i] * 100))%",
                                                           outdoorSightseeingLikelihoodString: "\(Int(outdoorSightseeingLikelihoods[i] * 100))%",
                                                           indoorSightseeingLikelihoodString: "\(Int(indoorSightseeingLikelihoods[i] * 100))%"))
                }
                self.forecastDailyDetails = dailyDetails
                self.state = .ready
            } catch let error as NetworkError {
                state = .error(error.errorDescription ?? error.localizedDescription)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
