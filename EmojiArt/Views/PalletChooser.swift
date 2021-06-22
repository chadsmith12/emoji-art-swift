//
//  PalletChooser.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/22/21.
//

import SwiftUI

struct PalletChooser: View {
    @EnvironmentObject var store: PalletStore
    @State private var choenPaletteIndex = 0
    var emojiFrontSize = CGFloat(EmojiArtModel.Emoji.defaultEmojiSize)
    var emojiFont: Font {
        .system(size: emojiFrontSize)
    }
    
    var body: some View {
        let pallet = store.getPallet(at: choenPaletteIndex)
        HStack {
            palletControlButton
            HStack {
                Text(pallet.name)
                ScrollingEmojisView(emojis: pallet.emojis)
                    .font(emojiFont)
            }
            .id(pallet.id)
            .transition(RollTransition(insertionOffset: (x: 0, y: emojiFrontSize), removalOffset: (x: 0, y: -emojiFrontSize)).transition)
        }
        .clipped()
    }
    
    var palletControlButton: some View {
        Button(action: cyclePalettes) {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
    }
    
    private func cyclePalettes() {
        withAnimation {
            choenPaletteIndex = (choenPaletteIndex + 1) % store.pallets.count
        }
    }
}

struct PalletChooser_Previews: PreviewProvider {
    static var previews: some View {
        PalletChooser()
            .environmentObject(PalletStore(named: "PreviewStore"))
    }
}
