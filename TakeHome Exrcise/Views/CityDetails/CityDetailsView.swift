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
        Text(viewModel.cityName)
            .onAppear {
                viewModel.run(city)
            }
    }
}
