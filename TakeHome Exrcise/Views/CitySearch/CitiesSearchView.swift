//
//  CitiesSearchView.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 09.11.2026.
//

import SwiftUI

struct CitiesSearchView: View {
    @ObservedObject var viewModel = CitiesSearchViewModel()
    
    var body: some View {
        List {
            switch viewModel.state {
            case .none:
                Text("Type at least 2 characters.")
                    .foregroundStyle(.secondary)
            case .loading:
                HStack(spacing: 8) {
                    ProgressView()
                    Text("Searching…").foregroundStyle(.secondary)
                }
            case .error(let message):
                Label(message, systemImage: "exclamationmark.triangle")
                    .foregroundStyle(.red)
            case .ready:
                if viewModel.searchResults.isEmpty {
                    Text("No cities found.").foregroundStyle(.secondary)
                }
                ForEach(viewModel.searchResults) { city in
                    NavigationLink() {
                        CityDetailsView(city: city)
                    } label: {
                        Text(city.name).font(.headline)
                        Text([city.admin1, city.country].compactMap { $0 }.joined(separator: ", "))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .listStyle(.plain)
        .searchable(
            text: Binding(
                get: { viewModel.query },
                set: { viewModel.query = $0 }
            ),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search city"
        )
    }
}
