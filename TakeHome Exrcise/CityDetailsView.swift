//
//  CityDetailsView.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 05.11.2026.
//

import SwiftUI

struct CityDetailsView: View {
    @ObservedObject private var viewModel = CityDetailsViewModel()
    
    var body: some View {
        Text(viewModel.cityName)
    }
}

#Preview {
    CityDetailsView()
}
