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
    
    
    var distanceText: NSMutableAttributedString {
        let string = "거리: \(distance)cm"
        let attributedStr = NSMutableAttributedString(string: string)
        attributedStr.addAttribute(.foregroundColor, value: isRecordingEnabled ? UIColor.ikuYellow : .ikuOrange , range: (string as NSString).range(of: "\(distance)cm"))
        return attributedStr
    }
    
    // Recording
    var isRecordingEnabled: Bool {
        (30 <= self.distance && 35 >= self.distance)
    }
    
    var recordButtonLayoutConstraint: NSLayoutConstraint = .init()
    var recordStatus: ARCapture.Status = .ready
    private var distance: Int = 0 {
        didSet {
            guard let updateUI else { return }
            DispatchQueue.main.async { updateUI(self.recordStatus) }
        }
    }
    
    private let avSpeechsynthesizer = AVSpeechSynthesizer()
    var timerCount = 0
    var captureTime: Double = 0.0
    private var recordTimer: Timer?
    private var degreeTimer: Timer?
    
    var updateUI: ((ARCapture.Status) -> Void)?
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
    
    private func calculateDistance(start: SCNVector3, end: SCNVector3) {
        let dx = end.x - start.x
        let dy = end.y - start.y
        let dz = end.z - start.z

        distance = Int(round((sqrt(pow(dx, 2) + pow(dy, 2) + pow(dz, 2))) * 100))
    }
    
    // Recording
    func runARCapture() {
        arCapture?.run { [weak self] recordStatus in
            guard let self = self,
                  let view = self.recordButtonLayoutConstraint.firstItem as? UIView else {
                return
            }
            self.recordStatus = recordStatus
            self.toggleTimer()
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
    func projectWill() {
        let string = "오른쪽 눈을 손바닥으로 가려주세요"
        let avSpeechUtterance = AVSpeechUtterance(string: string)
        // TODO: - lang enum 만들기
        avSpeechUtterance.voice = .init(language: "ko-KR")
        avSpeechUtterance.rate = 0.4
        avSpeechsynthesizer.speak(avSpeechUtterance)
    }
    
    // Timer
    private func toggleTimer(){
        if recordStatus == .recording {
            startTimer()
        } else {
            stopTimer()
        }
    }
    
    private func startTimer() {
        recordTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.timerCount += 1
        }
        
        degreeTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] timer in
            self?.transformVisualization.captureDegree(time: self?.captureTime ?? 0.0)
            self?.captureTime += 0.1
        }
    }
    
    private func stopTimer() {
        recordTimer?.invalidate()
        recordTimer = nil
        degreeTimer?.invalidate()
        degreeTimer = nil
        if timerCount >= 12 {
            // 잘 찍은거
        } else {
            // 중간에 끊은거
        }
        timerCount = 0
    }
    
    // MARK: - Life Cycles
    override init() {
        super.init()
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
