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
import SwiftUI

final class CoverTestViewController: UIViewController {
    // MARK: - Properties
    private var viewModel: CoverTestViewModel = CoverTestViewModel()
    private var viewStatus: TestGuide = .incorrectDistance
    var selectedEye: Eye = .left
    
    // UI Properties
    private var sceneView: ARSCNView = ARSCNView()
    
    private var guideFrameImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "CameraFrame"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    
    private var handGuideFrameImageStackView: UIStackView = {
        let left = UIImageView(image: UIImage(named: "Right_Test_HandGuide"))
        left.contentMode = .scaleAspectFit
        left.layer.opacity = 0
        
        let right = UIImageView(image: UIImage(named: "Left_Test_HandGuide"))
        right.contentMode = .scaleAspectFit
        right.layer.opacity = 0
        
        let stackView = UIStackView(arrangedSubviews: [left, right])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        return stackView
    }()
    
    private var cameraFrameView: UIStackView = {
        let backgroundAlpha: CGFloat = 0.8
        let topView = UIView()
        topView.translatesAutoresizingMaskIntoConstraints = false
        topView.backgroundColor = .black.withAlphaComponent(backgroundAlpha)
        
        let frameView = UIView()
        frameView.translatesAutoresizingMaskIntoConstraints = false
        frameView.backgroundColor = .clear
        
        let bottomView = UIView()
        bottomView.translatesAutoresizingMaskIntoConstraints = false
        bottomView.backgroundColor = .black.withAlphaComponent(backgroundAlpha)
        
        let stackView = UIStackView(arrangedSubviews: [topView, frameView, bottomView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        
        return stackView
    }()
    
    private var distanceLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "please keep this distance"
        label.textColor = .white
        label.backgroundColor = .clear
        label.font = .nexonGothicFont(ofSize: 17, weight: .bold)
        label.numberOfLines = 2
        let attrString = NSMutableAttributedString(string: label.text ?? "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4
        paragraphStyle.alignment = .center
        attrString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                value: paragraphStyle,
                                range: NSMakeRange(0, attrString.length))
        label.attributedText = attrString
        
        return label
    }()
    
    private var guideLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Fit the child's face to the border"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .nexonGothicFont(ofSize: 17)
        label.numberOfLines = 2
        return label
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
        emptyCircle.layer.borderWidth = 2
        emptyCircle.bindLayout(anyCancellable: &viewModel.anyCancellable)
        
        let fillCircle = UIView()
        fillCircle.isUserInteractionEnabled = false
        fillCircle.translatesAutoresizingMaskIntoConstraints = false
        fillCircle.backgroundColor = .red
        fillCircle.bindLayout(anyCancellable: &viewModel.anyCancellable)
        
        button.addSubview(emptyCircle)
        button.addSubview(fillCircle)
        
        viewModel.recordButtonLayoutConstraint = fillCircle.widthAnchor.constraint(equalTo: emptyCircle.widthAnchor, constant: -10)
        
        NSLayoutConstraint.activate([
            emptyCircle.widthAnchor.constraint(equalTo: button.widthAnchor),
            emptyCircle.heightAnchor.constraint(equalTo: emptyCircle.widthAnchor),
            emptyCircle.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            emptyCircle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            viewModel.recordButtonLayoutConstraint,
            fillCircle.heightAnchor.constraint(equalTo: fillCircle.widthAnchor),
            fillCircle.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            fillCircle.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            
            button.heightAnchor.constraint(equalTo: button.widthAnchor),
        ])
        
        return button
    }()
    
