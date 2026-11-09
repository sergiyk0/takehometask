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
    @Published var skiingLikelihoods: [Float] = []
    @Published var surfingLikelihoods: [Float] = []
    @Published var outdoorSightseeingLikelihoods: [Float] = []
    @Published var indoorSightseeingLikelihoods: [Float] = []
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
                self.state = .ready
            } catch let error as NetworkError {
                state = .error(error.errorDescription ?? error.localizedDescription)
            } catch {
                state = .error(error.localizedDescription)
            }
        }
    }
}
