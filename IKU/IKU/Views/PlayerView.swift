//
//  PlayerView.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/10.
//

import UIKit
import AVFoundation

final class PlayerView: UIView {
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    var player: AVPlayer? {
        get { playerLayer.player }
        set { playerLayer.player = newValue }
    }
    
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}

