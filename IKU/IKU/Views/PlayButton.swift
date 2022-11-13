//
//  PlayButton.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/13.
//

import SwiftUI

struct PlayButton: View {
    enum ButtonShape {
        case play
        case pause
    }
    
    var shape: ButtonShape = .play
    
    var body: some View {
        GeometryReader { geometry in
            let diameter = min(geometry.size.width, geometry.size.height)
            VStack {
                ZStack {
                    Circle()
                        .stroke(lineWidth: diameter/20)
                        .foregroundColor(.white)
                        .position(x: geometry.size.width/2, y: geometry.size.height/2)
                    
                    switch shape {
                    case .play:
                        Image(systemName: "play.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.blue)
                            .frame(width: diameter * 0.438, height: diameter * 0.438)
                            .position(x: geometry.size.width/2, y: geometry.size.height/2)
                    case .pause:
                        Image(systemName: "pause.fill")
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(.gray)
                            .frame(width: diameter * 0.438, height: diameter * 0.438)
                            .position(x: geometry.size.width/2, y: geometry.size.height/2)
                    }
                }
            }
        }
    }
}


