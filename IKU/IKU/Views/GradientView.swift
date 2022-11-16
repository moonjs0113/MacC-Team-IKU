//
//  GradientView.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/14.
//

import SwiftUI

struct GradientView: View {
    var colors: [Color]
    
    var body: some View {
        Rectangle()
            .foregroundColor(.clear)
            .background(
                LinearGradient(
                    gradient: Gradient(
                        colors: colors
                    ),
                    startPoint: .top,
                    endPoint: .bottom
                ),
                ignoresSafeAreaEdges: .all
            )
    }
}

struct GradientView_Previews: PreviewProvider {
    static var previews: some View {
        GradientView(colors: [.blue, .red])
    }
}
