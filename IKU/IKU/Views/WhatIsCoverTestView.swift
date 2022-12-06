//
//  WhatIsCoverTestView.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/30.
//

import SwiftUI

struct WhatIsCoverTestView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea(.all)
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                }
            
            TabView {
                Group {
                    GifView(imageName: "WhatIsCoverTest1")
                    ImageView(imageName: "WhatIsCoverTest2")
                    GifView(imageName: "WhatIsCoverTest3")
                    ImageView(imageName: "WhatIsCoverTest4")
                    ImageView(imageName: "WhatIsCoverTest5")
                }
                Group {
                    ImageView(imageName: "WhatIsCoverTest6")
                    ImageView(imageName: "WhatIsCoverTest7")
                    ImageView(imageName: "WhatIsCoverTest8")
                    ImageView(imageName: "WhatIsCoverTest9")
                    ImageView(imageName: "WhatIsCoverTest10")
                    ImageView(imageName: "WhatIsCoverTest11")
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onTapGesture { Void() }
            .padding(.vertical, 50)
        }
    }
    
    private struct GifView: View {
        @Environment(\.dismiss) private var dismiss
        
        let imageName: String
        var body: some View {
            GeometryReader { geometry in
                ZStack {
                    Color.clear.ignoresSafeArea(.all)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            dismiss()
                        }
                    
                    GIFImageView(name: imageName)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .scaledToFit()
                }
            }
            .padding(30)
        }
    }
    
    private struct ImageView: View {
        @Environment(\.dismiss) private var dismiss
        
        let imageName: String
        var body: some View {
            ZStack {
                Color.clear.ignoresSafeArea(.all)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        dismiss()
                    }
                
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                .padding(30)
            }
        }
    }
}
