//
//  Pallet.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/21/21.
//

import Foundation

struct Pallet: Identifiable, Codable {
    var name: String
    var emojis: String
    var id: Int
    
    init(name: String, emojis: String, id: Int) {
        self.name = name
        self.emojis = emojis
        self.id = id
    }
}
