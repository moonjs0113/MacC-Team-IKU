//
//  CareGuideView.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/12/01.
//

import SwiftUI

struct CareGuideView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var currentTabItem: Int = 0
    
    init() {
        UIPageControl.appearance().currentPageIndicatorTintColor = .ikuWhatBlue
        UIPageControl.appearance().pageIndicatorTintColor = .ikuCalendarWeeklyTitle
    }
    
    var body: some View {
        ZStack {
            Color.clear.ignoresSafeArea(.all)
                .contentShape(Rectangle())
                .onTapGesture {
                    dismiss()
                }
            
            GeometryReader { bottomLayerProxy in
                VStack {
                    Spacer()
                        ZStack {
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(Color.ikuBackgroundBlue)
                                .padding(.horizontal, 16)
                                .frame(height: bottomLayerProxy.size.height * 5/8 )
                                .overlay {
                                    VStack {
                                        Image(currentTabItem == 4 ? "GuideImage_1" : "GuideImage_0")
                                            .position(x: bottomLayerProxy.size.width / 2,
                                                      y: bottomLayerProxy.size.height / 6)
                                        TabView(selection: $currentTabItem) {
                                            ForEach(Array(GuideText.allCases.enumerated()), id :\.offset) { item in
                                                VStack {
                                                    Text(item.element.rawValue)
                                                        .font(Font(UIFont.nexonGothicFont(ofSize: 17)))
                                                        .multilineTextAlignment(.center)
                                                    Spacer()
                                                }
                                                .tag(item.offset)
                                            }
                                            
                                        }
                                        .frame(width: bottomLayerProxy.size.width * 0.8)
                                        .padding(.top, bottomLayerProxy.size.height * 0.0 )
                                        .tabViewStyle(.page(indexDisplayMode: .always))
                                    }
                                }
                        }
                    Spacer()
                }
            }
        }
        .onAppear {
            currentTabItem = 0
        }
    }
    
    static let controller: UIViewController = {
        UIHostingController(rootView: CareGuideView())
    }()
    
    enum GuideText: String, CaseIterable {
        case step1 = "The Strabismus test is a treatable disease. We will let you know what treatment you can get. Please do your child’s eyes healthy."
        case step2 = "Early treatment is very important. If treatment for strabismus is dalayed, complications may result. So, if you suspect your child has strabismus, Meet an expert and consult quickly. "
        case step3 = "Strabismums can be treated with a doctor, eye exercuses, and glasses. We hope that you will be treated according to your preferences."
        case step4 = "Bookmark the video and keep an eye on the angle of strabismus while treating strabismus."
        case step5 = "This service is a simple self-test. For accurate diagnosis, please visit the hospital and consult a doctor. The test results may depend on the imaging device or the surrounding environment. It is recommended that you be diagnosed by a trained professional. Do not use results from this app as part of a diagnosis or treatment plan."
    }
}

struct CareGuideView_Previews: PreviewProvider {
    static var previews: some View {
        CareGuideView()
        CareGuideView()
            .previewDevice(.init(rawValue: "iPhone SE (3rd generation)"))
    }
}
