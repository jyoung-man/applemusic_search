//
//  AppItem.swift
//  applemusic_search
//
//  Created by 박재영 on 12/10/25.
//

import Foundation
import SwiftUI

struct AppItem: Decodable, Identifiable, Hashable {
    let artistId: Int64?
    let trackId: Int64?
    let artworkUrl100: URL? // 아이콘
    let trackName: String? // 타이틀
    let averageUserRating: Double? // 별점
    let screenshotUrls: [URL?] // 스크린샷
    let ipadScreenshotUrls: [URL?] // 스크린샷
    let description: String? // 설명
    
    // Identifiable 요구(우선 trackId, 없으면 artistId 사용)
    var id: Int64 {
        return trackId ?? artistId ?? 0
    }
}
