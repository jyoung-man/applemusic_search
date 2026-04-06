//
//  AppleMusicResponse.swift
//  applemusic_search
//
//  Created by 박재영 on 12/6/25.
//

struct AppleMusicResponse: Decodable {
    var resultCount: Int
    var results: [AppleMusicModel]
}
