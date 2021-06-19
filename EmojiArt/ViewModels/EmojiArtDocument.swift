//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel
    
    init() {
        emojiArt = EmojiArtModel()
        emojiArt.addEmoji("😅", at: Point(x: -200, y: -100), size: 80)
        emojiArt.addEmoji("🏀", at: Point(x: 200, y: 100), size: 40)
    }
    
    var emojis: [EmojiArtModel.Emoji] {
        emojiArt.emojis
    }
    
    var background: EmojiArtModel.Background {
        emojiArt.background
    }
    
    // MARK: - Intents
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: Point, size: CGFloat = CGFloat(EmojiArtModel.Emoji.defaultEmojiSize)) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].location.x += Int(offset.width)
            emojiArt.emojis[index].location.y += Int(offset.height)
        }
    }
    
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale)
                                                .rounded(.toNearestOrAwayFromZero))
        }
    }
}
