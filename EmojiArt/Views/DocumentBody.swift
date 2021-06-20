//
//  DocumentBody.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

struct DocumentBody: View {
    @ObservedObject var document: EmojiArtDocument
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .position(Point(x: 0, y: 0).centerPoint(in: geometry.frame(in: .local)))
                )
                if document.backgroundStatus == .fetching {
                    ProgressView()
                        .scaleEffect(2)
                }
                else {
                    ForEach(document.emojis) { emoji in
                        Text(emoji.text)
                            .font(.system(size: fontSize(for: emoji)))
                            .position(position(for: emoji, in: geometry))
                    }
                }
            }
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return onDropItems(providers: providers, at: location, in: geometry)
            }
        }
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        emoji.location.centerPoint(in: geometry.frame(in: .local))
    }
    
    private func onDropItems(providers: [NSItemProvider], at location: CGPoint, in geometry: GeometryProxy) -> Bool {
        var found = providers.loadObjects(ofType: URL.self)  { url in
            document.setBackground(.url(url.imageURL))
        }
        
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                if let data = image.jpegData(compressionQuality: 1.0) {
                    document.setBackground(.imageData(data))
                }
            }
        }

        if !found {
            found = providers.loadObjects(ofType: String.self) { items in
                if let emoji = items.first, emoji.isEmoji {
                    document.addEmoji(String(emoji), at: Point(point: location, in: geometry.frame(in: .local)))
                }
            }
        }
        
        return found
    }
}

struct DocumentBody_Previews: PreviewProvider {
    static var previews: some View {
        DocumentBody(document: EmojiArtDocument())
    }
}
