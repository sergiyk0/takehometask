//
//  FindCityUsecaseTests.swift
//  TakeHome ExrciseTests
//
//  Created by Serhii Shapoval on 09.11.2026.
//

import Testing
@testable import TakeHome_Exrcise

struct FindCityUsecaseTests {

    @Test func testSuccess() async throws {
        let usecase = FindCityUseCaseMock()
        let results = try await usecase.run("Ottawa")
        #expect(results.count == 5)
    }
    
    @Test func testEmpty() async throws {
        let usecase = FindCityUseCaseMock()
        let result = try await usecase.run("New York")
        #expect(result.isEmpty)
    }
    
    @Test func testError() async throws {
        let usecase = FindCityUseCaseMock()
        await #expect(throws: (any Error).self) {
            try await usecase.run("Null")
        }
        
    }

}
