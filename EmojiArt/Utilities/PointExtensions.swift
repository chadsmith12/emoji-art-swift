//
//  PointExtensions.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/18/21.
//

import SwiftUI

extension Point {
    func centerPoint(in rect: CGRect) -> CGPoint {
        let center = rect.center
        
        return CGPoint(x: center.x + CGFloat(self.x), y: center.y + CGFloat(self.y))
    }
    
    
    /// Convience to allow creating a Point from the center of a CGPoint
    /// - Parameters:
    ///   - point: The CGPoint we are creating the point from
    ///   - rect: The rect we want the center of to get the cordinates from
    init(point: CGPoint, in rect: CGRect) {
        let center = rect.center
        
        self.x = Int(point.x - center.x)
        self.y = Int(point.y - center.y)
    }
}
