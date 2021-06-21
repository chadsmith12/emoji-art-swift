//
//  EmojiArtModel.swift
//  EmojiArt
//
//  Created by Chad Smith on 6/17/21.
//

import Foundation

struct EmojiArtModel: Codable {
    private var currentEmojiId = 0
    var background: Background = .blank
    var emojis = [Emoji]()
    
    init() {
        // blank to keep people from thinking they can init this document and set the emojis
    }
    
    init(json: Data) throws {
        self = try JSONDecoder().decode(EmojiArtModel.self, from: json)
    }
    
    init(url: URL) throws {
        let data = try Data(contentsOf: url)
        self = try EmojiArtModel(json: data)
    }
    
    /**
     Adds a new emoji to the list of emojis inside of the document
     */
    mutating func addEmoji(_ text: String, at location: Point, size: Int) {
        currentEmojiId += 1
        emojis.append(Emoji(text: text, location: location, size: size, id: currentEmojiId))
    }
    
    
    /// Gets the data encoded as a JSON
    /// - Throws: throws if the JSONEncoder fails
    /// - Returns: The Data encoded as JSON
    func json() throws -> Data {
        return try JSONEncoder().encode(self)
    }
    
    struct Emoji: Identifiable, Hashable, Codable {
        static let defaultEmojiSize = 40
        
        let text: String
        var location: Point
        var size: Int
        let id: Int
        
        // fileprivate make it private outside of this file, but public inside this file
        // this keeps people from being able to create an emoji without going through the method we provide
        fileprivate init(text: String, location: Point, size: Int, id: Int) {
            self.text = text
            self.location = location
            self.size = size
            self.id = id
        }
    }
}
