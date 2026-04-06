//
//  applemusic_searchTests.swift
//  applemusic_searchTests
//
//  Created by 박재영 on 12/6/25.
//

import Testing
import Foundation
import Combine
@testable import applemusic_search

// MARK: - SearchViewModel 단위 테스트

@Suite("SearchViewModel 테스트")
struct SearchViewModelTests {

    // MARK: encodeSpaces

    @Test("앞뒤 공백은 제거된다")
    func encodeSpaces_leadingTrailingSpaces_removed() {
        let vm = SearchViewModel()
        #expect(vm.encodeSpaces("  hello  ") == "hello")
    }

    @Test("단어 사이 공백은 +로 변환된다")
    func encodeSpaces_middleSpace_replacedWithPlus() {
        let vm = SearchViewModel()
        #expect(vm.encodeSpaces("hello world") == "hello+world")
    }

    @Test("연속 공백은 제거된다")
    func encodeSpaces_consecutiveSpaces_removed() {
        let vm = SearchViewModel()
        #expect(vm.encodeSpaces("hello  world") == "hello+world")
    }

    @Test("공백 없는 문자열은 그대로 반환된다")
    func encodeSpaces_noSpaces_unchanged() {
        let vm = SearchViewModel()
        #expect(vm.encodeSpaces("swift") == "swift")
    }

    @Test("빈 문자열은 빈 문자열로 반환된다")
    func encodeSpaces_emptyString_returnsEmpty() {
        let vm = SearchViewModel()
        #expect(vm.encodeSpaces("") == "")
    }

    // MARK: updateTypingMatches

    @Test("keyword 접두어로 시작하는 최근 키워드만 필터된다")
    func updateTypingMatches_filtersByPrefix() {
        let vm = SearchViewModel()
        vm.recentKeywords = ["swift", "swiftUI", "kotlin", "SwiftData"]
        vm.keyword = "swift"
        vm.updateTypingMatches()
        // 대소문자 무시 → "swift", "swiftUI", "SwiftData" 모두 매칭
        #expect(vm.typingMatches.count == 3)
        #expect(vm.typingMatches.contains("swift"))
        #expect(vm.typingMatches.contains("swiftUI"))
        #expect(vm.typingMatches.contains("SwiftData"))
        #expect(!vm.typingMatches.contains("kotlin"))
    }

    @Test("keyword가 비어 있으면 모든 최근 키워드가 매칭된다")
    func updateTypingMatches_emptyKeyword_matchesAll() {
        let vm = SearchViewModel()
        vm.recentKeywords = ["a", "b", "c"]
        vm.keyword = ""
        vm.updateTypingMatches()
        #expect(vm.typingMatches.count == 3)
    }

    @Test("일치하는 최근 키워드가 없으면 빈 배열이 된다")
    func updateTypingMatches_noMatch_returnsEmpty() {
        let vm = SearchViewModel()
        vm.recentKeywords = ["android", "flutter"]
        vm.keyword = "swift"
        vm.updateTypingMatches()
        #expect(vm.typingMatches.isEmpty)
    }

    // MARK: mode

    @Test("keyword가 비어 있으면 mode는 .before")
    func mode_emptyKeyword_isBefore() {
        let vm = SearchViewModel()
        vm.keyword = ""
        #expect(vm.mode == .before)
    }

    @Test("keyword 입력 후 검색 전이면 mode는 .typing")
    func mode_keywordWithoutSearch_isTyping() {
        let vm = SearchViewModel()
        vm.keyword = "swift"
        #expect(vm.mode == .typing)
    }

    // MARK: loadNextPage

    @Test("currentLimit이 200이면 loadNextPage는 증가하지 않는다")
    func loadNextPage_atMax_doesNotExceed200() {
        let vm = SearchViewModel()
        vm.currentLimit = 200
        let before = vm.currentLimit
        vm.loadNextPage()
        // isLoading이 true가 되어 guard 통과 → currentLimit 은 변경 안 됨
        #expect(vm.currentLimit == before)
    }

