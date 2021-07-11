//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var palletStore: PalletStore = PalletStore(named: "Default")
    
    var body: some Scene {
        DocumentGroup(newDocument: { EmojiArtDocument() }) { config in
            EmojiArtDocumentView(document: config.document)
                .environmentObject(palletStore)
        }
    }
}
