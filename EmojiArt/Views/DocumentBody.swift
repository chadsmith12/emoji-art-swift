//
//  DocumentBody.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

struct DocumentBody: View {
    @Environment(\.undoManager) var undoManager
    @ObservedObject var document: EmojiArtDocument
    @SceneStorage("DocumentBody.steadyStateZoomScale") private var steadyStateZoomScale: CGFloat = 1
    @SceneStorage("DocumentBody.steadyStatePanOffset") private var steadyStatePanOffset = CGSize.zero
    @State private var alertToShow: IdentifiableAlert?
    @State private var autoZoom = false
    @State private var backgroundPicker: BackgroundPickerType? = nil
    @GestureState private var gestureZoomScale: CGFloat = 1
    @GestureState private var gesturePanOffset = CGSize.zero
    @GestureState private var gestureEmojiOffset = CGSize.zero
    
    private var zoomScale: CGFloat {
        steadyStateZoomScale * gestureZoomScale
    }
    
    private var panOffset: CGSize {
        (steadyStatePanOffset + gesturePanOffset) * zoomScale
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.white
                OptionalImage(uiImage: document.backgroundImage)
                    .scaleEffect(zoomScale)
                    .position(Point(x: 0, y: 0).centerPoint(in: geometry.frame(in: .local), from: panOffset, zoomScale: zoomScale))
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
                            .gesture(self.dragEmojis(for: emoji))
                    }
                }
            }   
            .clipped()
            .onDrop(of: [.plainText, .url, .image], isTargeted: nil) { providers, location in
                return onDropItems(providers: providers, at: location, in: geometry)
            }
            .onTapGesture(perform: document.unselectAll)
            .gesture(panGesture().simultaneously(with: zoomGesture()))
            .alert(item: $alertToShow) { alertToShow in
                alertToShow.alert()
            }
            .onChange(of: document.backgroundStatus) { status in
                switch status {
                case .failed(let url):
                    showBackgroundStatusFailedAlert(url)
                default: break
                }
            }
            .onReceive(document.$backgroundImage) { image in
                if autoZoom {
                    zoomToFit(image: image, in: geometry.size)
                }
            }
            .compactableToolbar {
                AnimatedActionButton(title: "Paste", systemImage: "doc.on.clipboard") {
                    pasteBackground()
                }
                if CameraViewController.isAvailable {
                    AnimatedActionButton(title: "Take Photo", systemImage: "camera") {
                        backgroundPicker = .camera
                    }
                }
                AnimatedActionButton(title: "Select Background", systemImage: "photo") {
                    backgroundPicker = .library
                }
                if let undoManager = undoManager {
                    if undoManager.canUndo {
                        AnimatedActionButton(title: undoManager.undoActionName, systemImage: "arrow.uturn.backward") {
                            undoManager.undo()
                        }
                    }
                    if undoManager.canRedo {
                        AnimatedActionButton(title: undoManager.redoActionName, systemImage: "arrow.uturn.forward") {
                            undoManager.redo()
                        }
                    }
                }
            }
            .sheet(item: $backgroundPicker) { pickerType in
                switch pickerType {
                case .camera: Camera { image in
                    handlePickedImage(image)
                }
                case .library: PhotosLibraryViewController { image in
                    handlePickedImage(image)
                }
                }
            }
        }
    }
    
    private func handlePickedImage(_ image: UIImage?) {
        autoZoom = true
        if let imageData = image?.jpegData(compressionQuality: 1.0) {
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        }
        
        backgroundPicker = nil
    }
    
    private func pasteBackground() {
        if let imageData = UIPasteboard.general.image?.jpegData(compressionQuality: 1.0) {
            document.setBackground(.imageData(imageData), undoManager: undoManager)
        } else if let url = UIPasteboard.general.url?.imageURL {
            document.setBackground(.url(url), undoManager: undoManager)
        } else {
            alertToShow = IdentifiableAlert(title: "Paste Background", message: "There is no image currently on the pasteboard")
        }
    }
    
    private func showBackgroundStatusFailedAlert(_ url: URL) {
        alertToShow = IdentifiableAlert(id: "fetch failed for \(url.absoluteString)") {
            Alert(title: Text("Background Image Fetch"), message: Text("Couldn't load image from \(url)"), dismissButton: .default(Text("Ok")))
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
            document.setBackground(.url(url.imageURL), undoManager: undoManager)
        }
        
        if !found {
            found = providers.loadObjects(ofType: UIImage.self) { image in
                autoZoom = true
                if let data = image.jpegData(compressionQuality: 1.0) {
                    autoZoom = true
                    document.setBackground(.imageData(data), undoManager: undoManager)
                }
            }
        }

        if !found {
            found = providers.loadObjects(ofType: String.self) { items in
                if let emoji = items.first, emoji.isEmoji {
                    document.addEmoji(
                        String(emoji),
                        at: Point(point: location, in: geometry.frame(in: .local), from: panOffset, zoomScale: zoomScale),
                        size: CGFloat(EmojiArtModel.Emoji.defaultEmojiSize) / zoomScale,
                        undoManager: undoManager)
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
    
    private func dragEmojis(for emoji: EmojiArtModel.Emoji) -> some Gesture {
        let isSelected = document.isEmojiSelected(emoji)
        
        return DragGesture()
            .updating($gestureEmojiOffset) { latestDragGestureValue, gestureEmojiOffset, transaction in
                gestureEmojiOffset = latestDragGestureValue.translation / self.zoomScale
            }
            .onEnded { finalDragGestureValue in
                let distanceDragged = finalDragGestureValue.translation / self.zoomScale
                if isSelected  {
                    for emoji in document.selectedEmojis {
                        self.document.moveEmoji(emoji, by: distanceDragged, undoManager: undoManager)
                    }
                } else {
                    self.document.moveEmoji(emoji, by: distanceDragged, undoManager: undoManager)
                }
            }
    }
}

struct DocumentBody_Previews: PreviewProvider {
    static var previews: some View {
        DocumentBody(document: EmojiArtDocument())
    }
}
