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
    private let playPauseButtonHostingController: UIHostingController<PlayButton> = {
        let hostingController = UIHostingController(rootView: PlayButton())
        hostingController.view.backgroundColor = .clear
        hostingController.view.isUserInteractionEnabled = false
        return hostingController
    }()
    private var scrubberHostingController: UIHostingController<ScrubberView>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViews()
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
        
        playerView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(playPauseButtonTouched))
        )
        
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.topAnchor),
            playerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            playerView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        addChild(playPauseButtonHostingController)
        view.addSubview(playPauseButtonHostingController.view)
        playPauseButtonHostingController.didMove(toParent: self)
        playPauseButtonHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            playPauseButtonHostingController.view.centerXAnchor.constraint(equalTo: playerView.centerXAnchor),
            playPauseButtonHostingController.view.centerYAnchor.constraint(equalTo: playerView.centerYAnchor),
            playPauseButtonHostingController.view.widthAnchor.constraint(equalToConstant: 73),
            playPauseButtonHostingController.view.heightAnchor.constraint(equalToConstant: 73)
        ])
    }
    
    private func loadPropertyValuesAsync(forAsset newAsset: AVURLAsset) async throws {
        let (isPlayable, hasProtectedContent) = try await newAsset.load(.isPlayable, .hasProtectedContent)
        if isPlayable && !hasProtectedContent {
            playerView.player = player
            playerView.player?.replaceCurrentItem(with: AVPlayerItem(asset: newAsset))
        }
    }
    
    @objc private func playPauseButtonTouched() {
        switch player.timeControlStatus {
        case .paused:
            let currentItem = player.currentItem
            if currentItem?.currentTime() == currentItem?.duration {
                currentItem?.seek(to: .zero, completionHandler: { _ in })
            }
            player.play()
            playPauseButtonHostingController.rootView.shape = .play
            popAndDisapperAnimation(of: playPauseButtonHostingController.view)
        default:
            player.pause()
            playPauseButtonHostingController.rootView.shape = .pause
            popAndDisapperAnimation(of: playPauseButtonHostingController.view)
        }
    }
        
    private func popAndDisapperAnimation(of view: UIView) {
        view.alpha = 1
        view.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
        UIViewPropertyAnimator.runningPropertyAnimator(
            withDuration: 0.2,
            delay: 0,
            options: .curveEaseInOut) {
                view.transform = CGAffineTransform.identity
            } completion: { _ in
                UIView.transition(with: view, duration: 1) {
                    view.alpha = 0
                }
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
