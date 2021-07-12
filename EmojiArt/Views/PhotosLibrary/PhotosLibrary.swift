//
//  PhotosLibrary.swift
//  EmojiArt
//
//  Created by Chad Smith on 7/11/21.
//

import SwiftUI

struct PhotosLibrary: View {
    var handlePickedImage: (UIImage?) -> Void
    
    var body: some View {
        PhotosLibrary { image in
            handlePickedImage(image)
        }
    }
}

struct PhotosLibrary_Previews: PreviewProvider {
    static var previews: some View {
        PhotosLibrary { _ in
            
        }
    }
}
