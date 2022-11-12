//
//  SelectPhotoViewController.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/10.
//

import SwiftUI
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
    private var scrubberHostingController: UIHostingController<ScrubberView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViews()
        
        playPauseButton.addTarget(self, action: #selector(playPauseButtonTouched(_:)), for: .touchUpInside)
        
        guard let movieURL = Bundle.main.url(forResource: "video", withExtension: "m4v") else { return }
        let asset = AVURLAsset(url: movieURL)

        Task {
            try await loadPropertyValuesAsync(forAsset: asset)
            configureHostingViewController()
        }
    }
    
    private func configureNavigationBar() {
        let selectButton = UIBarButtonItem(title: "선택하기", style: .plain, target: self, action: #selector(selectButtonTouched(_:)))
        navigationItem.rightBarButtonItem = selectButton
    }
    
    private func configureHostingViewController(){
        let hostingController = UIHostingController(rootView: ScrubberView(player: player))
        scrubberHostingController = hostingController
        
        addChild(hostingController)
        view.addSubview(hostingController.view)
        hostingController.didMove(toParent: self)
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: playerView.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
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
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
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
    
    @objc private func selectButtonTouched(_ sender: UIButton?) {
        guard let movieURL = Bundle.main.url(forResource: "video", withExtension: "m4v") else { return }
        let time = player.currentTime()
        let asset = AVURLAsset(url: movieURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        generator.generateCGImageAsynchronously(for: time) { image, _, _ in
            DispatchQueue.main.async { [weak self] in
                let imageViewController = ImageViewController()
                self?.present(imageViewController, animated: true)
                imageViewController.imageView.image = UIImage(cgImage: image!)
            }
        }
    }
}

fileprivate class ImageViewController: UIViewController {
    let imageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.contentMode = .scaleAspectFit
        return uiImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
