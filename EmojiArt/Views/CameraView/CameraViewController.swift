//
//  CameraViewController.swift
//  EmojiArt
//
//  Created by Chad Smith on 7/11/21.
//

import SwiftUI

struct CameraViewController: UIViewControllerRepresentable {
    /// Determines if the camera is currently available on this platform
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    /// The action that is caled when the image has been picked or taken
    /// The image could be nil if the user canceled this action
    var handlePickedImage: (UIImage?) -> Void
    
    func makeCoordinator() -> Coordinator {
        Coordinator(handlePickedImage: handlePickedImage)
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.allowsEditing = true
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {
        // Nothing to do
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var handlePickedImage: (UIImage?) -> Void
        
        init(handlePickedImage: @escaping (UIImage?) -> Void) {
            self.handlePickedImage = handlePickedImage
        }
        
        
        /// Called when the image picker was cancled, and nothing was selected
        /// - Parameter picker: The controller object managing the image picker interface.
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            handlePickedImage(nil)
        }
        
        
        /// Called when the user has picked/taken the picture
        /// - Parameters:
        ///   - picker: The controller object managing the image picker interface
        ///   - info: Dictionary of the image information taken
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // attempt to get the edited image if they edited it, otherwise get the original
            let pickedImage = (info[.editedImage] ?? info[.originalImage]) as? UIImage
            if let temp = info[.mediaMetadata] {
                print(temp)
            }
            
            handlePickedImage(pickedImage)
        }
    }
}
