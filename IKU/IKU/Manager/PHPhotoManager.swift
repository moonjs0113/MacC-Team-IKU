//
//  PHPhotoManager.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/19.
//

import UIKit
import SwiftUI
import PhotosUI

class PHPhotoManager: NSObject {
    static let share: PHPhotoManager = PHPhotoManager()
    
    func saveVideo(url: URL, completeHandler: @escaping () -> Void, errorHandler: @escaping () -> Void) {
        PHPhotoLibrary.requestAuthorization(for: .addOnly) { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                break
            case .authorized:
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
                } completionHandler: { isSaveComplete, _ in
                    if isSaveComplete {
                        completeHandler()
                    }
                }
            case .restricted, .denied, .limited:
                fallthrough
            @unknown default:
                errorHandler()
            }
        }
    }
    
    func createPHPickerViewController(_ delegate: PHPickerViewControllerDelegate) -> PHPickerViewController {
        var configuration = PHPickerConfiguration()
        configuration.filter = .images
        configuration.selectionLimit = 1
        let pickerViewController = PHPickerViewController(configuration: configuration)
        pickerViewController.delegate = delegate
        return pickerViewController
    }
    
    override private init() {
        super.init()
    }
}

struct PHPickerView: UIViewControllerRepresentable {
    func makeCoordinator() -> Coordinator {
        return PHPickerView.Coordinator(parent: self)
    }
    
    @Binding var images : UIImage?
    @Binding var picker : Bool
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {
        
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var parent: PHPickerView
        
        init(parent: PHPickerView) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.picker.toggle()
            
            for img in results {
                if img.itemProvider.canLoadObject(ofClass: UIImage.self){
                    img.itemProvider.loadObject(ofClass: UIImage.self) { (image, err) in
                        guard let selectedImage = image else {
                            print("err ")
                            return
                        }
                        if let uiImage = selectedImage as? UIImage {
                            self.parent.images = uiImage
                        }
                    }
                } else {
                    print("cannot be loaded ")
                }
            }
        }
    }
}
