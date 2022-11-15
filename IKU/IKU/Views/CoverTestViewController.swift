//
//  CoverTestViewController.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/14.
//

import UIKit
import AVFoundation
import Combine
import ARKit
import SceneKit

final class CoverTestViewController: UIViewController {
    // MARK: - Properties
    public let videoManager: VideoManager = VideoManager()
    private var anyCancellable = Set<AnyCancellable>()
    private var recordButtonLayoutConstraint: NSLayoutConstraint = .init()
    private var transformVisualization: ARSceneManager = ARSceneManager()
    private var faceAnchors: [ARFaceAnchor: ARSCNViewDelegate] = [:]
    
    // UI Properties
    private var sceneView: ARSCNView = ARSCNView()
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
        guideLabel.text = "거리: 0cm\n가이드 라인에 아이의 얼굴을 맞춰 촬영해주세요!"
        guideLabel.textColor = .white
        guideLabel.font = .nexonGothicFont(ofSize: 13, weight: .bold)
        guideLabel.numberOfLines = 2
        let attrString = NSMutableAttributedString(string: guideLabel.text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                value: paragraphStyle,
                                range: NSMakeRange(0, attrString.length))
        guideLabel.attributedText = attrString
        
        return guideLabel
    }()
    
    lazy private var recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("", for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: #selector(touchRecordButton(_:)), for: .touchUpInside)
        
        // Button Image
        let emptyCircle = UIView()
        emptyCircle.translatesAutoresizingMaskIntoConstraints = false
        emptyCircle.isUserInteractionEnabled = false
        emptyCircle.backgroundColor = .clear
        emptyCircle.layer.borderColor = UIColor.white.cgColor
        emptyCircle.layer.borderWidth = 4
        bindLayout(view: emptyCircle)
        
        let fillCircle = UIView()
        fillCircle.isUserInteractionEnabled = false
        fillCircle.translatesAutoresizingMaskIntoConstraints = false
        fillCircle.backgroundColor = .red
        bindLayout(view: fillCircle)
        
        button.addSubview(emptyCircle)
        button.addSubview(fillCircle)
        
        recordButtonLayoutConstraint = fillCircle.widthAnchor.constraint(equalTo: emptyCircle.widthAnchor, constant: -13)
        
        NSLayoutConstraint.activate([
            emptyCircle.widthAnchor.constraint(equalTo: button.widthAnchor),
            emptyCircle.heightAnchor.constraint(equalTo: emptyCircle.widthAnchor),
            emptyCircle.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            emptyCircle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            recordButtonLayoutConstraint,
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
    
    // MARK: - Methods
    private func setupARScene() {
        sceneView.delegate = self
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)
        sceneView.isHidden = true
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
    }
    
    private func setupLayoutConstraint() {
        let previewLayer = videoManager.createPreviewLayer(view: view)
        view.layer.addSublayer(previewLayer)
        
        view.addSubview(cameraFrameView)
        view.addSubview(headerView)
        view.addSubview(recordButton)
        
        NSLayoutConstraint.activate([
            cameraFrameView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraFrameView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cameraFrameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraFrameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: cameraFrameView.subviews[0].bottomAnchor, constant: -10),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.centerYAnchor.constraint(equalTo: cameraFrameView.subviews[2].centerYAnchor),
            recordButton.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.18),
        ])
    }
    
    private func configureBinding() {
        videoManager.didFinishRecordingTo = goToSelectPhotoViewController
    }
    
    private func bindLayout(view: UIView) {
        view.publisher(for: \.bounds, options: [.new, .initial, .old, .prior])
            .receive(on: DispatchQueue.main)
            .filter { trunc($0.width) == trunc($0.height) }
            .map { $0.width / 2 }
            .assign(to: \.layer.cornerRadius, on: view)
            .store(in: &anyCancellable)
    }
    
    private func goToSelectPhotoViewController(url: URL) {
        // Smile Code
        print(url)
    }
    
    public func resetTracking() {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    // MARK: - Objc-C Methods
    @objc private func touchCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func touchHelpButton(_ sender: UIButton) {
        print(#function)
    }
    
    @objc private func touchRecordButton(_ sender: UIButton) {
        videoManager.run { [weak self] isRecording in
            guard let self = self,
                  let view = self.recordButtonLayoutConstraint.firstItem as? UIView else {
                return
            }
            UIView.animate(withDuration: 0.3) {
                self.recordButtonLayoutConstraint.constant = isRecording ? -45 : -13
                if isRecording {
                    self.anyCancellable.removeAll()
                    view.layer.cornerRadius = 5
                } else {
                    self.bindLayout(view: view)
                }
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        }
    }
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayoutConstraint()
//        setupARScene()
        configureBinding()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else {
                return
            }
            self.videoManager.captureSession.startRunning()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        resetTracking()
    }
}

// MARK: - Delegate
extension CoverTestViewController: ARSessionDelegate, ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            if node.childNodes.isEmpty {
                if let contentNode = self.transformVisualization.renderer(renderer, nodeFor: faceAnchor) {
                    node.addChildNode(contentNode)
                    self.faceAnchors[faceAnchor] = self.transformVisualization
                }
            }
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor,
              let _ = faceAnchors[faceAnchor],
              let contentNode = transformVisualization.contentNode else {
            return
        }
        
        transformVisualization.renderer(renderer, didUpdate: contentNode, for: anchor)
        
        let end = transformVisualization.leftEyeNode.presentation.worldPosition
        let start = sceneView.pointOfView?.worldPosition
        
        if let start {
            calculateDistance(start: start, end: end)
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        faceAnchors[faceAnchor] = nil
    }
    
    func calculateDistance(start: SCNVector3, end: SCNVector3) {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z

        let distance = (sqrt(pow(dx, 2) + pow(dy, 2) + pow(dz, 2))) * 100
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.guideLabel.text = "거리: \(Int(round(distance)))cm\n가이드 라인에 아이의 얼굴을 맞춰 촬영해주세요!"
        }
        print(String(format: "Distance: %.2fcm", distance))
    }
}
