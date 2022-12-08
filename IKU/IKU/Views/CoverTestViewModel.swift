//
//  CoverTestViewModel.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/17.
//

import UIKit
import AVFoundation
import ARKit
import SceneKit
import Combine

class CoverTestViewModel: NSObject {
    // MARK: - Properties
    //AR
    var arCapture: ARCapture?
    private var transformVisualization: ARSceneManager = ARSceneManager()
    private var faceAnchors: [ARFaceAnchor: ARSCNViewDelegate] = [:]
    var degrees: [Double: Double] {
        transformVisualization.horizontalDegrees
    }
    
    var guideFrameColor: UIColor {
        isRecordingEnabled ? .ikuCameraYellow : .white
    }
    
    // Recording
    var isRecordingEnabled: Bool {
        (12...14).contains(distance)
    }
    
    var recordButtonLayoutConstraint: NSLayoutConstraint = .init()
    var recordStatus: ARCapture.Status = .ready
    private var distance: Int = 0 {
        didSet {
            guard let updateDistanceUI else { return }
            DispatchQueue.main.async { updateDistanceUI(self.recordStatus, self.distance) }
        }
    }
    
    private var avSpeechSynthesizer: AVSpeechSynthesizer? = AVSpeechSynthesizer()
    var selectedEye: Eye = .left
    var testGuide: TestGuide = .isReady
    var timerCount: Double = 0
    var captureTime: Double = 0.0
    private var recordTimer: Timer?
    private var degreeTimer: Timer?
    
    var updateDistanceUI: ((ARCapture.Status, Int) -> Void)?
    var updateGuideTextUI: ((String) -> Void)?
    var anyCancellable = Set<AnyCancellable>()
    
    // MARK: - Methods
    // AR
    func resetTracking(sceneView: ARSCNView) {
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.videoHDRAllowed = true
        configuration.maximumNumberOfTrackedFaces = ARFaceTrackingConfiguration.supportedNumberOfTrackedFaces
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func stopTracking(sceneView: ARSCNView) {
        sceneView.session.pause()
    }
    
    private func calculateDistance(start: SCNVector3, end: SCNVector3) {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z

        distance = Int(round((sqrt(pow(dx, 2) + pow(dy, 2) + pow(dz, 2))) * 100) / 2.54)
    }
    
    // Recording
    func runARCapture(session: ARSession) {
        arCapture?.run { [weak self] recordStatus in
            guard let self = self,
                  let view = self.recordButtonLayoutConstraint.firstItem as? UIView else {
                return
            }
            self.recordStatus = recordStatus
            if recordStatus == .recording {
                self.toggleTimer(session: session)
                self.playVoiceGuide(text: TestGuide.uncover.voiceText)
                guard let updateGuideTextUI = self.updateGuideTextUI else { return }
                DispatchQueue.main.async { updateGuideTextUI(TestGuide.uncover.voiceText) }
            }
            UIView.animate(withDuration: 0.3) {
                self.recordButtonLayoutConstraint.constant = (recordStatus == .recording) ? -45 : -10
                if recordStatus == .recording {
                    self.anyCancellable.removeAll()
                    view.layer.cornerRadius = 5
                } else {
                    view.bindLayout(anyCancellable: &self.anyCancellable)
                }
                view.setNeedsLayout()
                view.layoutIfNeeded()
            }
        }
    }
    
    // Guide
    func initAVSpeechsynthesizer() {
        avSpeechSynthesizer = AVSpeechSynthesizer()
    }
    
    func playVoiceGuide(text: String) {
        avSpeechSynthesizer?.stopSpeaking(at: .immediate)
        let avSpeechUtterance = AVSpeechUtterance(string: text)
        avSpeechUtterance.voice = .init(language: "en-US")
        avSpeechUtterance.rate = 0.5
        avSpeechSynthesizer?.speak(avSpeechUtterance)
    }
    
    func startVoiceGuide() {
        timerCount += 1
        timerCount = timerCount.roundSecondPoint
        var guideText: TestGuide = .isReady
        var voiceText = ""
        switch self.timerCount {
        case 2...4:
            guideText = .countTime(5 - Int(timerCount))
            voiceText = "\(5 - Int(timerCount))"
        case 5, 12: // 4.5, 11.5
            guideText = .countTime(5)
            voiceText = "Complete"
        case 6:
            guideText = .coverTo(selectedEye)
            voiceText = guideText.voiceText
        case 9...11:
            guideText = .countTime(12 - Int(timerCount))
            voiceText = "\(12 - Int(timerCount))"
        case 13...:
            guideText = .testComplete
            voiceText = guideText.voiceText
        default:
            voiceText = ""
        }
        if !voiceText.isEmpty {
            self.testGuide = guideText
            playVoiceGuide(text: voiceText)
            guard let updateGuideTextUI else { return }
            DispatchQueue.main.async { updateGuideTextUI(guideText.voiceText) }
        }
    }
    
    func stopVoiceGuide() {
        avSpeechSynthesizer?.stopSpeaking(at: .immediate)
        avSpeechSynthesizer = nil
    }
    
    // Timer
    private func toggleTimer(session: ARSession){
        if recordStatus == .recording {
            startTimer()
        } else {
            stopTimer()
            stopVoiceGuide()
            session.pause()
        }
    }
    
    private func startTimer() {
        recordTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] timer in
            self?.startVoiceGuide()
        }
        
        degreeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            self?.transformVisualization.captureDegree(time: self?.captureTime ?? 0.0)
            self?.captureTime += 0.1
        }
    }
    
    func stopTimer() {
        recordTimer?.invalidate()
        recordTimer = nil
        degreeTimer?.invalidate()
        degreeTimer = nil
        timerCount = 0
    }
    
    // MARK: - Life Cycles
    override init() {
        super.init()
        initAVSpeechsynthesizer()
    }
}

// MARK: - Delegates And DataSources
extension CoverTestViewModel: ARSessionDelegate, ARSCNViewDelegate {
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
        // TODO: - SceneView 객체가 거리 계산에 직접 필요한지 확인 필요
        let start = renderer.pointOfView?.worldPosition
        
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
}