    // MARK: - Methods
    private func setupNavigationController() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        
        let barButtonItem = UIBarButtonItem(image: UIImage(systemName: "xmark",
                                                           withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium)),
                                            style: .done,
                                            target: self,
                                            action: #selector(touchCloseButton(_:)))
        barButtonItem.tintColor = .white
        navigationItem.leftBarButtonItem = barButtonItem
        navigationItem.titleView = distanceLabel
        navigationController?.navigationBar.scrollEdgeAppearance = nil
    }
    
    private func setupARScene() {
        sceneView.delegate = viewModel
        sceneView.session.delegate = viewModel
        sceneView.automaticallyUpdatesLighting = true
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sceneView)
        NSLayoutConstraint.activate([
            sceneView.topAnchor.constraint(equalTo: view.topAnchor),
            sceneView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            sceneView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sceneView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
        viewModel.arCapture = ARCapture(view: sceneView)
    }
    
    private func setupLayoutConstraint() {
        view.addSubview(cameraFrameView)
        view.addSubview(guideLabel)
        view.addSubview(recordButton)
        cameraFrameView.subviews[1].addSubview(guideFrameImageView)
        cameraFrameView.subviews[1].addSubview(handGuideFrameImageStackView)
        
        
        NSLayoutConstraint.activate([
            cameraFrameView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraFrameView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            cameraFrameView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraFrameView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraFrameView.subviews[0].bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            
            guideFrameImageView.centerXAnchor.constraint(equalTo: cameraFrameView.subviews[1].centerXAnchor),
            guideFrameImageView.centerYAnchor.constraint(equalTo: cameraFrameView.subviews[1].centerYAnchor),
            guideFrameImageView.widthAnchor.constraint(equalTo: cameraFrameView.subviews[1].widthAnchor),
            
            handGuideFrameImageStackView.centerXAnchor.constraint(equalTo: guideFrameImageView.centerXAnchor),
            handGuideFrameImageStackView.centerYAnchor.constraint(equalTo: guideFrameImageView.centerYAnchor),
            handGuideFrameImageStackView.heightAnchor.constraint(equalTo: guideFrameImageView.heightAnchor),
            handGuideFrameImageStackView.widthAnchor.constraint(equalTo: guideFrameImageView.widthAnchor),
            
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideLabel.topAnchor.constraint(equalTo: cameraFrameView.subviews[2].topAnchor, constant: 15),
            guideLabel.heightAnchor.constraint(equalTo: recordButton.heightAnchor),
            guideLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 15),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
        ])
    }
    
    private func configureBinding() {
        viewModel.arCapture?.didFinishRecordingTo = goToSelectPhotoViewController
        viewModel.updateDistanceUI = updateDistanceUI
        viewModel.updateGuideTextUI = updateGuideTextUI
    }
    
    private func updateGuideTextUI(text: String) {
        recordButtonIsEnabled(inEnabled: viewModel.testGuide == .testComplete)
        let opacity: Float = (viewModel.timerCount > 5 && viewModel.timerCount < 13) ? 1 : 0
        handGuideFrameImageStackView.subviews[selectedEye == .left ? 1 : 0].layer.opacity = opacity
        guideLabel.text = text
    }
    
    private func updateDistanceUI(arCaputreStatus: ARCapture.Status, distance: Int) {
        var viewStatus: TestGuide = .incorrectDistance
        if distance < 12 {
            distanceLabel.text = TestGuide.getAway.labelText
        } else if distance > 14 {
            distanceLabel.text = TestGuide.getCloser.labelText
        } else {
            viewStatus = .isReady
            distanceLabel.text = TestGuide.keepDistance.labelText
        }
        guideFrameImageView.tintColor = viewModel.guideFrameColor
        if arCaputreStatus == .ready {
            if self.viewStatus != viewStatus {
                self.viewStatus = viewStatus
                viewModel.playVoiceGuide(text: viewStatus.voiceText)
                guideLabel.text = viewStatus.labelText
            }
            recordButtonIsEnabled(inEnabled: viewModel.isRecordingEnabled)
        }
    }
    
    private func recordButtonIsEnabled(inEnabled: Bool) {
        recordButton.isEnabled = inEnabled
        recordButton.subviews[1].alpha = inEnabled ? 1 : 0.5
    }
    
    private func goToSelectPhotoViewController(url: URL) {
        let selectPhotoViewController = SelectPhotoViewController(urlPath: url,
                                                                  degrees: viewModel.degrees,
                                                                  selectedEye: selectedEye)
        navigationController?.pushViewController(selectPhotoViewController, animated: true)
    }

    // MARK: - Objc-C Methods
    @objc private func touchCloseButton(_ sender: UIButton) {
        viewModel.stopVoiceGuide()
        viewModel.stopTracking(sceneView: sceneView)
        dismiss(animated: true)
    }
    
    @objc private func touchHelpButton(_ sender: UIButton) {
        guard let fileManager = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
              let contentsOfDirectory = try? FileManager.default.contentsOfDirectory(at: fileManager, includingPropertiesForKeys: nil) else {
            return
        }
        contentsOfDirectory.forEach { print($0) }
    }
    
    @objc private func touchRecordButton(_ sender: UIButton) {
        viewModel.runARCapture(session: sceneView.session)
    }
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupARScene()
        setupLayoutConstraint()
        configureBinding()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        viewModel.resetTracking(sceneView: sceneView)
        viewModel.initAVSpeechsynthesizer()
        viewModel.selectedEye = selectedEye
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.stopVoiceGuide()
        viewModel.stopTimer()
    }
}

struct CoverTestView: UIViewControllerRepresentable {
    var selectedEye: Eye
    
    typealias UIViewControllerType = UINavigationController
    
    func makeUIViewController(context: Context) -> UINavigationController {
        let navigationController = UINavigationController()
        let coverTestViewController = CoverTestViewController()
        coverTestViewController.selectedEye = selectedEye
        navigationController.navigationBar.tintColor = .clear
        navigationController.navigationBar.backgroundColor = .clear
        navigationController.view.backgroundColor = .clear
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(coverTestViewController, animated: true)
        return navigationController
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
        
    }
}
