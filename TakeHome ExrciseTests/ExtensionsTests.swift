//
//  ExtensionsTests.swift
//  TakeHome ExrciseTests
//

import Testing
@testable import TakeHome_Exrcise

struct ExtensionsTests {

    @Test func sumOfIntegers() {
        #expect([1, 2, 3, 4].sum() == 10)
    }

    @Test func sumOfEmptyIsZero() {
        #expect([Int]().sum() == 0)
        #expect([Double]().sum() == 0)
    }

    @Test func sumOfDoubles() {
        #expect([0.5, 0.25, 0.25].sum() == 1.0)
    }

    @Test func integerAverageUsesIntegerDivision() {
        #expect([1, 2, 4].average() == 2)
    }

    @Test func integerAverageAsFloatingPoint() {
        let average: Double = [1, 2, 4].average()
        #expect(abs(average - 7.0 / 3.0) < 1e-9)
    }

    @Test func emptyIntegerAverageIsZero() {
        #expect([Int]().average() == 0)
        let average: Double = [Int]().average()
        #expect(average == 0)
    }

    @Test func floatingPointAverage() {
        #expect([1.0, 2.0, 6.0].average() == 3.0)
    }

    @Test func emptyFloatingPointAverageIsZero() {
        #expect([Double]().average() == 0)
    }
}
