//
//  UIView+Extension.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/14.
//

import UIKit
import Combine

extension UIView {
    func toCircle(anyCancellable: inout Set<AnyCancellable>) {
        self.publisher(for: \.bounds, options: [.new, .initial, .old, .prior])
            .receive(on: DispatchQueue.main)
            .map { return $0.width / 2 }
            .assign(to: \.layer.cornerRadius, on: self)
            .store(in: &anyCancellable)
    }
}
