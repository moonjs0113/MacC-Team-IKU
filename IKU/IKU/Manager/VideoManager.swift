//
//  VideoManager.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/15.
//

import AVFoundation
import UIKit

class VideoManager: NSObject {
    // MARK: - Properties
    private var videoInput: AVCaptureDeviceInput!
    private var videoOutput: AVCaptureMovieFileOutput!
    private let videoDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
    private var saveURL: URL?
    
    public var captureSession: AVCaptureSession =  {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        return session
    }()
    
    public var didFinishRecordingTo: (URL) -> () = { _ in }
    
    // MARK: - Methods
    // Private Fuction
    private func setupSession() {
        guard let videoDevice else { return }
        
        captureSession.beginConfiguration()
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            captureSession.commitConfiguration()
            return
        }
        
        self.videoInput = videoInput
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        
        videoOutput = AVCaptureMovieFileOutput()
        
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
    }
    
    private func tempURL() -> URL? {
        let directory = NSTemporaryDirectory() as NSString
        
        if directory != "" {
            let path = directory.appendingPathComponent(NSUUID().uuidString + ".mp4")
            return URL(fileURLWithPath: path)
        }
        
        return nil
    }
    
    private func startRecoding() {
        let connection = videoOutput.connection(with: AVMediaType.video)
        
        // orientation을 설정해야 가로/세로 방향에 따른 레코딩 출력이 잘 나옴.
        if (connection?.isVideoOrientationSupported)! {
            connection?.videoOrientation = .portrait
        }
        
        let device = videoInput.device
        if (device.isSmoothAutoFocusSupported) {
          do {
            try device.lockForConfiguration()
            device.isSmoothAutoFocusEnabled = false
            device.unlockForConfiguration()
          } catch {
            print("Error setting configuration: \(error)")
          }
        }
        
        saveURL = tempURL()
        if let saveURL {
            videoOutput.startRecording(to: saveURL, recordingDelegate: self)
        }
    }
    
    private func stopRecoding() {
        videoOutput.stopRecording()
    }
    
    // Public Fuction
    public func createPreviewLayer(view: UIView) -> AVCaptureVideoPreviewLayer {
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.bounds = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
        previewLayer.position = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }
    
    public func run(_ completeHandler: @escaping (Bool) -> Void) {
        let isRecording = videoOutput.isRecording
        isRecording
        ? stopRecoding()
        : startRecoding()
        completeHandler(!isRecording)
    }
    
    // MARK: - Life Cycles
    override init() {
        super.init()
        self.setupSession()
    }
}

extension VideoManager: AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        didFinishRecordingTo(outputFileURL)
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        print(#function)
    }
}
