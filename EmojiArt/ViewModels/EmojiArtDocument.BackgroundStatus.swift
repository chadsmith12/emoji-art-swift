//
//  EmojiArtDocument.BackgroundStatus.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/19/21.
//

import Foundation

extension EmojiArtDocument {
    enum BackgroundStatus: Equatable {
        case idle
        case fetching
        case failed(URL)
    }
}
