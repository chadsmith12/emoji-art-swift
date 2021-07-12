//
//  PhotosLibraryViewController.swift
//  EmojiArt
//
//  Created by Chad Smith on 7/11/21.
//

import SwiftUI
import PhotosUI

struct PhotosLibraryViewController: UIViewControllerRepresentable {
    var handlePickedImage: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedImage: handlePickedImage)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        // nothing to do
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var handlePickedImage: (UIImage?) -> Void
        
        init(handlePickedImage: @escaping (UIImage?) -> Void) {
            self.handlePickedImage = handlePickedImage
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            let items = results.map { result in
                result.itemProvider
            }
            let found = items.loadObjects(ofType: UIImage.self) { [weak self] image in
                self?.handlePickedImage(image)
            }
            
            if !found {
                self.handlePickedImage(nil)
            }
        }
    }
}
