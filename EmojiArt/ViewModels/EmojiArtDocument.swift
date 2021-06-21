//
//  EmojiArtDocument.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import SwiftUI

class EmojiArtDocument: ObservableObject {
    @Published private(set) var emojiArt: EmojiArtModel {
        didSet {
            scheduleAutoSave()
            if emojiArt.background != oldValue.background  {
                fetchBackground()
            }
        }
    }
    
    @Published var backgroundImage: UIImage?
    @Published var backgroundStatus = BackgroundStatus.idle
    @Published private(set) var selectedEmojis: Set<EmojiArtModel.Emoji> = []
    private var autoSaveTimer: Timer?
    
    init() {
        if let url = AutoSave.url, let autoSavedEmojiArt = try? EmojiArtModel(url: url) {
            emojiArt = autoSavedEmojiArt
            fetchBackground()
        } else {
            emojiArt = EmojiArtModel()
            //emojiArt.addEmoji("😅", at: Point(x: -200, y: -100), size: 80)
            //emojiArt.addEmoji("🏀", at: Point(x: 200, y: 100), size: 40)
        }
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
            backgroundStatus =  .fetching
            DispatchQueue.global(qos: .userInitiated).async {
                let imageData = try? Data(contentsOf: url)
                DispatchQueue.main.async { [weak self] in
                    // did we load the same background?
                    // we don't want to accidently load something that too long and is old
                    if self?.background == EmojiArtModel.Background.url(url) {
                        self?.backgroundStatus = .idle
                        if imageData != nil {
                            self?.backgroundImage = UIImage(data: imageData!)
                        }
                    }
                }
            }
        case .imageData(let data):
            backgroundImage = UIImage(data: data)
        case .blank:
            break
        }
    }
    
    // MARK: - Intents
    func setBackground(_ background: EmojiArtModel.Background) {
        emojiArt.background = background
    }
    
    func addEmoji(_ emoji: String, at location: Point, size: CGFloat = CGFloat(EmojiArtModel.Emoji.defaultEmojiSize)) {
        emojiArt.addEmoji(emoji, at: location, size: Int(size))
    }
    
    func moveEmoji(_ emoji: EmojiArtModel.Emoji, by offset: CGSize) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].location.x += Int(offset.width)
            emojiArt.emojis[index].location.y += Int(offset.height)
        }
    }
        
    func scaleEmoji(_ emoji: EmojiArtModel.Emoji, by scale: CGFloat) {
        if let index = emojiArt.emojis.index(matching: emoji) {
            emojiArt.emojis[index].size = Int((CGFloat(emojiArt.emojis[index].size) * scale)
                                                .rounded(.toNearestOrAwayFromZero))
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
    
    private func autosave() {
        if let url = AutoSave.url {
            save(to: url)
        }
    }
    
    private func scheduleAutoSave() {
        autoSaveTimer?.invalidate()
        autoSaveTimer = Timer.scheduledTimer(withTimeInterval: AutoSave.interval, repeats: false) { _ in
            self.autosave()
        }
    }
    
    private func save(to url: URL) {
        let thisFunction = "\(String(describing: self)).\(#function)"
        do {
            let data = try emojiArt.json()
            print("\(thisFunction) json = \(String(data: data, encoding: .utf8) ?? "nil")")
            try data.write(to: url)
        } catch let encodingError where encodingError is EncodingError {
            print("\(thisFunction) failed to encode with error: \(encodingError.localizedDescription)")
        } catch {
            print("\(thisFunction) error: \(error)")
        }
    }
    
    private struct AutoSave {
        static let filename = "AutoSaved.emojiart"
        static var url: URL? {
            let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            
            return documentDirectory?.appendingPathComponent(filename)
        }
        static let interval: TimeInterval = 5
    }
}
