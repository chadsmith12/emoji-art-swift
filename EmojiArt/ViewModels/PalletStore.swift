//
//  PalletStore.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/21/21.
//

import SwiftUI

class PalletStore: ObservableObject {
    let name: String
    
    @Published var pallets = [Pallet]() {
        didSet {
            storeInUserDefaults()
        }
    }
    
    init(named name: String) {
        self.name = name
        
        restoreFromUserDefault()
        if pallets.isEmpty {
            for pallet in defaultPallets {
                insertPallet(named: pallet.key, emojis: pallet.value)
            }
        }
    }
    
    private var userDefaultsKey: String {
        "PalletStore:\(name)"
    }
    
    // MARK: - Intents
    func getPallet(at index: Int) -> Pallet {
        let safeIndex = min(max(index, 0), pallets.count - 1)
        return pallets[safeIndex]
    }
    
    @discardableResult
    func removePallet(at index: Int) -> Int {
        if pallets.count > 1, pallets.indices.contains(index) {
            pallets.remove(at: index)
        }
        
        return index % pallets.count
    }
    
    func insertPallet(named name: String, emojis: String?, at index: Int = 0)  {
        let uniqueId = (pallets.max(by: {$0.id < $1.id})?.id ?? 0) + 1
        let pallet = Pallet(name: name, emojis: emojis ?? "", id: uniqueId)
        let safeIndex = min(max(index, 0), pallets.count)
        pallets.insert(pallet, at: safeIndex)
    }
    
    private func storeInUserDefaults() {
        let encodedData = try? JSONEncoder().encode(pallets)
        UserDefaults.standard.set(encodedData, forKey: userDefaultsKey)
    }
    
    private func restoreFromUserDefault() {
        if let jsonData = UserDefaults.standard.data(forKey: userDefaultsKey),
           let decodedPallets = try? JSONDecoder().decode([Pallet].self, from: jsonData) {
            pallets = decodedPallets
        }
    }
}
