//
//  CityDetailsView.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import SwiftUI

struct CityDetailsView: View {
    @ObservedObject private var viewModel = CityDetailsViewModel()
    let city: City
    
    var body: some View {
        VStack {
            switch viewModel.state {
            case .none:
                Text(viewModel.cityName)
                    .foregroundStyle(.primary)
            case .loading:
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Loading…").foregroundStyle(.secondary)
                }
                case .error(let message):
                    Label(message, systemImage: "exclamationmark.triangle")
                        .foregroundStyle(.red)
            case .ready:
                if viewModel.forecastDailyDetails.isEmpty {
                    Text("No forecast found.").foregroundStyle(.secondary)
                }
                HStack {
                    VStack {
                        Text("Date")
                        ForEach(viewModel.forecastDailyDetails) { details in
                            Text(details.dateString)
                                .foregroundStyle(.secondary)
                        }
                    }
                    VStack {
                        Text("Skiing")
                        ForEach(viewModel.forecastDailyDetails) { details in
                            Text(details.skiingLikelihoodString)
                                .foregroundStyle(.secondary)
                        }
                    }
                    VStack {
                        Text("Surfing")
                        ForEach(viewModel.forecastDailyDetails) { details in
                            Text(details.surfingLikelihoodString)
                                .foregroundStyle(.secondary)
                        }
                    }
                    VStack {
                        Text("Outdoors")
                        ForEach(viewModel.forecastDailyDetails) { details in
                            Text(details.outdoorSightseeingLikelihoodString)
                                .foregroundStyle(.secondary)
                        }
                    }
                    VStack {
                        Text("Indoors")
                        ForEach(viewModel.forecastDailyDetails) { details in
                            Text(details.indoorSightseeingLikelihoodString)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.run(city)
        }
        .navigationTitle(city.name)
    }
}


