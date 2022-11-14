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
    private let playPauseButton: UIButton = {
        let button = UIButton()
        button.setImage(.init(systemName: "play.circle"), for: .normal)
        button.contentHorizontalAlignment = .fill
        button.contentVerticalAlignment = .fill
        button.isEnabled = true
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTouched(_:)), for: .touchUpInside)
        
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
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(playerView)
        view.addSubview(playPauseButton)
        
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            playerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])

        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            playPauseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func loadPropertyValuesAsync(forAsset newAsset: AVURLAsset) async throws {
        let (isPlayable, hasProtectedContent) = try await newAsset.load(.isPlayable, .hasProtectedContent)
        if isPlayable && !hasProtectedContent {
            playerView.player = player
            playerView.player?.replaceCurrentItem(with: AVPlayerItem(asset: newAsset))
        }
    }
    
    @objc private func playPauseButtonTouched(_ sender: UIButton?) {
        switch player.timeControlStatus {
        case .paused:
            let currentItem = player.currentItem
            if currentItem?.currentTime() == currentItem?.duration {
                currentItem?.seek(to: .zero, completionHandler: { _ in })
            }
            player.play()
        default:
            player.pause()
        }
    }
}
