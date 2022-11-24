//
//  StoryView.swift
//  IKU
//
//  Created by KimJS on 2022/11/15.
//

import SwiftUI
import AVFoundation

// MARK: - Extensions
extension Color {
    static let ikuBlue: Color = Color("ikuBlue")
    static let ikuBackgroundBlue: Color = Color( "ikuBackgroundBlue")
    static let ikuEyeSelectBackgroundBlue: Color = Color("ikuEyeSelectBackgroundBlue")
}

struct StoryView: View {
    
    // MARK: - Properties
    @State private var selectedEye: Eye = .left
    let customBlue = Color.ikuBlue
    @State private var showAlert: Bool = false
    @State private var showCoverTestView: Bool = false
    
    private func goToAppSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    var body: some View {
        ZStack {
            Color.ikuBackgroundBlue
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
                
                SelectWhichEyeView(selectedEye: $selectedEye)
                
                // 눈이 제대로 선택되었는지 확인하는 디버깅 용도의 코드입니다. 임의로 삭제 가능합니다.
                Text("선택된 눈 : \(selectedEye.rawValue)")
                    .padding()
                
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
                    AVCaptureDevice.requestAccess(for: .video) { permission in
                        
                        
                        if permission {
                            showCoverTestView = true //self.goToCoverTestView()
                        } else {
                            showAlert = true
                            //                                self.showAlertPermissionSetting(title: "Require Camera Permission",
                            //                                                                message: "사시각 측정을 위해 카메라 권한이 필요합니다.\n설정으로 이동하시겠습니까?")
                        }
                        
                    }
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
        .fullScreenCover(isPresented: $showCoverTestView) {
            CoverTestView(selectedEye: selectedEye)
                .ignoresSafeArea()
        }
        .alert("Require Camera Permission", isPresented: $showAlert) {
            Button("확인") {
                goToAppSetting()
            }
            Button("취소", role: .cancel) { }
        } message: {
            Text("사시각 측정을 위해 카메라 권한이 필요합니다.\n설정으로 이동하시겠습니까?")
        }
    }
}

struct StoryView_Previews: PreviewProvider {
    static var previews: some View {
        StoryView()
    }
}
