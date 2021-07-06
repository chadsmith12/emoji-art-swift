//
//  PalletManager.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/23/21.
//

import SwiftUI

struct PalletManager: View {
    @EnvironmentObject var store: PalletStore
    @State private var editMode: EditMode = .inactive
    
    var body: some View {
        NavigationView {
            List {
                ForEach(store.pallets) { pallet in
                    NavigationLink(destination: PalletEditor(pallet: $store.pallets[pallet])) {
                        VStack(alignment: .leading) {
                            Text(pallet.name)
                            Text(pallet.emojis)
                        }
                    }
                }
                .onDelete { indexSet in
                    store.pallets.remove(atOffsets: indexSet)
                }
                .onMove { indexSet, newOffset in
                    store.pallets.move(fromOffsets: indexSet, toOffset: newOffset)
                }
            }
            .navigationTitle("Manage Pallets")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                EditButton()
            }
            .environment(\.editMode, $editMode)
        }
    }
}

struct PalletManager_Previews: PreviewProvider {
    static var previews: some View {
        PalletManager()
            .previewDevice("iPhone 8 Plus")
            .environmentObject(PalletStore(named: "ManagerStore"))
    }
}
