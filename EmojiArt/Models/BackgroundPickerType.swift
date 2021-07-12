//
//  BackgroundPickerType.swift
//  EmojiArt
//
//  Created by Chad Smith on 7/11/21.
//

import Foundation

enum BackgroundPickerType: Identifiable {
    case camera
    case library
    
    var id: BackgroundPickerType { self }
}
