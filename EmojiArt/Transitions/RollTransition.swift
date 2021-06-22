//
//  RollTransition.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/22/21.
//

import SwiftUI

struct RollTransition {
    var insertionOffset: (x: CGFloat, y: CGFloat)
    var removalOffset: (x: CGFloat, y: CGFloat)
    
    var transition: AnyTransition {
        AnyTransition.asymmetric(insertion: .offset(x: insertionOffset.x, y: insertionOffset.y), removal: .offset(x: removalOffset.x, y: removalOffset.y))
    }
}
