//
//  EmojiArtDocumentView.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

struct EmojiArtDocumentView: View {
    @ObservedObject var document: EmojiArtDocument
    let testEmojis = "😅🐶🐯🐷🐱🐦🎾⚽️🏀🖥📱⌚️💙☮️☦️🇨🇷🇨🇳🇧🇬☾☇"
    
    var body: some View {
        VStack(spacing: 0) {
            DocumentBody(document: document)
            PalletChooser()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        EmojiArtDocumentView(document: EmojiArtDocument())
    }
}
