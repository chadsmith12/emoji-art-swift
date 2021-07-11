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
    
    init(id: String, alert: @escaping () -> Alert) {
        self.id = id
        self.alert = alert
    }
    
    init(id: String, title: String, message: String) {
        self.id = id
        alert = {
            Alert(title: Text(title), message: Text(message), dismissButton: .default(Text("OK")))
        }
    }
    
    init(title: String, message: String) {
        self.init(id: title + message, title: title, message: message)
    }
}
