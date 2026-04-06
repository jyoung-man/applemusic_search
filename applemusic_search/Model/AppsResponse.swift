//
//  AppsResponse.swift
//  applemusic_search
//
//  Created by 박재영 on 12/10/25.
//

struct AppsResponse: Decodable {
    var resultCount: Int
    var results: [AppItem]
}
