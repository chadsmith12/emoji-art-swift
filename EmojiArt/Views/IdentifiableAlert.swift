//
//  IdentifiableAlert.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/24/21.
//

import SwiftUI

struct IdentifiableAlert: Identifiable {
    var id: String
    var alert: () -> Alert
}
