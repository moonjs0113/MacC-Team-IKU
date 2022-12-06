//
//  SelectPhotoViewController.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/10.
//

import SwiftUI
import AVFoundation
import Combine

final class SelectPhotoViewController: UIViewController {
    // MARK: - Properties
    private let player = AVPlayer()
    private lazy var announcementLabel: UILabel = {
        let uiLabel = UILabel()
        uiLabel.font = .nexonGothicFont(ofSize: 17)
        uiLabel.textColor = .white
        uiLabel.textAlignment = .center
        uiLabel.text = capturedImage == nil ?
            "Uncovered Frame" : "Covered Frame"
        return uiLabel
    }()
    private let playerView: PlayerView = PlayerView()
    private let playPauseButtonHostingController: UIHostingController<PlayButton> = {
        let hostingController = UIHostingController(rootView: PlayButton())
        hostingController.view.backgroundColor = .clear
        hostingController.view.isUserInteractionEnabled = false
        return hostingController
    }()
    private let gradientHostingController: UIHostingController<GradientView> =
        UIHostingController(rootView: GradientView(colors: [Color(uiColor: #colorLiteral(red: 0.7215686275, green: 0.7137254902, blue: 0.7176470588, alpha: 1)), Color(uiColor: #colorLiteral(red: 0.968627451, green: 0.968627451, blue: 0.968627451, alpha: 1))]))
    private var scrubberHostingController: UIHostingController<ScrubberView>?
    private var capturedImage: UIImage? = nil
    private var urlPath: URL?
    private var degrees: [Double: Double] = [:]
    private var angle: (Double?, Double?) = (nil, nil)
    private var selectedTime: (Double?, Double?) = (nil, nil)
    private var selectedEye: Eye = .left
    private var recommandedUncoverFrameTime: Double = 0
    private var recommandedCoverFrameTime: Double = 0
    private var observers: [AnyCancellable] = []
    private var scrubberView: ScrubberView?

    // MARK: - Methods
    private func configureNavigationBar() {
        let barButtonTitle = self.capturedImage == nil ? "Next" : "Confirm"
        let selectButton = UIBarButtonItem(title: barButtonTitle, style: .plain, target: self, action: #selector(selectButtonTouched(_:)))
        selectButton.tintColor = .white
        navigationItem.rightBarButtonItem = selectButton
        navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    private func configureHostingViewController(){
        guard let scrubberView else { return }
        scrubberView.scrollDidTouched
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let view = self?.playPauseButtonHostingController.view else { return }
                UIView.transition(with: view, duration: 1) {
                    view.alpha = 0
                }
            }
            .store(in: &observers)
        let hostingController = UIHostingController(
            rootView: scrubberView
        )
        scrubberHostingController = hostingController
        hostingController.view.backgroundColor = .clear
        
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
        view.backgroundColor = #colorLiteral(red: 0.1688045561, green: 0.1888649762, blue: 0.1928240955, alpha: 1)
        
//        view.addSubview(announcementLabel)
//        announcementLabel.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            announcementLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
//            announcementLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
//        ])
        navigationItem.titleView = announcementLabel
        
        playerView.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(playPauseButtonTouched))
        )
        view.addSubview(playerView)
        playerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            playerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
//            playerView.topAnchor.constraint(equalTo: announcementLabel.bottomAnchor, constant: 16),
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
        
        addChild(gradientHostingController)
        view.addSubview(gradientHostingController.view)
        gradientHostingController.didMove(toParent: self)
        gradientHostingController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            gradientHostingController.view.topAnchor.constraint(equalTo: playerView.bottomAnchor),
            gradientHostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            gradientHostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            gradientHostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func loadPropertyValuesAsync(forAsset newAsset: AVURLAsset) async throws {
        let (isPlayable, hasProtectedContent) = try await newAsset.load(.isPlayable, .hasProtectedContent)
        if isPlayable && !hasProtectedContent {
            playerView.player = player
            playerView.player?.replaceCurrentItem(with: AVPlayerItem(asset: newAsset))
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
    
    // MARK: - Objc-C Methods
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
    
    @objc private func selectButtonTouched(_ sender: UIButton?) {
        guard let videoURL = urlPath else { return }
        let time = player.currentTime()
        let asset = AVURLAsset(url: videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        generator.generateCGImageAsynchronously(for: time) { image, _, _ in
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                let backItem = UIBarButtonItem()
                backItem.title = ""
                self.navigationItem.backBarButtonItem = backItem
                
                if let savedImage = self.capturedImage,
                   let cgImage = image {
                    self.player.pause()
                    guard let resultViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else {
                        return
                    }
                    
                    resultViewController.url = videoURL
                    resultViewController.eyeImages.leftImage = savedImage
                    resultViewController.eyeImages.rightImage = UIImage(cgImage: cgImage)
                    resultViewController.degrees = self.degrees
                    
                    self.selectedTime.1 = time.seconds.roundSecondPoint
                    self.angle.1 = self.degrees[time.seconds.roundSecondPoint]
                    resultViewController.angle = (self.angle.0 ?? 0.0, self.angle.1 ?? 0.0)
                    resultViewController.selectedTime = (self.selectedTime.0 ?? 0.0, self.selectedTime.1 ?? 0.0)
                    resultViewController.numberEye = self.selectedEye
                    
                    backItem.tintColor = .black
                    self.navigationController?.pushViewController(resultViewController, animated: true)
                } else if let cgImage = image {
                    self.player.pause()
                    
                    let nextViewController = SelectPhotoViewController(
                        urlPath: self.urlPath,
                        degrees: self.degrees,
                        selectedEye: self.selectedEye,
                        capturedImage: UIImage(cgImage: cgImage),
                        recommandedUncoverFrameTime: self.recommandedUncoverFrameTime,
                        recommandedCoverFrameTime: self.recommandedCoverFrameTime
                    )
                    self.selectedTime.0 = time.seconds.roundSecondPoint
                    self.angle.0 = self.degrees[time.seconds.roundSecondPoint]
                    nextViewController.angle = self.angle
                    nextViewController.selectedTime = self.selectedTime
                    
                    backItem.tintColor = .white
                    self.navigationController?.pushViewController(nextViewController, animated: true)
                }
            }
        }
    }
    
    // MARK: - Life Cycles
    convenience init(urlPath: URL?, degrees: [Double: Double], selectedEye: Eye, capturedImage: UIImage? = nil, recommandedUncoverFrameTime: Double, recommandedCoverFrameTime: Double) {
        self.init()
        self.urlPath = urlPath
        self.degrees = degrees
        self.selectedEye = selectedEye
        self.capturedImage = capturedImage
        self.recommandedUncoverFrameTime = recommandedUncoverFrameTime
        self.recommandedCoverFrameTime = recommandedCoverFrameTime
        self.scrubberView = ScrubberView(
            player: player,
            highlightTime: capturedImage == nil ? recommandedUncoverFrameTime : recommandedCoverFrameTime
        )
    }
    
    convenience init(urlPath: URL?, degrees: [Double: Double]) {
        self.init()
        self.urlPath = urlPath
        self.degrees = degrees
        self.scrubberView = ScrubberView(
            player: player,
            highlightTime: 0,
            isShowRecommend: false
        )
        self.announcementLabel.isHidden = true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureViews()
        guard let urlPath else { return }
        let asset = AVURLAsset(url: urlPath)

        Task {
            try await loadPropertyValuesAsync(forAsset: asset)
            configureHostingViewController()
        }
    }
}

fileprivate class ImageViewController: UIViewController {
    let leftImageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.contentMode = .scaleAspectFit
        return uiImageView
    }()
    let rightImageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.contentMode = .scaleAspectFit
        return uiImageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    private func configureView() {
        leftImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(leftImageView)
        NSLayoutConstraint.activate([
            leftImageView.topAnchor.constraint(equalTo: view.topAnchor),
            leftImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            leftImageView.trailingAnchor.constraint(equalTo: view.centerXAnchor),
            leftImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        rightImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(rightImageView)
        NSLayoutConstraint.activate([
            rightImageView.topAnchor.constraint(equalTo: view.topAnchor),
            rightImageView.leadingAnchor.constraint(equalTo: view.centerXAnchor),
            rightImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            rightImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
