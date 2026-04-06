//
//  AppleMusicRow.swift
//  applemusic_search
//
//  Created by 박재영 on 12/6/25.
//

import SwiftUI
import Kingfisher

struct AppleMusicRow: View {
    @ObservedObject var viewModel: SearchViewModel
    @State var app: AppItem

    var body: some View {
        HStack {
            if let artworkUrl = app.artworkUrl100 {
                KFImage(artworkUrl)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 60, height: 60)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            VStack(alignment: .leading, spacing: 10) {
                
                HStack {
                    if let trackName = app.trackName {
                        Text(trackName)
                            .font(.body)
                        Spacer()
                    }
                }
                .padding(.leading, 4) // 좌측 여백
                 

             }
        }
    }
}
