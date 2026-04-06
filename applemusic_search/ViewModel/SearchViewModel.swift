//
//  SearchViewModel.swift
//  applemusic_search
//
//  Created by 박재영 on 12/6/25.
//

import SwiftUI
import Combine

enum SearchMode {
    case before      // 검색 전 (검색어 없음)
    case typing      // 검색 중 (입력 중)
    case after       // 검색 완료 (결과 리스트)
}

final class SearchViewModel:
    ObservableObject {
    @Published var keyword = "" {
        didSet {
            // 검색어가 변경되면 검색 상태 리셋
            if keyword != oldValue {
                hasSearched = false
                updateTypingMatches()
            }
        }
    }
    @Published var isLoading = false
    @Published var currentLimit: Int = 20
    @Published private(set) var apps = [AppItem]()
    @Published var recentKeywords: [String] = []
    @Published var typingMatches: [String] = []
    @Published private var hasSearched = false

    var mode: SearchMode {
        if keyword.isEmpty {
            return .before
        } else if !hasSearched || (hasSearched && !keyword.isEmpty && apps.isEmpty) {
            return .typing
        } else {
            return .after
        }
    }

    private var searchCancellable: Cancellable? {
        didSet { oldValue?.cancel() }
    }

    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }
    
    deinit {
        searchCancellable?.cancel()
    }
    
    func encodeSpaces(_ text: String) -> String {
        let chars = Array(text)
        var result = ""

        for i in 0..<chars.count {
            let current = chars[i]

            if current == " " {
                // 문자열 시작 또는 뒤에 글자가 없거나 공백이면 → 삭제
                if i == 0 || i + 1 == chars.count || chars[i + 1] == " " {
                    continue
                } else {
                    // 뒤에 글자가 있으면 "+”로 변환
                    result.append("+")
                }
            } else {
                result.append(current)
            }
        }

        return result
    }

    func loadNextPage() {
        guard !isLoading else { return }
        isLoading = true
        if currentLimit == 200 { return }
        let next = currentLimit * 2
        currentLimit = min(next, 200)
        search(reset: false) { [weak self] in
            self?.isLoading = false
        }
    }
    
    func updateTypingMatches() {
        typingMatches = recentKeywords.filter {
            $0.lowercased().hasPrefix(keyword.lowercased())
        }
    }

    func search(reset: Bool = true, completion: (() -> Void)? = nil) {
        if reset {
            apps = []
            currentLimit = 20
            hasSearched = false
        }
        
        guard !keyword.isEmpty else {
            apps = []
            currentLimit = 20
            hasSearched = false
            return
        }
        
        self.appendRecentKeyword(keyword)
        let term = encodeSpaces(keyword)
        var urlComponents = URLComponents(string: "https://itunes.apple.com/search")!
        urlComponents.queryItems = [
            URLQueryItem(name: "term", value: term),
            URLQueryItem(name: "media", value: "software"),
            URLQueryItem(name: "limit", value: "\(currentLimit)"),
            URLQueryItem(name: "country", value: "KR"),
        ]
        
        let request = URLRequest(url: urlComponents.url!)
        print("request url = \(String(describing: urlComponents.url!))")
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        searchCancellable = session.dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: AppsResponse.self, decoder: decoder)
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error: \(error)")
                    self.apps = []
                    self.hasSearched = true
                }
            }, receiveValue: { response in
                self.apps = response.results
                self.hasSearched = true
                completion?()
            })
    }
    func clearApps() {
        self.apps = []
        self.hasSearched = false
    }
    private func appendRecentKeyword(_ keyword: String) {
        self.recentKeywords.append(keyword)
    }
}
