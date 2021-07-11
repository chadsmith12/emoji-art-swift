//
//  CompactableInContextMenu.swift
//  EmojiArt
//
//  Created by Chad Smith on 7/11/21.
//

import SwiftUI

/// View Modifier that will wrap your content into a single button context button if, and only if, it's the compact size class
struct CompactableInContextMenu: ViewModifier {
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var isCompact: Bool {
        horizontalSizeClass == .compact
    }
    
    func body(content: Content) -> some View {
        if isCompact {
            Button {
                
            } label: {
                Image(systemName: "ellipsis.circle")
            }
            .contextMenu {
                content
            }
        } else {
            content
        }
    }
}

extension View {
    func compactableToolbar<Content>(@ViewBuilder content: () -> Content) -> some View where Content: View {
        self.toolbar {
            content().modifier(CompactableInContextMenu())
        }
    }
}
