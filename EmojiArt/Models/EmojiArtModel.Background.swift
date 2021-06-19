//
//  EmojiArtDocument.Background.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import Foundation

extension EmojiArtModel {
    enum Background {
        case blank
        case url(URL)
        case imageData(Data)
        
        var url: URL? {
            switch self {
            case .url(let url): return url
            default: return nil
            }
        }
        
        var data: Data? {
            switch self {
            case .imageData(let data): return data
            default: return nil
            }
        }
    }
}
