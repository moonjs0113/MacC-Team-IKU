//
//  PHPhotoManager.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/19.
//

import UIKit
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
