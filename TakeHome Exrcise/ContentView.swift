//
//  ContentView.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 03.11.2026.
//

import SwiftUI

struct ContentView: View {
    @State var city: City?
    var body: some View {
        Group {
            if let city = city {
                CityDetailsView(city: city)
            } else {
                CitiesSearchView { city in
                    self.city = city
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
