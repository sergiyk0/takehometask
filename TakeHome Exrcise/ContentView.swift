//
//  ContentView.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 03.11.2026.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ScrollView {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
