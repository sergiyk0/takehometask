//
//  CitySearchViewModel.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 09.11.2026.
//

import Combine
import SwiftUI

class CitiesSearchViewModel: ObservableObject {
    @Published var searchResults: [City] = []
    @Published var query: String = "" {
        didSet {
            guard query != oldValue else { return }
            scheduleSearch()
        }
    }
    @Published var state: ViewModelState = .none
    
    private let findCityUseCase = UseCases.findCityUseCase()
    private var searchTask: Task<Void, Never>?
    private let minimumQueryLength = 2
    private let debounce: UInt64 = 300_000_000
    
    private func scheduleSearch() {
        searchTask?.cancel()
        let text = query.trimmingCharacters(in: .whitespacesAndNewlines)

        guard text.count >= minimumQueryLength else {
            state = .none
            return
        }

        searchTask = Task { [weak self, debounce] in
            try? await Task.sleep(nanoseconds: debounce)
            guard !Task.isCancelled, let self else { return }
            await self.performSearch(text)
        }
    }
    
    private func performSearch(_ text: String) async {
        state = .loading
        do {
            let result = try await findCityUseCase.run(text)
            guard !Task.isCancelled else { return }
            searchResults = result
            state = .ready
        } catch {
            guard !Task.isCancelled else { return }
            state = .error(error.localizedDescription)
        }
    }
}

