//
//  ScrollingEmojisView.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

struct ScrollingEmojisView: View {
    let emojis: String
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(emojis.map { String($0) }, id: \.self) { emoji in
                    Text(emoji)
                        .onDrag {
                            return getItemProvider(for: emoji)
                        }
                }
            }
        }
    }
    
    private func getItemProvider(for emoji: String) -> NSItemProvider {
        NSItemProvider(object: emoji as NSString)
    }
}

struct ScrollingEmojisView_Previews: PreviewProvider {
    static let testEmojis = "😅🐶🐯🐷🐱🐦🎾⚽️🏀🖥📱⌚️💙☮️☦️🇨🇷🇨🇳🇧🇬☾☇"
    
    static var previews: some View {
        ScrollingEmojisView(emojis: testEmojis)
    }
}
