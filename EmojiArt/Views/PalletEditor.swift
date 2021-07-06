//
//  PalletEditor.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/22/21.
//

import SwiftUI

struct PalletEditor: View {
    @Binding var pallet: Pallet
    @State private var newEmojis: String = ""
    @State private var emojisAdded: String = ""
    
    private var distinctEmojis: [String] {
        return pallet.emojis.removingDuplicateCharacters.map {String($0)}
    }
    
    var body: some View {
        Form {
            Section(header: Text("Name")) {
                TextField("Name", text: $pallet.name)
            }
            Section(header: Text("Add Emojis")) {
                TextField("", text: $newEmojis)
                    .onChange(of: newEmojis, perform: addEmojis)
            }
            Section(header: Text("Remove Emojis")) {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 40))]) {
                    ForEach(distinctEmojis, id: \.self) { emoji in
                        Text(emoji)
                            .onTapGesture {
                                removeEmoji(emoji)
                            }
                    }
                }
            }
        }
        .frame(minWidth: 300, minHeight: 350)
        .navigationTitle("Edit \(pallet.name)")
    }
    
    private func addEmojis(_ emojis: String) {
        withAnimation {
            // go through all emojis, if no longer included remove it
            for currentEmoji in pallet.emojis {
                if !emojis.contains(currentEmoji) && emojisAdded.contains(currentEmoji) {
                    if let removeIndex = pallet.emojis.firstIndex(of: currentEmoji) {
                        pallet.emojis.remove(at: removeIndex)
                    }
                }
            }
            
            pallet.emojis = (emojis + pallet.emojis)
                .filter { $0.isEmoji }
                .removingDuplicateCharacters
            emojisAdded.append(emojis)
        }
    }
    
    private func removeEmoji(_ emoji: String) {
        withAnimation {
            pallet.emojis.removeAll(where: {String($0) == emoji})
        }
    }
}

struct PalletEditor_Previews: PreviewProvider {
    static var previews: some View {
        PalletEditor(pallet: .constant(PalletStore(named: "Preview:PalletEditor").getPallet(at: 0)))
            .previewLayout(.fixed(width: /*@START_MENU_TOKEN@*/300.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/350.0/*@END_MENU_TOKEN@*/))
    }
}
