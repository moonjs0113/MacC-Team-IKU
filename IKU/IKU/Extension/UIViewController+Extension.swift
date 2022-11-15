//
//  UIViewController+Extension.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/14.
//

import UIKit

extension UIViewController {
    func openSystemSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}
