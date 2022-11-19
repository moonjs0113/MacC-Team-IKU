//
//  ScrubberView.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/13.
//

import SwiftUI
import AVFoundation

struct ScrubberView: View {
    @StateObject private var viewModel: ScrubberViewModel
    
    init(player: AVPlayer, degrees: [Float]) {
        self._viewModel = StateObject(wrappedValue: ScrubberViewModel(player: player, degrees: degrees))
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                LazyHStack(spacing: 0) {
                    ForEach(self.viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                    }
                }
                .offset(
                    x: geometry.frame(in: .local).midX - viewModel.currentTime.seconds * viewModel.photoRatio * geometry.frame(in: .local).height,
                    y: geometry.frame(in: .local).minY
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
    let player: AVPlayer
    var timeObserverToken: Any?
    var photoRatio: Double = .zero
    var onTouchedTime: CMTime?
    var degrees: [Float]
    @Published var currentTime: CMTime = .zero
    @Published var images: [UIImage] = []
    
    init(player: AVPlayer, degrees: [Float]) {
        self.player = player
        self.degrees = degrees
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
    
    func dragEnd() {
        self.onTouchedTime = nil
    }
    
    private func addPeriodicTimeObserver() {
        let time = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserverToken = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            guard let self = self else { return }
            self.currentTime = self.player.currentTime()
            var time = Int(floor(self.currentTime.seconds * 10))
            if time >= self.degrees.count {
                time = self.degrees.count - 1
            }
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
                self?.photoRatio = Double(image.width) / Double(image.height)
                self?.images.append(UIImage(cgImage: image))
            }
        }
    }
}