    @Test("currentLimit이 20이면 loadNextPage 후 40이 된다")
    func loadNextPage_from20_becomes40() async throws {
        let vm = SearchViewModel()
        vm.keyword = "swift"
        vm.currentLimit = 20
        // isLoading을 false로 두고 nextPage 호출
        // 실제 네트워크 호출은 발생하지만 currentLimit 변경만 검증
        vm.loadNextPage()
        #expect(vm.currentLimit == 40)
    }
}

// MARK: - AppItem 디코딩 테스트

@Suite("AppItem 디코딩 테스트")
struct AppItemDecodingTests {

    private func decode(_ json: String) throws -> AppItem {
        let data = json.data(using: .utf8)!
        return try JSONDecoder().decode(AppItem.self, from: data)
    }

    @Test("trackId가 있으면 id는 trackId를 반환한다")
    func id_prefersTrackId() throws {
        let json = """
        {
            "trackId": 123,
            "artistId": 456,
            "screenshotUrls": [],
            "ipadScreenshotUrls": []
        }
        """
        let item = try decode(json)
        #expect(item.id == 123)
    }

    @Test("trackId가 없으면 id는 artistId를 반환한다")
    func id_fallsBackToArtistId() throws {
        let json = """
        {
            "artistId": 456,
            "screenshotUrls": [],
            "ipadScreenshotUrls": []
        }
        """
        let item = try decode(json)
        #expect(item.id == 456)
    }

    @Test("trackId, artistId 모두 없으면 id는 0")
    func id_defaultsToZero() throws {
        let json = """
        {
            "screenshotUrls": [],
            "ipadScreenshotUrls": []
        }
        """
        let item = try decode(json)
        #expect(item.id == 0)
    }

    @Test("trackName, description 등 선택적 필드가 없어도 디코딩 성공")
    func decoding_optionalFieldsMissing_succeeds() throws {
        let json = """
        {
            "trackId": 1,
            "screenshotUrls": [],
            "ipadScreenshotUrls": []
        }
        """
        let item = try decode(json)
        #expect(item.trackName == nil)
        #expect(item.description == nil)
        #expect(item.averageUserRating == nil)
        #expect(item.artworkUrl100 == nil)
    }

    @Test("artworkUrl100이 유효한 URL이면 올바르게 디코딩된다")
    func decoding_validArtworkUrl_parsed() throws {
        let json = """
        {
            "trackId": 1,
            "artworkUrl100": "https://example.com/icon.png",
            "screenshotUrls": [],
            "ipadScreenshotUrls": []
        }
        """
        let item = try decode(json)
        #expect(item.artworkUrl100?.absoluteString == "https://example.com/icon.png")
    }

    @Test("screenshotUrls 배열이 올바르게 디코딩된다")
    func decoding_screenshotUrls_parsed() throws {
        let json = """
        {
            "trackId": 1,
            "screenshotUrls": [
                "https://example.com/s1.png",
                "https://example.com/s2.png"
            ],
            "ipadScreenshotUrls": []
        }
        """
        let item = try decode(json)
        #expect(item.screenshotUrls.count == 2)
    }

    @Test("averageUserRating이 올바르게 디코딩된다")
    func decoding_averageUserRating_parsed() throws {
        let json = """
        {
            "trackId": 1,
            "averageUserRating": 4.5,
            "screenshotUrls": [],
            "ipadScreenshotUrls": []
        }
        """
        let item = try decode(json)
        #expect(item.averageUserRating == 4.5)
    }
}

// MARK: - AppsResponse 디코딩 테스트

@Suite("AppsResponse 디코딩 테스트")
struct AppsResponseDecodingTests {

