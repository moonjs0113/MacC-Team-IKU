//
//  StoryView.swift
//  IKU
//
//  Created by KimJS on 2022/11/15.
//

import SwiftUI

// MARK: - Extensions
extension Color {
    static let ikuBlue: Color = Color("ikuBlue")
    static let ikuBackground: Color = Color( "ikuBackground")
    static let ikuEyeSelectBackground: Color = Color("ikuEyeSelectBackground")
}

struct StoryView: View {
    
    // MARK: - Properties
    @State var mode: Eyes = .left
    let customBlue = Color.ikuBlue
    
    var body: some View {
        ZStack {
            Color.ikuBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                HStack {
                    Image(systemName: "questionmark.circle")
                        .foregroundColor(customBlue)
                    
                    Spacer()
                    
                    // TODO: 앱 로고로 대체
                    Image(systemName: "hare")
                    Text("아이쿠")
                        .bold()
                        .foregroundColor(customBlue)
                        .font(Font(UIFont.nexonGothicFont(ofSize: 22, weight: .bold)))
                    Spacer()
                    
                    Text("응애1")
                        .foregroundColor(customBlue)
                        .font(Font(UIFont.nexonGothicFont(ofSize: 13, weight: .bold)))
                    // TODO: 프로필 로고로 대체
                    Image(systemName: "person.circle")
                }
                .padding()
                
                Spacer()
                
                Text("검사할 눈을 선택해주세요")
                    .bold()
                    .font(Font(UIFont.nexonGothicFont(ofSize: 20, weight: .bold)))
                    .foregroundColor(customBlue)
                    .padding(.bottom, 29)
                
                // TODO: 눈 선택 화면 만들기
                SelectWhichEyeView(mode: $mode)
                
                VStack(alignment: .leading, spacing: 0) {
                    Text("가림막 검사는? 오른쪽 눈 검사할 때는")
                        .bold()
                        .font(Font(UIFont.nexonGothicFont(ofSize: 17, weight: .bold)))
                        .foregroundColor(customBlue)
                        .padding(.bottom, 6)
                    Text("왼쪽 눈을 가려주세요")
                        .font(Font(UIFont.nexonGothicFont(ofSize: 15, weight: .regular)))
                }
                
                Spacer()
                
                Button {
                    // TODO: 검사하기 버튼을 누르면 검사하는 화면으로 이동
                } label: {
                    ZStack {
                        Rectangle()
                            .cornerRadius(10)
                            .foregroundColor(customBlue)
                            .frame(height:52, alignment: .center)
                            .shadow(radius: 4, x: 0, y: 4)
                            .padding()
                        
                        Text("검사하기")
                            .bold()
                            .font(Font(UIFont.nexonGothicFont(ofSize: 20, weight: .bold)))
                            .foregroundColor(.white)
                    }
                }
            }
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
    }
}
