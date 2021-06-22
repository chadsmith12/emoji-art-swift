//
//  EmojiArtApp.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

@main
struct EmojiArtApp: App {
    @StateObject var document: EmojiArtDocument = EmojiArtDocument()
    @StateObject var palletStore: PalletStore = PalletStore(named: "Default")
    
    var body: some Scene {
        WindowGroup {
            EmojiArtDocumentView(document: document)
                .environmentObject(palletStore)
        }
    }
}
