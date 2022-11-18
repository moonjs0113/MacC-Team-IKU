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
    private var viewModel: CoverTestViewModel = CoverTestViewModel()
    
    // UI Properties
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
        label.text = "거리: 0cm"
        label.textColor = .white
        label.font = .nexonGothicFont(ofSize: 13, weight: .bold)
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
        label.text = "카메라와 적정거리(30-35cm)인지 확인해주세요."
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
        viewModel.bindLayout(view: emptyCircle)
        
        let fillCircle = UIView()
        fillCircle.isUserInteractionEnabled = false
        fillCircle.translatesAutoresizingMaskIntoConstraints = false
        fillCircle.backgroundColor = .red
        viewModel.bindLayout(view: fillCircle)
        
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
        view.addSubview(distanceLabel)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.topAnchor),
            closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            closeButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -7),
            
            helpButton.topAnchor.constraint(equalTo: view.topAnchor),
            helpButton.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            helpButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -7),
            
            distanceLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            distanceLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
        
        return view
    }()
    
    // MARK: - Methods
    private func setupNavigationController() {
        navigationItem.backButtonTitle = ""
    }
    
    private func setupARScene() {
        let sceneView = viewModel.sceneView
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
        view.addSubview(headerView)
        view.addSubview(guideLabel)
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
            
            guideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            guideLabel.topAnchor.constraint(equalTo: cameraFrameView.subviews[2].topAnchor, constant: 15),
            guideLabel.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.95),
            
            recordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            recordButton.topAnchor.constraint(equalTo: guideLabel.bottomAnchor, constant: 15),
            recordButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            recordButton.widthAnchor.constraint(equalToConstant: 70),
        ])
    }
    
    private func configureBinding() {
        viewModel.arCapture?.didFinishRecordingTo = goToSelectPhotoViewController
        viewModel.updateUI = updateUI
    }
    
    private func updateUI(status: ARCapture.Status) {
        distanceLabel.attributedText = viewModel.distanceText
        let isCompleteRecording = viewModel.timerCount >= 1 //12
        if status == .ready {
            guideLabel.text = viewModel.isRecordingEnabled ? "녹화버튼을 눌러주세요." : "카메라와 적정거리(30-35cm)인지 확인해주세요."
//            recordButtonIsEnabled(inEnabled: viewModel.isRecordingEnabled)
        } else {
            if isCompleteRecording {
                guideLabel.text = "검사가 완료되었으니 종료버튼을 눌러주세요."
            } else {
                guideLabel.text = (viewModel.timerCount / 3) % 2 == 0 ? "오른쪽 눈을 손바닥으로 가려주세요 3초" : "손바닥을 떼주세요 3초"
            }
        }
        recordButtonIsEnabled(inEnabled: status == .ready ? viewModel.isRecordingEnabled : isCompleteRecording)
    }
    
    private func recordButtonIsEnabled(inEnabled: Bool) {
        recordButton.isEnabled = inEnabled
        recordButton.subviews[1].alpha = inEnabled ? 1 : 0.5
    }
    
    private func goToSelectPhotoViewController(url: URL) {
        let selectPhotoViewController = SelectPhotoViewController()
        selectPhotoViewController.prepareValue(url: url, degrees: viewModel.degrees)
        navigationController?.pushViewController(selectPhotoViewController, animated: true)
    }

    // MARK: - Objc-C Methods
    @objc private func touchCloseButton(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @objc private func touchHelpButton(_ sender: UIButton) {
//        playSound()
//        projectWill()
        guard let fileManager = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false),
              let contentsOfDirectory = try? FileManager.default.contentsOfDirectory(at: fileManager, includingPropertiesForKeys: nil) else {
            return
        }
        contentsOfDirectory.forEach { print($0) }
    }
    
    @objc private func touchRecordButton(_ sender: UIButton) {
        viewModel.runARCapture()
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
        viewModel.resetTracking()
    }
}
