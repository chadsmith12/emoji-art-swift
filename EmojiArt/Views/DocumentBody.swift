//
//  DocumentBody.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

struct DocumentBody: View {
    @ObservedObject var document: EmojiArtDocument
    @State private var steadyStateZoomScale: CGFloat = 1
    @GestureState private var gestureZoomScale: CGFloat = 1
    @State private var steadyStatePanOffset = CGSize.zero
    @GestureState private var gesturePanOffset = CGSize.zero
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white.overlay(
                    OptionalImage(uiImage: document.backgroundImage)
                        .scaleEffect(zoomScale)
                        .position(Point(x: 0, y: 0).centerPoint(in: geometry.frame(in: .local), from: panOffset, zoomScale: zoomScale))
                )
                .gesture(doubleTapToZoom(in: geometry.size))
                if document.backgroundStatus == .fetching {
                    ProgressView()
                        .scaleEffect(2)
                }
                else {
                    ForEach(document.emojis) { emoji in
                        DocumentEmojiView(content: emoji.text, isSelected: document.isEmojiSelected(emoji))
                            .font(.system(size: fontSize(for: emoji)))
                            .scaleEffect(zoomScale)
                            .position(position(for: emoji, in: geometry))
                            .onTapGesture {
                                document.selectEmoji(emoji)
                            }
                    }
                }
            }   
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return onDropItems(providers: providers, at: location, in: geometry)
            }
            .onTapGesture(perform: document.unselectAll)
            .gesture(panGesture().simultaneously(with: zoomGesture()))
        }
    }
    
    private func fontSize(for emoji: EmojiArtModel.Emoji) -> CGFloat {
        CGFloat(emoji.size)
    }
    
    private func position(for emoji: EmojiArtModel.Emoji, in geometry: GeometryProxy) -> CGPoint {
        emoji.location.centerPoint(in: geometry.frame(in: .local), from: panOffset, zoomScale: zoomScale)
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
                    document.addEmoji(
                        String(emoji),
                        at: Point(point: location, in: geometry.frame(in: .local), from: panOffset, zoomScale: zoomScale),
                        size: CGFloat(EmojiArtModel.Emoji.defaultEmojiSize) / zoomScale)
                }
            }
        }
        
        return found
    }
    
    private func zoomToFit(image: UIImage?, in size: CGSize) {
        if let image = image, image.size.width > 0, image.size.height > 0, size.width > 0, size.height > 0 {
            let hZoom = size.width / image.size.width
            let vZoom = size.height / image.size.height
            steadyStatePanOffset = .zero
            steadyStateZoomScale = min(hZoom, vZoom)
        }
    }
    
    private func doubleTapToZoom(in size: CGSize) -> some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation{
                    zoomToFit(image: document.backgroundImage, in: size)
                }
            }
    }
    
    private func zoomGesture() -> some Gesture {
        MagnificationGesture()
            .updating($gestureZoomScale) { latestGestureScale, gestureZoomScale, _ in
                gestureZoomScale = latestGestureScale
            }
            .onEnded { gestureScaleAtEnd in
                steadyStateZoomScale *= gestureScaleAtEnd
            }
    }
    
    private func panGesture() -> some Gesture {
        DragGesture()
            .updating($gesturePanOffset) { latestDragGestureValue, gesturePanOffset, _ in
                gesturePanOffset = latestDragGestureValue.translation / zoomScale
            }
            .onEnded { finalDragGestureVale in
                steadyStatePanOffset = steadyStatePanOffset + (finalDragGestureVale.translation / zoomScale)
            }
    }
}

struct DocumentBody_Previews: PreviewProvider {
    static var previews: some View {
        DocumentBody(document: EmojiArtDocument())
    }
}
