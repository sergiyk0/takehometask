//
//  CacheTests.swift
//  TakeHome ExrciseTests
//

import Foundation
import Testing
@testable import TakeHome_Exrcise

struct CacheTests {

    /// Mutable clock so tests can move time forward deterministically.
    final class TestClock {
        var now = Date(timeIntervalSince1970: 1_000_000)
    }

    private func makeCache(lifetime: TimeInterval = 60, clock: TestClock = TestClock()) -> (Cache<String, Int>, TestClock) {
        (Cache<String, Int>(dateProvider: { clock.now }, entryLifetime: lifetime), clock)
    }

    @Test func returnsNilForUnknownKey() {
        let (cache, _) = makeCache()
        #expect(cache.value(forKey: "missing") == nil)
    }

    @Test func returnsInsertedValue() {
        let (cache, _) = makeCache()
        cache.insert(42, forKey: "answer")
        #expect(cache.value(forKey: "answer") == 42)
    }

    @Test func insertingSameKeyOverwrites() {
        let (cache, _) = makeCache()
        cache.insert(1, forKey: "k")
        cache.insert(2, forKey: "k")
        #expect(cache.value(forKey: "k") == 2)
    }

    @Test func keysAreIndependent() {
        let (cache, _) = makeCache()
        cache.insert(1, forKey: "a")
        cache.insert(2, forKey: "b")
        #expect(cache.value(forKey: "a") == 1)
        #expect(cache.value(forKey: "b") == 2)
    }

    @Test func valueIsAvailableBeforeExpiry() {
        let (cache, clock) = makeCache(lifetime: 60)
        cache.insert(7, forKey: "k")
        clock.now.addTimeInterval(59)
        #expect(cache.value(forKey: "k") == 7)
    }

    @Test func valueExpiresExactlyAtLifetime() {
        let (cache, clock) = makeCache(lifetime: 60)
        cache.insert(7, forKey: "k")
        clock.now.addTimeInterval(60)
        #expect(cache.value(forKey: "k") == nil)
    }

    @Test func expiredValueStaysGone() {
        let (cache, clock) = makeCache(lifetime: 60)
        cache.insert(7, forKey: "k")
        clock.now.addTimeInterval(120)
        #expect(cache.value(forKey: "k") == nil)
        // Moving the clock back must not resurrect an entry that was already evicted.
        clock.now.addTimeInterval(-120)
        #expect(cache.value(forKey: "k") == nil)
    }

    @Test func reinsertingRefreshesExpiry() {
        let (cache, clock) = makeCache(lifetime: 60)
        cache.insert(1, forKey: "k")
        clock.now.addTimeInterval(50)
        cache.insert(2, forKey: "k")
        clock.now.addTimeInterval(50)
        #expect(cache.value(forKey: "k") == 2)
    }

    @Test func removeValueDeletesEntry() {
        let (cache, _) = makeCache()
        cache.insert(1, forKey: "k")
        cache.removeValue(forKey: "k")
        #expect(cache.value(forKey: "k") == nil)
    }

    @Test func removingUnknownKeyIsHarmless() {
        let (cache, _) = makeCache()
        cache.removeValue(forKey: "nope")
        #expect(cache.value(forKey: "nope") == nil)
    }

    @Test func subscriptGetAndSet() {
        let (cache, _) = makeCache()
        cache["k"] = 5
        #expect(cache["k"] == 5)
    }

    @Test func subscriptSetNilRemovesEntry() {
        let (cache, _) = makeCache()
        cache["k"] = 5
        cache["k"] = nil
        #expect(cache["k"] == nil)
    }

    @Test func worksWithHashableStructKeys() {
        let cache = Cache<City, String>()
        let ottawa = TestFixtures.city(id: 1, name: "Ottawa")
        let toronto = TestFixtures.city(id: 2, name: "Toronto")
        cache[ottawa] = "cold"
        #expect(cache[ottawa] == "cold")
        #expect(cache[toronto] == nil)
    }

    @Test func defaultLifetimeIsFiveMinutes() {
        let clock = TestClock()
        let cache = Cache<String, Int>(dateProvider: { clock.now })
        cache.insert(1, forKey: "k")
        clock.now.addTimeInterval(5 * 60 - 1)
        #expect(cache.value(forKey: "k") == 1)
        clock.now.addTimeInterval(1)
        #expect(cache.value(forKey: "k") == nil)
    }
}
