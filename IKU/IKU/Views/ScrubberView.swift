//
//  ScrubberView.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/13.
//

import SwiftUI
import AVFoundation
import Combine

struct ScrubberView: View {
    @StateObject private var viewModel: ScrubberViewModel
    let scrollDidTouched = PassthroughSubject<Void, Never>()
    
    init(player: AVPlayer, highlightTime: Double) {
        self._viewModel = StateObject(wrappedValue: ScrubberViewModel(player: player, highlightTime: highlightTime))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                GeometryReader { innerGeomerty in
                    LazyHStack(spacing: 0) {
                        ForEach(self.viewModel.images, id: \.self) { image in
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                        }
                    }
                    .offset(
                        x: innerGeomerty.frame(in: .local).midX - viewModel.currentTime.seconds * viewModel.photoRatio * geometry.frame(in: .local).height,
                        y: geometry.frame(in: .local).minY
                    )
                }
                
                Rectangle()
                    .stroke(lineWidth: 2)
                    .contentShape(Rectangle())
                    .foregroundColor(.yellow)
                    .frame(
                        width: viewModel.photoRatio * geometry.frame(in: .local).height + 4,
                        height: geometry.frame(in: .local).height
                    )
                    .position(
                        x: geometry.frame(in: .local).midX + (viewModel.highlightTime - viewModel.currentTime.seconds) * viewModel.photoRatio * geometry.frame(in: .local).height,
                        y: geometry.frame(in: .local).midY
                    )
                    .onTapGesture {
                        viewModel.highlightTouched()
                    }
                
                SpeechBubbleView(text: "Recommended Frame", color: .ikuBackgroundBlue)
                    .font(Font(UIFont.nexonGothicFont(ofSize: 13)))
                    .position(
                        x: geometry.frame(in: .local).midX + (viewModel.highlightTime - viewModel.currentTime.seconds) * viewModel.photoRatio * geometry.frame(in: .local).height,
                        y: -44 * 1/2 + -44 * 1/3
                    )
                
                RoundedRectangle(cornerRadius: 2)
                    .stroke(lineWidth: 1.5)
                    .frame(width:4)
                    .background(.white)
                    .position(x: geometry.frame(in: .local).midX, y: geometry.frame(in: .local).midY)
            }
            .gesture(
                DragGesture(minimumDistance: 0, coordinateSpace: .local)
                    .onChanged { value in
                        viewModel.dragged(toX: value.translation.width, viewHeight: geometry.frame(in: .local).maxY)
                        scrollDidTouched.send()
                    }
                    .onEnded { _ in
                        viewModel.dragEnd()
                    }
            )
        }
        .frame(height: 44)
        .onAppear() {
            viewModel.onAppear()
        }
    }
}

final class ScrubberViewModel: ObservableObject {
    static let timeScale: CMTimeScale = CMTimeScale(NSEC_PER_SEC)
    let highlightTime: Double
    let player: AVPlayer
    var timeObserverToken: Any?
    var photoRatio: Double = .zero
    var onTouchedTime: CMTime?
    @Published var currentTime: CMTime
    @Published var images: [UIImage] = []
    
    init(player: AVPlayer, highlightTime: Double) {
        self.player = player
        self.highlightTime = highlightTime
        self.currentTime = CMTime(seconds: highlightTime, preferredTimescale: Self.timeScale)
        self.player.seek(to: self.currentTime)
        addPeriodicTimeObserver()
    }
    
    func onAppear() {
        Task {
            try await generateSnapshotImages()
        }
    }
    
    func dragged(toX: Double, viewHeight: Double) {
        player.pause()
        if let onTouchedTime {
            let computedTime = onTouchedTime - CMTime(seconds: toX / (viewHeight * photoRatio), preferredTimescale: Self.timeScale)
            
            if computedTime <= CMTime(seconds: 0, preferredTimescale: Self.timeScale) {
                currentTime = CMTime(seconds: 0, preferredTimescale: Self.timeScale)
            } else if let currentItem = player.currentItem,
                      computedTime >= currentItem.duration {
                currentTime = currentItem.duration
            } else {
                currentTime = computedTime
                player.seek(to: currentTime, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        } else {
            self.onTouchedTime = currentTime
        }
    }
    
    func highlightTouched() {
        withAnimation {
            currentTime = CMTime(seconds: highlightTime, preferredTimescale: Self.timeScale)
            player.seek(to: currentTime, toleranceBefore: .zero, toleranceAfter: .zero)
        }
    }
    
    func dragEnd() {
        self.onTouchedTime = nil
    }
    
    private func addPeriodicTimeObserver() {
        let time = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = self.player.currentTime()
        }
    }
    
    private func generateSnapshotImages() async throws {
        guard let currentItem = player.currentItem else { return }
        let generator = AVAssetImageGenerator(asset: currentItem.asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        let duration = try await currentItem.asset.load(.duration).seconds
        
        DispatchQueue.main.async { [weak self] in
            for time in 0..<Int(duration) {
                guard let image = try? generator.copyCGImage (
                    at: CMTime(seconds: Double(time), preferredTimescale: Self.timeScale),
                    actualTime: nil
                ) else {
                    return
                }
                if self?.photoRatio == .zero {
                    self?.photoRatio = Double(image.width) / Double(image.height)
                }
                self?.images.append(UIImage(cgImage: image))
            }
            let lastPhotoTime = Double(Int(duration))
            guard let image = try? generator.copyCGImage(
                at: CMTime(seconds: lastPhotoTime, preferredTimescale: Self.timeScale),
                actualTime: nil
            ) else {
                return
            }
            let cropRect = CGRect(
                x: 0,
                y: 0,
                width: Int(Double(image.width) * (duration - lastPhotoTime)),
                height: image.height
            )
            guard let croppedImage = image.cropping(to: cropRect) else { return }
            self?.images.append(UIImage(cgImage: croppedImage))
        }
    }
}
