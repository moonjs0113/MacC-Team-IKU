//
//  GIFImageView.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/30.
//

import SwiftUI

struct GIFImageView: UIViewRepresentable {
    private let data: Data?
    private let name: String?
    
    init(data: Data) {
        self.data = data
        self.name = nil
    }
    
    public init(name: String) {
        self.data = nil
        self.name = name
    }
    
    func makeUIView(context: Context) -> UIGIFImage {
        if let data = data {
            return UIGIFImage(data: data)
        } else {
            return UIGIFImage(name: name ?? "")
        }
    }
    
    func updateUIView(_ uiView: UIGIFImage, context: Context) {
        if let data = data {
            uiView.updateGIF(data: data)
        } else {
            uiView.updateGIF(name: name ?? "")
        }
    }
}

class UIGIFImage: UIView {
    private let imageView = UIImageView()
    private var data: Data?
    private var name: String?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(name: String) {
        self.init()
        self.name = name
        initView()
    }
    
    convenience init(data: Data) {
        self.init()
        self.data = data
        initView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = bounds
        self.addSubview(imageView)
    }
    
    func updateGIF(data: Data) {
        imageView.image = UIImage.gifImage(data: data)
    }
    
    func updateGIF(name: String) {
        imageView.image = UIImage.gifImage(name: name)
    }
    
    private func initView() {
        imageView.contentMode = .scaleAspectFit
    }
}
