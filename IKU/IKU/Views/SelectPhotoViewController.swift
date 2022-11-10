//
//  SelectPhotoViewController.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/10.
//

import UIKit
import AVFoundation

final class SelectPhotoViewController: UIViewController {
    private let player = AVPlayer()
    private let playerView: PlayerView = PlayerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        
        guard let movieURL = Bundle.main.url(forResource: "video", withExtension: "m4v") else { return }
        let asset = AVURLAsset(url: movieURL)

        Task {
            try await loadPropertyValuesAsync(forAsset: asset)
        }
    }
    
    private func configureViews() {
        view.backgroundColor = .red
        playerView.backgroundColor = .blue
        
        playerView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playerView)
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
    
    private func loadPropertyValuesAsync(forAsset newAsset: AVURLAsset) async throws {
        let (isPlayable, hasProtectedContent) = try await newAsset.load(.isPlayable, .hasProtectedContent)
        if isPlayable && !hasProtectedContent {
            playerView.player = player
            playerView.player?.replaceCurrentItem(with: AVPlayerItem(asset: newAsset))
        }
    }
}
