//
//  FindCityUseCaseMock.swift
//  TakeHome Exrcise
//
//  Created by Serhii Shapoval on 09.11.2026.
//

@testable import TakeHome_Exrcise

final class FindCityUseCaseMock: FindCityUseCase {
    private var repository: CitiesRepository
    
    init(repository: CitiesRepository = CitiesRepositoryMock()) {
        self.repository = repository
    }
    
    func run(_ name: String) async throws -> [City] {
        try await repository.searchCities(for: name)
    }
}
