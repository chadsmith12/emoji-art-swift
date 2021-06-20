//
//  DocumentEmojiView.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/19/21.
//

import SwiftUI

struct DocumentEmojiView: View {
    var content: String
    var isSelected: Bool
    
    var body: some View {
        Text(content)
            .padding(4.0)
            .border(isSelected ? Color.black : Color.clear)
    }
}

struct DocumentEmojiView_Previews: PreviewProvider {
    static var previews: some View {
        DocumentEmojiView(content: "🎾", isSelected: true)
    }
}
