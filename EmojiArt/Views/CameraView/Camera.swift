//
//  Camera.swift
//  EmojiArt
//
//  Created by Chad Smith on 7/11/21.
//

import SwiftUI

struct Camera: View {
    var handleSelectedImage: (UIImage?) -> Void
    var body: some View {
        CameraViewController { selectedImage in
            handleSelectedImage(selectedImage)
        }
    }
}

struct Camera_Previews: PreviewProvider {
    static var previews: some View {
        Camera { _ in
            // Nothing in the preview
        }
    }
}