    @Test("resultCount와 results 배열이 올바르게 디코딩된다")
    func decoding_resultCountAndResults() throws {
        let json = """
        {
            "resultCount": 2,
            "results": [
                {
                    "trackId": 1,
                    "trackName": "App One",
                    "screenshotUrls": [],
                    "ipadScreenshotUrls": []
                },
                {
                    "trackId": 2,
                    "trackName": "App Two",
                    "screenshotUrls": [],
                    "ipadScreenshotUrls": []
                }
            ]
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(AppsResponse.self, from: data)
        #expect(response.resultCount == 2)
        #expect(response.results.count == 2)
        #expect(response.results[0].trackName == "App One")
        #expect(response.results[1].trackName == "App Two")
    }

    @Test("results가 빈 배열이어도 디코딩 성공")
    func decoding_emptyResults_succeeds() throws {
        let json = """
        {
            "resultCount": 0,
            "results": []
        }
        """
        let data = json.data(using: .utf8)!
        let response = try JSONDecoder().decode(AppsResponse.self, from: data)
        #expect(response.resultCount == 0)
        #expect(response.results.isEmpty)
    }
}

// MARK: - Mock URLProtocol 기반 search() 통합 테스트

/// URLSession 요청을 가로채서 미리 정의한 응답을 반환하는 Mock
final class MockURLProtocol: URLProtocol {
    static var stubResponseData: Data?
    static var stubError: Error?
    static var requestHandler: ((URLRequest) -> (HTTPURLResponse, Data))?

    override class func canInit(with request: URLRequest) -> Bool { true }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        if let error = MockURLProtocol.stubError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }
        if let handler = MockURLProtocol.requestHandler {
            let (response, data) = handler(request)
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } else if let data = MockURLProtocol.stubResponseData {
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: 200,
                httpVersion: nil,
                headerFields: nil
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        }
    }

    override func stopLoading() {}
}

@Suite("search() 통합 테스트 (Mock 네트워크)")
struct SearchIntegrationTests {

    // 각 테스트 시작 전 Mock 상태를 항상 초기화 → 테스트 간 오염 방지
    init() {
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.stubError = nil
        MockURLProtocol.requestHandler = nil
    }

    private func makeViewModel() -> SearchViewModel {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        return SearchViewModel(session: URLSession(configuration: config))
    }

    @Test("정상 응답 시 apps가 채워진다")
    func search_successResponse_populatesApps() async throws {
        let json = """
        {
            "resultCount": 1,
            "results": [
                {
                    "trackId": 999,
                    "trackName": "MockApp",
                    "screenshotUrls": [],
                    "ipadScreenshotUrls": []
                }
            ]
        }
        """
        MockURLProtocol.stubResponseData = json.data(using: .utf8)
        MockURLProtocol.stubError = nil
        MockURLProtocol.requestHandler = nil

        let vm = makeViewModel()
        vm.keyword = "mock"

        await withCheckedContinuation { continuation in
            vm.search(reset: true) {
                continuation.resume()
            }
        }

        #expect(vm.apps.count == 1)
        #expect(vm.apps.first?.trackName == "MockApp")
        #expect(vm.mode == .after)
    }

    @Test("네트워크 오류 시 apps가 비어 있다")
    func search_networkError_appsEmpty() async throws {
        MockURLProtocol.stubResponseData = nil
        MockURLProtocol.requestHandler = nil
        MockURLProtocol.stubError = URLError(.notConnectedToInternet)

        let vm = makeViewModel()
        vm.keyword = "error"

        // 오류 시 completion이 호출되지 않으므로 충분히 대기
        try await Task.sleep(nanoseconds: 500_000_000)
        vm.search(reset: true)
        try await Task.sleep(nanoseconds: 500_000_000)

        #expect(vm.apps.isEmpty)
    }

    @Test("keyword가 비어 있으면 search()는 apps를 비운다")
    func search_emptyKeyword_clearsApps() async {
        let vm = makeViewModel()
        vm.keyword = ""
        vm.search(reset: true)
        #expect(vm.apps.isEmpty)
        #expect(vm.mode == .before)
    }
}
