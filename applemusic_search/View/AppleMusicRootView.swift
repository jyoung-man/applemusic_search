//
//  AppleMusicRootView.swift
//  applemusic_search
//
//  Created by 박재영 on 12/6/25.
//

import SwiftUI

struct AppleMusicRootView: View {
    @ObservedObject var viewModel = SearchViewModel()

    var body: some View {
        NavigationStack {
            VStack {
                // 검색바를 상단에 고정
                searchBar
                    .padding(.horizontal)
                    .padding(.top)
                // 내용
                contentView
                Spacer()
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Spacer 영역 탭 시 키보드 숨김
                        hideKeyboard()
                    }
            }
            .navigationTitle("Apps")
        }
    }

    var contentView: some View {
        VStack {
            // 검색 전 상태 (최근 검색어)
            if viewModel.mode == .before {
                recentListView
            }
            
            // 입력 중 상태 (추천 검색어)
            if viewModel.mode == .typing {
                typingListView
            }
            
            // 검색 완료 상태 (결과 리스트)
            if viewModel.mode == .after {
                resultListView
            }
        }
    }
    
    var recentListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 섹션 헤더
            HStack {
                Text("최근 검색어")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemGroupedBackground))
            .onTapGesture {
                hideKeyboard()
            }
            
            // 최근 검색어 리스트
            if viewModel.recentKeywords.isEmpty {
                VStack {
                    Text("최근 검색어가 없습니다")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .onTapGesture {
                    hideKeyboard()
                }
            } else {
                ForEach(Array(viewModel.recentKeywords.enumerated()), id: \.offset) { index, keyword in
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            
                            Text(keyword)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.systemBackground))
                        .onTapGesture {
                            viewModel.keyword = keyword
                            hideKeyboard() // 키보드 숨김
                            viewModel.search()
                        }
                        
                        // 구분선 (마지막 항목 제외)
                        if index < viewModel.recentKeywords.count - 1 {
                            Rectangle()
                                .fill(Color(UIColor.separator))
                                .frame(height: 0.5)
                                .padding(.leading, 48) // 아이콘 너비만큼 들여쓰기
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }

    var resultListView: some View {
        List(viewModel.apps) { app in
            NavigationLink {
                AppleMusicDetailView(viewModel: self.viewModel, app: app)
            } label: {
                AppleMusicRow(viewModel: self.viewModel, app: app)
                    .task {
                        if app == viewModel.apps.last {
                            viewModel.loadNextPage()
                        }
                    }
            }
        }
        .dismissKeyboardOnScroll()
    }

    var searchBar: some View {
        TextField("검색어 입력", text: $viewModel.keyword)
            .textFieldStyle(.roundedBorder)
            .padding()
            .onSubmit {
                viewModel.search()
                hideKeyboard()
            }
    }
    
    var typingListView: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 섹션 헤더
            HStack {
                Text("추천 검색어")
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(UIColor.systemGroupedBackground))
            .onTapGesture {
                hideKeyboard()
            }
            
            // 추천 검색어 리스트
            if viewModel.typingMatches.isEmpty {
                VStack {
                    Text("추천 검색어가 없습니다")
                        .foregroundColor(.secondary)
                        .font(.body)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .background(Color(UIColor.systemBackground))
                .onTapGesture {
                    hideKeyboard()
                }
            } else {
                ForEach(Array(viewModel.typingMatches.enumerated()), id: \.offset) { index, word in
                    VStack(spacing: 0) {
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.secondary)
                                .font(.system(size: 14))
                            
                            Text(word)
                                .font(.body)
                                .foregroundColor(.primary)
                            
                            Spacer()
                            
                            Image(systemName: "arrow.up.left")
                                .foregroundColor(.secondary)
                                .font(.system(size: 12))
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(UIColor.systemBackground))
                        .onTapGesture {
                            viewModel.keyword = word
                            hideKeyboard() // 키보드 숨김
                        }
                        
                        // 구분선 (마지막 항목 제외)
                        if index < viewModel.typingMatches.count - 1 {
                            Rectangle()
                                .fill(Color(UIColor.separator))
                                .frame(height: 0.5)
                                .padding(.leading, 48) // 아이콘 너비만큼 들여쓰기
                        }
                    }
                }
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

#Preview {
    AppleMusicRootView()
}
