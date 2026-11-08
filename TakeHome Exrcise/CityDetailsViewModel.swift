//
//  CityDetailsViewModel.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import Combine
import SwiftUI

class CityDetailsViewModel: ObservableObject {
    enum State {
        case none
        case loading
        case error(String)
        case ready
    }
    @Published var cityName: String = ""
    @Published var skiingLikelihood: Float = 0
    @Published var surfingLikelihood: Float = 0
    @Published var outdoorSightseeingLikelihood: Float = 0
    @Published var indoorSightseeingLikelihood: Float = 0
    @Published var state: State = .none
    
    private var loadCityDetailsUseCase: LoadCityDetailsUseCase = UseCases.loadCityDetailsUseCase()
    private var city: City?
    
    func run() async {
        self.state = .loading
        do {
            guard let city  = self.city else {
                self.state = .error("No city provided")
                return
            }
            let cityDetails = try await loadCityDetailsUseCase.run(city: city)
            self.cityName = cityDetails.name
            self.skiingLikelihood = cityDetails.skiingLikelihood
            self.surfingLikelihood = cityDetails.surfingLikelihood
            self.outdoorSightseeingLikelihood = cityDetails.outdoorSightseeingLikelihood
            self.indoorSightseeingLikelihood = cityDetails.indoorSightseeingLikelihood
            self.state = .ready
        } catch let error as NetworkError {
            state = .error(error.errorDescription ?? error.localizedDescription)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}
