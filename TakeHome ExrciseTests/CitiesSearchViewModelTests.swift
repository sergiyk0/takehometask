//
//  CitiesSearchViewModelTests.swift
//  TakeHome ExrciseTests
//

import Testing
@testable import TakeHome_Exrcise

/// Only the synchronous, network-free behaviour of the view model is covered here:
/// `CitiesSearchViewModel` creates its use case internally, so any query long enough to
/// trigger a search would hit the real API once the debounce elapses.
/// These tests always cancel or avoid that path before the debounce fires.
@MainActor
struct CitiesSearchViewModelTests {

    private func isNone(_ state: ViewModelState) -> Bool {
        if case .none = state { return true }
        return false
    }

    @Test func startsIdle() {
        let viewModel = CitiesSearchViewModel()
        #expect(viewModel.query.isEmpty)
        #expect(viewModel.searchResults.isEmpty)
        #expect(isNone(viewModel.state))
    }

    @Test func queryShorterThanTwoCharactersStaysIdle() {
        let viewModel = CitiesSearchViewModel()
        viewModel.query = "a"
        #expect(isNone(viewModel.state))
        #expect(viewModel.searchResults.isEmpty)
    }

    @Test func whitespaceOnlyQueryStaysIdle() {
        let viewModel = CitiesSearchViewModel()
        viewModel.query = "      "
        #expect(isNone(viewModel.state))
    }

    @Test func paddingDoesNotCountTowardsMinimumLength() {
        let viewModel = CitiesSearchViewModel()
        viewModel.query = "  a  "
        #expect(isNone(viewModel.state))
    }

    @Test func shorteningQueryCancelsPendingSearchAndResetsState() {
        let viewModel = CitiesSearchViewModel()
        viewModel.query = "ab"   // schedules a debounced search (cannot run before this test yields)
        viewModel.query = "a"    // cancels it and resets the state
        #expect(isNone(viewModel.state))
        #expect(viewModel.searchResults.isEmpty)
    }

    @Test func clearingQueryCancelsPendingSearch() {
        let viewModel = CitiesSearchViewModel()
        viewModel.query = "ot"
        viewModel.query = ""
        #expect(isNone(viewModel.state))
    }
}
