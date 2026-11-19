//
//  APIClientTests.swift
//  TakeHome ExrciseTests
//

import Foundation
import Testing
@testable import TakeHome_Exrcise

private let endpoint = Endpoint(host: "example.com", path: "/v1/test")

// MARK: - DefaultAPIClient

struct DefaultAPIClientTests {

    @Test func decodesSnakeCaseJSON() async throws {
        let stub = HTTPClientStub(status: 200, body: TestFixtures.citiesJSON)
        let client = DefaultAPIClient(http: stub)

        let response = try await client.send(endpoint, as: GeocodingResponseDTO.self)

        let cities = try #require(response.results)
        #expect(cities.count == 2)
        #expect(cities[0].id == 6094817)
        #expect(cities[0].countryCode == "CA")
        #expect(cities[0].admin1 == "Ontario")
        #expect(cities[0].population == 812129)
        #expect(cities[1].elevation == nil)
        #expect(cities[1].timezone == nil)
    }

    @Test func missingResultsKeyDecodesToNil() async throws {
        let client = DefaultAPIClient(http: HTTPClientStub(body: "{}"))
        let response = try await client.send(endpoint, as: GeocodingResponseDTO.self)
        #expect(response.results == nil)
    }

    @Test func sendsTheEndpointRequest() async throws {
        let stub = HTTPClientStub(body: "{}")
        let client = DefaultAPIClient(http: stub)

        _ = try await client.send(endpoint, as: GeocodingResponseDTO.self)

        #expect(stub.requests.count == 1)
        #expect(stub.requests.first?.url?.absoluteString == "https://example.com/v1/test")
        #expect(stub.requests.first?.httpMethod == "GET")
    }

    @Test func acceptsAnyTwoHundredSeriesStatus() async throws {
        for status in [200, 201, 204, 299] {
            let client = DefaultAPIClient(http: HTTPClientStub(status: status, body: "{}"))
            _ = try await client.send(endpoint, as: GeocodingResponseDTO.self)
        }
    }

    @Test func badStatusCarriesServerReason() async {
        let body = #"{"error": true, "reason": "Latitude must be in range of -90 to 90"}"#
        let client = DefaultAPIClient(http: HTTPClientStub(status: 400, body: body))
        do {
            _ = try await client.send(endpoint, as: GeocodingResponseDTO.self)
            Issue.record("Expected an error")
        } catch NetworkError.badStatus(let code, let reason) {
            #expect(code == 400)
            #expect(reason == "Latitude must be in range of -90 to 90")
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func badStatusWithoutParsableBodyHasNoReason() async {
        let client = DefaultAPIClient(http: HTTPClientStub(status: 502, body: "<html>Bad gateway</html>"))
        do {
            _ = try await client.send(endpoint, as: GeocodingResponseDTO.self)
            Issue.record("Expected an error")
        } catch NetworkError.badStatus(let code, let reason) {
            #expect(code == 502)
            #expect(reason == nil)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func redirectsAndClientErrorsAreRejected() async {
        for status in [300, 301, 404, 500] {
            let client = DefaultAPIClient(http: HTTPClientStub(status: status, body: "{}"))
            do {
                _ = try await client.send(endpoint, as: GeocodingResponseDTO.self)
                Issue.record("Expected status \(status) to throw")
            } catch NetworkError.badStatus(let code, _) {
                #expect(code == status)
            } catch {
                Issue.record("Unexpected error for \(status): \(error)")
            }
        }
    }

    @Test func malformedBodyThrowsDecodingError() async {
        let client = DefaultAPIClient(http: HTTPClientStub(status: 200, body: "not json"))
        do {
            _ = try await client.send(endpoint, as: GeocodingResponseDTO.self)
            Issue.record("Expected an error")
        } catch NetworkError.decoding {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func wrongShapeThrowsDecodingError() async {
        // `results` must be an array of cities, not a string.
        let client = DefaultAPIClient(http: HTTPClientStub(status: 200, body: #"{"results": "oops"}"#))
        do {
            _ = try await client.send(endpoint, as: GeocodingResponseDTO.self)
            Issue.record("Expected an error")
        } catch NetworkError.decoding {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func transportErrorsPropagate() async {
        let stub = HTTPClientStub(failure: NetworkError.transport(URLError(.notConnectedToInternet)))
        let client = DefaultAPIClient(http: stub)
        do {
            _ = try await client.send(endpoint, as: GeocodingResponseDTO.self)
            Issue.record("Expected an error")
        } catch NetworkError.transport(let urlError) {
            #expect(urlError.code == .notConnectedToInternet)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func invalidEndpointFailsBeforeAnyRequest() async {
        let stub = HTTPClientStub()
        let client = DefaultAPIClient(http: stub)
        do {
            _ = try await client.send(Endpoint(host: "example.com", path: "no-slash"),
                                      as: GeocodingResponseDTO.self)
            Issue.record("Expected an error")
        } catch NetworkError.invalidURL {
            #expect(stub.requests.isEmpty)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}

// MARK: - URLSessionHTTPClient

/// URLProtocol that answers every request from `handler`, so no real network is used.
final class StubURLProtocol: URLProtocol {
    nonisolated(unsafe) static var handler: ((URLRequest) throws -> (URLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        guard let handler = StubURLProtocol.handler else {
            client?.urlProtocol(self, didFailWithError: URLError(.unknown))
            return
        }
        do {
            let (response, data) = try handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } catch {
            client?.urlProtocol(self, didFailWithError: error)
        }
    }

    override func stopLoading() {}
}

@Suite(.serialized)
struct URLSessionHTTPClientTests {

    private func makeClient() -> URLSessionHTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return URLSessionHTTPClient(session: URLSession(configuration: configuration))
    }

    private let request = URLRequest(url: URL(string: "https://example.com/v1/test")!)

    @Test func returnsDataAndHTTPResponse() async throws {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 201, httpVersion: nil, headerFields: nil)!
            return (response, Data("hello".utf8))
        }
        defer { StubURLProtocol.handler = nil }

        let (data, response) = try await makeClient().send(request)

        #expect(String(decoding: data, as: UTF8.self) == "hello")
        #expect(response.statusCode == 201)
    }

    @Test func mapsCancelledURLErrorToCancelled() async {
        StubURLProtocol.handler = { _ in throw URLError(.cancelled) }
        defer { StubURLProtocol.handler = nil }

        do {
            _ = try await makeClient().send(request)
            Issue.record("Expected an error")
        } catch NetworkError.cancelled {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func wrapsOtherURLErrorsAsTransport() async {
        StubURLProtocol.handler = { _ in throw URLError(.timedOut) }
        defer { StubURLProtocol.handler = nil }

        do {
            _ = try await makeClient().send(request)
            Issue.record("Expected an error")
        } catch NetworkError.transport(let urlError) {
            #expect(urlError.code == .timedOut)
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func nonHTTPResponseIsInvalid() async {
        StubURLProtocol.handler = { request in
            let response = URLResponse(url: request.url!, mimeType: nil, expectedContentLength: 0, textEncodingName: nil)
            return (response, Data())
        }
        defer { StubURLProtocol.handler = nil }

        do {
            _ = try await makeClient().send(request)
            Issue.record("Expected an error")
        } catch NetworkError.invalidResponse {
            // expected
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }
}
