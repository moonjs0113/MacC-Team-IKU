//
//  StoryView.swift
//  IKU
//
//  Created by KimJS on 2022/11/15.
//
import SwiftUI
import AVFoundation

struct StoryView: View, StoryViewDelegate {
    @State private var selectedEye: Eye = .right
    @State private var showAlert: Bool = false
    @State private var showCoverTestView: Bool = false
    @State private var nickName: String = "EyeKu"
    @State private var showFailAlert: Bool = false
    @State private var imageURL: URL?
    @State private var isShowingPopover = false
    
    init() {
        let appearence = UINavigationBarAppearance()
        appearence.shadowColor = .black
        appearence.backgroundColor = .ikuBackgroundBlue
        UINavigationBar.appearance().scrollEdgeAppearance = appearence
    }
    
    var body: some View {
        ZStack {
            Color.ikuBackgroundBlue
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Text("Select eye to test")
                    .bold()
                    .font(Font(UIFont.nexonGothicFont(ofSize: 20, weight: .bold)))
                    .foregroundColor(.black)
                    .padding(32)
                
                EyeSelectingView($selectedEye)
                    .padding()
                
                VStack {
                    Text("Click What is “Cover Test?” before starting test. If you understand “Cover Test”, push the “Test Start!” button")
                        .multilineTextAlignment(.leading)
                        .padding()
                    Button {
                        isShowingPopover = true
                    } label: {
                        Text(#"What is "Cover Test"?"#)
                            .underline()
                            .foregroundColor(.ikuBlue)
                    }
                    .padding(.bottom, 32)
                    .fullScreenCover(isPresented: $isShowingPopover, content: {
                        WhatIsCoverTestView()
                            .modalColor(.init(white: 0, alpha: 0.2))
                    })
                }
                .background {
                    RoundedRectangle(cornerRadius: 5)
                        .foregroundColor(.white)
                }
                .padding()
                
                
                Spacer()
                
                Button {
                    scanButtonTouched()
                } label: {
                    HStack {
                        Spacer()
                        Text("Test Start!")
                            .foregroundColor(.white)
                            .font(Font(UIFont.nexonGothicFont(ofSize: 20, weight: .bold)))
                        Spacer()
                    }
                    .padding()
                }
                .background {
                    RoundedRectangle(cornerRadius: 10)
                        .foregroundColor(.ikuBlue)
                }
                .padding()
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
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Strabismus Test")
                    .font(Font(UIFont.nexonGothicFont(ofSize: 17, weight: .bold)))
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    ProfileView(storyViewDelegate: self)
                } label: {
                    HStack {
                        Text(nickName)
                            .font(Font(UIFont.nexonGothicFont(ofSize: 13, weight: .bold)))
                            .foregroundColor(.black)
                        Group {
                            if let imageURL = self.imageURL,
                               let imageData = try? Data(contentsOf: imageURL),
                               let uiImage = UIImage(data: imageData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFill()
                            } else {
                                Image("DefaultProfileImage")
                                    .resizable()
                                    .scaledToFill()
                            }
                        }
                        .frame(width: 25, height: 25)
                        .clipShape(Circle())
                    }
                }
            }
        }
        .onAppear {
            fetchUI()
        }
        .alert("Save failed", isPresented: $showFailAlert) {
            Button("확인") { }
        } message: {
            Text("Failed to save profile information.")
        }
    }
    
    private func goToAppSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func scanButtonTouched() {
        AVCaptureDevice.requestAccess(for: .video) { permission in
            if permission { showCoverTestView = true }
            else { showAlert = true }
        }
    }
    
    func fetchUI() {
        do {
            guard let localIdentifier = UserDefaults.standard.string(forKey: UserDefaultsKey.PROFILE_LOCALIDENTIFIER.rawValue) else {
                return
            }
            let persistenceManager = try PersistenceManager()
            let profileData = try persistenceManager.fetchProfile(withLocalIdentifier: localIdentifier)
            guard let data = profileData.first else { return }
            let savePath = try FileManager.default.url(
                for: .documentDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            self.imageURL = savePath.appendingPathComponent("\(localIdentifier).png")
            self.nickName = data.nickname
        } catch {
            showFailAlert.toggle()
        }
    }
}

protocol StoryViewDelegate {
    func fetchUI()
}

fileprivate struct EyeSelectingView: View {
    @Binding private var selectedEye: Eye
    
    init(_ selectedEye: Binding<Eye>) {
        self._selectedEye = selectedEye
    }
    
    var body: some View {
        Group {
            switch selectedEye {
            case .left:
                Image("LeftEyeSelectedImage")
                    .resizable()
                    .scaledToFit()
            case .right:
                Image("RightEyeSelectedImage")
                    .resizable()
                    .scaledToFit()
            }
        }
        .overlay{
            GeometryReader { geometry in
                ZStack {
                    Rectangle()
                        .opacity(0.47)
                        .foregroundColor(.ikuEyeSelectBackgroundBlue)
                        .mask {
                            Mask(direction: selectedEye, in: CGRect(
                                origin: .zero,
                                size: CGSize(
                                    width: geometry.size.width,
                                    height: geometry.size.height))
                            )
                        }
                        .onTapGesture {
                            switch selectedEye {
                            case .left: selectedEye = .right
                            case .right: selectedEye = .left
                            }
                        }
                    VStack {
                        Spacer()
                        HStack{
                            Spacer()
                            Text("Left Eye")
                            Spacer()
                            Spacer()
                            Text("Right Eye")
                            Spacer()
                        }
                        .font(Font(UIFont.nexonGothicFont(ofSize: 17, weight: .bold)))
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .clipShape(
            RoundedRectangle(cornerRadius: 10)
        )
    }
    
    private func Mask(direction eye: Eye, in rect: CGRect) -> some View {
        var shape = Rectangle().path(in: rect)
        shape.addPath(RoundedRectangle(cornerRadius: 10)
            .path(in:CGRect(
                origin: CGPoint(x: eye == .left ? 4 : rect.midX + 4, y: 4),
                size: CGSize(width: rect.width/2 - 8, height: rect.height - 8))
            )
        )
        return shape.fill(style: FillStyle(eoFill: true))
    }
}

fileprivate struct ModalColorView: UIViewRepresentable {
    
    let color: UIColor
    
    func makeUIView(context: Context) -> some UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = color
        }
        return view
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {}
}

fileprivate struct ModalColorViewModifier: ViewModifier {
    
    let color: UIColor
    
    func body(content: Content) -> some View {
        content
            .background(ModalColorView(color: color))
    }
}

extension View {
    func modalColor(_ color: UIColor = .clear) -> some View {
        self.modifier(ModalColorViewModifier(color: color))
    }
}
