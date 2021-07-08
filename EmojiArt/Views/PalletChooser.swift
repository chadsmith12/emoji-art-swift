//
//  PalletChooser.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/22/21.
//

import SwiftUI

struct PalletChooser: View {
    @EnvironmentObject var store: PalletStore
    @SceneStorage("PalletChoose.chosenPaletteIndex") private var choenPaletteIndex = 0
    @State private var palletToEdit: Pallet?
    @State private var managing = false
    
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
            .popover(item: $palletToEdit) { pallet in
                PalletEditor(pallet: $store.pallets[pallet])
            }
            .sheet(isPresented: $managing) {
                PalletManager()
            }
        }
        .clipped()
    }
    
    var palletControlButton: some View {
        Button(action: cyclePalettes) {
            Image(systemName: "paintpalette")
        }
        .font(emojiFont)
        .contextMenu {
            contextMenu
        }
    }
    
    @ViewBuilder
    var contextMenu: some View {
        AnimatedActionButton(title: "Edit", systemImage: "pencil") {
            palletToEdit = store.getPallet(at: choenPaletteIndex)
        }
        AnimatedActionButton(title: "New", systemImage: "plus") {
            store.insertPallet(named: "New", emojis: "", at: choenPaletteIndex)
            palletToEdit = store.getPallet(at: choenPaletteIndex)
        }
        AnimatedActionButton(title: "Delete", systemImage: "minus.circle") {
            choenPaletteIndex = store.removePallet(at: choenPaletteIndex)
        }
        AnimatedActionButton(title: "Manager", systemImage: "slider.vertical.3") {
            managing = true
        }
        gotoMenu
    }
    
    var gotoMenu: some View {
        Menu {
            ForEach(store.pallets) { pallet in
                AnimatedActionButton(title: pallet.name) {
                    if let index = store.pallets.index(matching: pallet) {
                        self.choenPaletteIndex = index
                    }
                }
            }
        } label: {
            Label("Go To", systemImage: "text.insert")
        }
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
