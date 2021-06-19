//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    let document: EmojiArtDocument = EmojiArtDocument()
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
        }
    }
}
