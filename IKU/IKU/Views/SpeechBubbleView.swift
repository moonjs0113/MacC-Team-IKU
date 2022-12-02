//
//  SpeechBubbleView.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/29.
//

import SwiftUI

struct SpeechBubbleView: View {
    let text: String
    let color: Color
    
    var body: some View {
        Text(text)
            .padding(.vertical, 9)
            .padding(.horizontal, 11)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(color)
            )
            .overlay(
                SpeechBubbleTail()
                    .fill(color)
        )
    }
}

fileprivate struct SpeechBubbleTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.midX - rect.width * 1/30, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY + rect.height * 1/3))
        path.addLine(to: CGPoint(x: rect.midX + rect.width * 1/30, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}



struct SpeechBubbleView_Previews: PreviewProvider {
    static var previews: some View {
        SpeechBubbleView(text: "Recommand Frame", color: .ikuBackgroundBlue)
            .font(Font(UIFont.nexonGothicFont(ofSize: 13)))
    }
}
