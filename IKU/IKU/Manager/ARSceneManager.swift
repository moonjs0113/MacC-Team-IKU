//
//  ARSceneManager.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/15.
//

import ARKit
import SceneKit

class ARSceneManager: NSObject, ARSCNViewDelegate {
    var contentNode: SCNNode?
    
    lazy var rightEyeNode = SCNReferenceNode(named: "coordinateOrigin")
    lazy var leftEyeNode = SCNReferenceNode(named: "coordinateOrigin")
    
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard anchor is ARFaceAnchor else { return nil }
        contentNode = SCNReferenceNode()
        addEyeTransformNodes()
        return contentNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        
        rightEyeNode.simdTransform = faceAnchor.rightEyeTransform
        leftEyeNode.simdTransform = faceAnchor.leftEyeTransform
    }
    
    func addEyeTransformNodes() {
        guard let anchorNode = contentNode else { return }
        
        rightEyeNode.simdPivot = float4x4(diagonal: [5, 5, 1, 1]) // [R,G,B,1]
        leftEyeNode.simdPivot = float4x4(diagonal: [5, 5, 1, 1])
        
        anchorNode.addChildNode(rightEyeNode)
        anchorNode.addChildNode(leftEyeNode)
    }
}

// MARK: - Helper
extension SCNReferenceNode {
    convenience init(named resourceName: String, loadImmediately: Bool = true) {
        let url = Bundle.main.url(forResource: resourceName, withExtension: "scn", subdirectory: "Models.scnassets")!
        self.init(url: url)!
        if loadImmediately {
            self.load()
        }
    }
}
