//
//  WrapInNavigationView.swift
//  EmojiArt
//
//  Created by Chad Smith on 7/10/21.
//

import SwiftUI

extension View {
    /// Wraps the current view in a navigation view, if the users current device is not an iPad
    /// - Parameter dismiss: The action to take when it is dismissed
    /// - Returns: The view wrapped in a navigation view with a Close button
    @ViewBuilder
    func wrapInNavigationView(_ dismiss: (() -> Void)?) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            NavigationView {
                self
                    .navigationBarTitleDisplayMode(.inline)
                    .dismissable(dismiss)
            }
            .navigationViewStyle(StackNavigationViewStyle())
        } else {
            self
        }
    }
    
    
    /// Adds a Close button to the toolbar that will dismiss the current view
    /// - Parameter dismiss: The action to take when it is dismissed
    /// - Returns: A toolbar that has a Close button that preforms the dismiss action
    @ViewBuilder
    func dismissable(_ dismiss: (() -> Void)?) -> some View {
        if UIDevice.current.userInterfaceIdiom != .pad, let dismiss = dismiss {
            self.toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                }
            }
        }
        else {
            self
        }
    }
}
