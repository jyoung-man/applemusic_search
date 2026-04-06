//
//  AppleMusicDetailView.swift
//  applemusic_search
//
//  Created by 박재영 on 12/28/25.
//

import SwiftUI
import Kingfisher


struct AppleMusicDetailView: View {
    @ObservedObject var viewModel: SearchViewModel
    @State var app: AppItem
    @State private var isDescriptionExpanded: Bool = false

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(spacing: 24) {
                // 앱 헤더 섹션
                headerSection
                
                // 스크린샷 섹션 (스크린샷이 있을 때만 표시)
                if !app.screenshotUrls.isEmpty {
                    screenshotSection
                }
                
                // 설명 섹션
                descriptionSection
                
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - 앱 헤더 섹션
    private var headerSection: some View {
        VStack(spacing: 20) {
            HStack(alignment: .center, spacing: 16) {
                // 앱 아이콘
                if let artworkUrl = app.artworkUrl100 {
                    KFImage(artworkUrl)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                }
                
                // 앱 정보
                VStack(alignment: .leading, spacing: 6) {
                    if let trackName = app.trackName {
                        Text(trackName)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                    
                    if let averageUserRating = app.averageUserRating {
                        HStack(spacing: 4) {
                            ForEach(0..<5) { index in
                                Image(systemName: index < Int(averageUserRating.rounded()) ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .font(.caption)
                            }
                            Text(String(format: "%.1f", averageUserRating))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    Spacer()
                }
                
                Spacer()
            }
            .padding(.vertical, 8)
            
            Divider()
                .padding(.horizontal, -16)
        }
    }
    
    // MARK: - 스크린샷 섹션
    private var screenshotSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("스크린샷")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 16) {
                    ForEach(app.screenshotUrls.indices, id: \.self) { index in
                        if let url = app.screenshotUrls[index] {
                            KFImage(url)
                                .resizable()
                                .placeholder {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.gray.opacity(0.1))
                                        .frame(width: 200, height: 350)
                                        .overlay(
                                            ProgressView()
                                                .progressViewStyle(CircularProgressViewStyle(tint: .gray))
                                        )
                                }
                                .fade(duration: 0.3)
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 200, height: 350)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                                .shadow(color: .black.opacity(0.12), radius: 6, x: 0, y: 3)
                        } else {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.gray.opacity(0.1))
                                .frame(width: 200, height: 350)
                                .overlay(
                                    VStack(spacing: 8) {
                                        Image(systemName: "photo")
                                            .font(.title2)
                                            .foregroundColor(.gray)
                                        Text("이미지 없음")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                )
                                .shadow(color: .black.opacity(0.05), radius: 3, x: 0, y: 1)
                        }
                    }
                }
                .padding(.horizontal, 4)
            }
        }
    }
    
    // MARK: - 설명 섹션
    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("설명")
                .font(.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if let description = app.description {
                VStack(alignment: .leading, spacing: 12) {
                    // 설명 텍스트 (expanded 여부에 따라 제한)
                    if isDescriptionExpanded {
                        // 전체 설명 표시
                        Text(description)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    } else {
                        // 일부만 표시 (스크린샷 유무에 따라 제한)
                        Text(description)
                            .font(.body)
                            .foregroundColor(.primary)
                            .lineSpacing(4)
                            .lineLimit(app.screenshotUrls.isEmpty ? 20 : 3)
                    }
                    
                    // 더보기 버튼 (설명이 3줄보다 길 경우만 표시)
                    if shouldShowMoreButton(description) {
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isDescriptionExpanded.toggle()
                            }
                        }) {
                            HStack {
                                Text(isDescriptionExpanded ? "닫기" : "더보기")
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.blue)
                                
                                Image(systemName: isDescriptionExpanded ? "chevron.up" : "chevron.down")
                                    .foregroundColor(.blue)
                                    .font(.caption)
                            }
                        }
                    }
                }
                .padding(.vertical, 4)
            } else {
                Text("설명이 제공되지 않았습니다.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .italic()
                    .padding(.vertical, 4)
            }
        }
        .padding(.bottom, 16)
    }
    
    // MARK: - Helper 메서드
    private func shouldShowMoreButton(_ description: String) -> Bool {
        // 스크린샷이 없으면 더 많은 텍스트 표시 (900자), 있으면 150자
        let threshold = app.screenshotUrls.isEmpty ? 900 : 150
        return description.count > threshold
    }
}
