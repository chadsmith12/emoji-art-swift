//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI
import Combine
import UniformTypeIdentifiers

class EmojiArtDocument: ReferenceFileDocument {
    static var readableContentTypes = [UTType.emojiart]
    static var writableContentTypes = [UTType.emojiart]
    
    required init(configuration: ReadConfiguration) throws {
        if let data = configuration.file.regularFileContents {
            emojiArt = try EmojiArtModel(json: data)
            fetchBackground()
        } else {
            throw CocoaError(.fileReadCorruptFile)
        }
    }
    
    func snapshot(contentType: UTType) throws -> Data {
        try emojiArt.json()
    }
    
    func fileWrapper(snapshot: Data, configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: snapshot)
    }
    
    typealias Snapshot = Data
    
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            if emojiArt.background != oldValue.background  {
                fetchBackground()
            }
        }
    }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundStatus = BackgroundStatus.idle
    @Published private(set) var selectedEmojis: Set<EmojiArtModel.Emoji> = []
    private var backgroundCancellable: AnyCancellable?
    
    init() {
        emojiArt = EmojiArtModel()
    }
    
    var emojis: [EmojiArtModel.Emoji] {
        emojiArt.emojis
    }
    
    var background: EmojiArtModel.Background {
        emojiArt.background
    }
    
    private func fetchBackground() {
        backgroundImage = nil
        switch emojiArt.background {
        case .url(let url):
            // go and download the image in the background
            // once done, update the image on the main UI thread
            fetchBackgroundFrom(url: url)
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    private func fetchBackgroundFrom(url: URL) {
        backgroundStatus =  .fetching
        let session = URLSession.shared
        let publisher = session.dataTaskPublisher(for: url)
            .map{(data, urlResponse) in UIImage(data: data)}
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
        
        backgroundCancellable = publisher
            .sink { [weak self] image in
                self?.backgroundImage = image
                self?.backgroundStatus = (image != nil) ? .idle : .failed(url)
            }
    }
    
    // MARK: - Intents
    func setBackground(_ background: EmojiArtModel.Background, undoManager: UndoManager?) {
        undoablyPerform(operation: "Set Background", with: undoManager) {
            emojiArt.background = background
        }
    }
    
    func addEmoji(_ emoji: String, at location: Point, size: CGFloat = CGFloat(EmojiArtModel.Emoji.defaultEmojiSize), undoManager: UndoManager?) {
        undoablyPerform(operation: "Add \(emoji)", with: undoManager) {
            emojiArt.addEmoji(emoji, at: location, size: Int(size))
        }
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize, undoManager: UndoManager?) {
        undoablyPerform(operation: "Move", with: undoManager) {
            if let index = emojiArt.emojis.index(matching: emoji) {
                emojiArt.emojis[index].location.x += Int(offset.width)
                emojiArt.emojis[index].location.y += Int(offset.height)
            }
        }
    }
        
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat, undoManager: UndoManager?) {
        undoablyPerform(operation: "Scale Emoji", with: undoManager) {
            if let index = emojiArt.emojis.index(matching: emoji) {
                emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale)
                                                    .rounded(.toNearestOrAwayFromZero))
            }
        }
    }
    
    func selectEmoji(_ emoji: EmojiArtModel.Emoji) {
        if isEmojiSelected(emoji) {
            selectedEmojis.remove(emoji)
        }
        else {
            selectedEmojis.insert(emoji)
        }
    }
    
    func isEmojiSelected(_ emoji: EmojiArtModel.Emoji) -> Bool {
        selectedEmojis.contains(emoji)
    }
    
    func unselectAll() {
        selectedEmojis = []
    }
    
    // MARK: Undo
    private func undoablyPerform(operation: String, with undoManager: UndoManager? = nil, action: () -> Void) {
        let oldEmojiArt = emojiArt
        action()
        undoManager?.registerUndo(withTarget: self) { myself in
            myself.undoablyPerform(operation: operation) {
                myself.emojiArt = oldEmojiArt
            }
        }
        undoManager?.setActionName(operation)
    }
}
