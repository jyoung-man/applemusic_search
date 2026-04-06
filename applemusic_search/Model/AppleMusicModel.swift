//
//  AppleMusicModel.swift
//  applemusic_search
//
//  Created by 박재영 on 12/6/25.
//

import Foundation
import SwiftUI

struct AppleMusicModel: Decodable, Identifiable, Hashable {
    // 원본 키들을 그대로 보존 (없을 수도 있으니 optional로)
    let wrapperType: String?
    let kind: String?
    let artistId: Int64?
    let collectionId: Int64?
    let trackId: Int64?
    let artistName: String?
    let collectionName: String?
    let trackName: String?
    let collectionPrice: Double?
    let trackCount: Int?
    let country: String?
    let currency: String?
    let releaseDate: Date?
    let primaryGenreName: String?
    let previewUrl: URL?
    let description: String?
    let artworkUrl60: URL?
    let artworkUrl100: URL?

    // Identifiable 요구(우선 collectionId, 없으면 trackId, 없으면 artistId 사용)
    var id: Int64 {
        return collectionId ?? trackId ?? artistId ?? 0
    }

    enum CodingKeys: String, CodingKey {
        case wrapperType, kind, artistId, collectionId, trackId, artistName
        case collectionName, trackName, collectionPrice, trackCount, country, currency
        case releaseDate, primaryGenreName, previewUrl, description
        case artworkUrl60, artworkUrl100
    }
}
