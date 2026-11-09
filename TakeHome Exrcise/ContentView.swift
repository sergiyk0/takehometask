//
//  ContentView.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 03.11.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            CitiesSearchView()
                .navigationTitle("Search for city")
        }
    }
}


#Preview {
    ContentView()
}
