//
//  AnimatedActionButton.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/22/21.
//

import SwiftUI

struct AnimatedActionButton: View {
    var title: String? = nil
    var systemImage: String? = nil
    let action: () -> Void
    
    var body: some View {
        Button {
            withAnimation {
                action()
            }
        } label: {
            if title != nil && systemImage != nil {
                Label(title!, systemImage: systemImage!)
            } else if title != nil {
                Text(title!)
            } else if systemImage != nil {
                Image(systemName: systemImage!)
            }
        }
    }
}

struct AnimatedActionButton_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedActionButton(title: "New Button") {
            // do nothing
        }
    }
}
