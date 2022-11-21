//
//  UIView+Extension.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/18.
//

import UIKit
import Combine

extension UIView {
    func bindLayout(anyCancellable: inout Set<AnyCancellable>) {
        clipsToBounds = true
        self.publisher(for: \.bounds, options: [.new, .initial, .old, .prior])
            .receive(on: DispatchQueue.main)
            .filter { trunc($0.width) == trunc($0.height) }
            .map { $0.width / 2 }
            .assign(to: \.layer.cornerRadius, on: self)
            .store(in: &anyCancellable)
    }
}
