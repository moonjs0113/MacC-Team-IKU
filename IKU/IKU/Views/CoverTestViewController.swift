//
//  CoverTestViewController.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/14.
//

import UIKit
import AVFoundation
import Combine

class CoverTestViewController: UIViewController {
    // MARK: - Properties
    private var subscriptions = Set<AnyCancellable>()
    
    // AVFoundation Properties
    private var videoInput: AVCaptureDeviceInput!
    private var videoOutput: AVCaptureMovieFileOutput!
    private let videoDevice = AVCaptureDevice.default(.builtInTrueDepthCamera, for: .video, position: .front)
    private var captureSession: AVCaptureSession =  {
        let session = AVCaptureSession()
        session.sessionPreset = .high
        return session
    }()
    
    // UI Properties
    private var cameraFrameView: UIStackView = {
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = .black.withAlphaComponent(0.5)
        
        let frameView = UIView()
        frameView.translatesAutoresizingMaskIntoConstraints = false
        frameView.backgroundColor = .clear
        
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .black.withAlphaComponent(0.5)
        
        let stackView = UIStackView(arrangedSubviews: [topView, frameView, bottomView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        NSLayoutConstraint.activate([
            frameView.heightAnchor.constraint(equalTo: frameView.widthAnchor, multiplier: 4/3),
            bottomView.heightAnchor.constraint(greaterThanOrEqualToConstant: 70),
        ])
        
        return stackView
    }()
    
    private var guideLabel: UILabel = {
        let guideLabel = UILabel()
        guideLabel.translatesAutoresizingMaskIntoConstraints = false
        guideLabel.text = "거리: XXcm\n가이드 라인에 아이의 얼굴을 맞춰 촬영해주세요!"
        guideLabel.textColor = .white
        guideLabel.textAlignment = .center
        guideLabel.font = .nexonGothicFont(ofSize: 13, weight: .bold)
        guideLabel.numberOfLines = 2
        let attrString = NSMutableAttributedString(string: guideLabel.text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        guideLabel.attributedText = attrString
        
        return guideLabel
    }()
    
    lazy private var recodeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(touchRecodeButton(_:)), for: .touchUpInside)
        
        // Button Image
        let emptyCircle = UIView()
        emptyCircle.translatesAutoresizingMaskIntoConstraints = false
        emptyCircle.isUserInteractionEnabled = false
        emptyCircle.backgroundColor = .clear
        emptyCircle.layer.borderColor = UIColor.white.cgColor
        emptyCircle.layer.borderWidth = 3
        emptyCircle.toCircle(anyCancellable: &subscriptions)
        
        let fillCircle = UIView()
        fillCircle.isUserInteractionEnabled = false
        fillCircle.translatesAutoresizingMaskIntoConstraints = false
        fillCircle.backgroundColor = .red
        fillCircle.toCircle(anyCancellable: &subscriptions)
        
        button.addSubview(emptyCircle)
        button.addSubview(fillCircle)
        
        NSLayoutConstraint.activate([
            emptyCircle.widthAnchor.constraint(equalTo: button.widthAnchor),
            emptyCircle.heightAnchor.constraint(equalTo: emptyCircle.widthAnchor),
            emptyCircle.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            emptyCircle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            fillCircle.widthAnchor.constraint(equalTo: emptyCircle.widthAnchor, constant: -10),
            fillCircle.heightAnchor.constraint(equalTo: fillCircle.widthAnchor),
            fillCircle.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            fillCircle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
        ])
        
        return button
    }()
    
    lazy private var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        
        let closeButton = UIButton(type: .system)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.setTitle("", for: .normal)
        closeButton.setImage(UIImage(systemName: "xmark",
                                     withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium)),
                             for: .normal)
        closeButton.tintColor = .white
        closeButton.addTarget(self, action: #selector(touchCloseButton(_:)), for: .touchUpInside)
        
        let helpButton = UIButton(type: .system)
        helpButton.translatesAutoresizingMaskIntoConstraints = false
        helpButton.setTitle("", for: .normal)
        helpButton.setImage(UIImage(systemName: "questionmark.circle",
                                    withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium)),
                            for: .normal)
        helpButton.tintColor = .white
        helpButton.addTarget(self, action: #selector(touchHelpButton(_:)), for: .touchUpInside)
        
        view.addSubview(closeButton)
        view.addSubview(helpButton)
        view.addSubview(guideLabel)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            
            helpButton.topAnchor.constraint(equalTo: view.topAnchor),
            helpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            guideLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor),
            guideLabel.topAnchor.constraint(equalTo: helpButton.bottomAnchor),
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])

        return view
    }()
    
    lazy private var previewLayer: AVCaptureVideoPreviewLayer = {
        let previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        previewLayer.bounds = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        previewLayer.position = CGPoint(x: self.view.bounds.midX, y: self.view.bounds.midY)
        previewLayer.videoGravity = .resizeAspectFill
        return previewLayer
    }()
    
    // MARK: - Methods
    private func setupSession() {
        guard let videoDevice else { return }
        
        captureSession.beginConfiguration()
        
        guard let videoInput = try? AVCaptureDeviceInput(device: videoDevice) else {
            captureSession.commitConfiguration()
            return
        }
        
        if captureSession.canAddInput(videoInput) {
            captureSession.addInput(videoInput)
        }
        
        let videoOutput = AVCaptureMovieFileOutput()
        if captureSession.canAddOutput(videoOutput) {
            captureSession.addOutput(videoOutput)
        }
        
        captureSession.commitConfiguration()
    }
    
    private func setupLayoutConstraint() {
        view.addSubview(cameraFrameView)
        view.addSubview(headerView)
        view.addSubview(recodeButton)
        
        NSLayoutConstraint.activate([
            cameraFrameView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraFrameView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cameraFrameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraFrameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: cameraFrameView.subviews[0].bottomAnchor, constant: -10),
            
            recodeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recodeButton.centerYAnchor.constraint(equalTo: cameraFrameView.subviews[2].centerYAnchor),
            recodeButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.18),
        ])
    }
    
    // MARK: - Objc-C Methods
    @objc private func touchCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func touchHelpButton(_ sender: UIButton) {
        print(#function)
    }
    
    @objc private func touchRecodeButton(_ sender: UIButton) {
        print(#function)
        print(sender.subviews)
    }
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.layer.addSublayer(previewLayer)
        setupLayoutConstraint()
        setupSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            self.captureSession.startRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
}
