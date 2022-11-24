//
//  UIViewController+Extension.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/14.
//

import UIKit

extension UIViewController {
    private func openSystemSetting() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func showAlertPermissionSetting(title: String, message: String) {
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: "예", style: .default) { [weak self] _ in
            self?.openSystemSetting()
        }
        let cancel = UIAlertAction(title: "아니오", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    func showAlertController(
        title: String,
        message: String,
        style: UIAlertController.Style = .alert,
        isAddCancelAction: Bool = true,
        completeHandler: @escaping () -> Void
    ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        let ok = UIAlertAction(title: isAddCancelAction ? "예" : "확인" , style: .default) { _ in
            completeHandler()
            return
        }
        alert.addAction(ok)
        
        if isAddCancelAction {
            let cancel = UIAlertAction(title: "아니오", style: .cancel)
            alert.addAction(cancel)
        }
        
        present(alert, animated: true)
    }
    
    func addEndEditingGesture() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(endEditing(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    @objc private func endEditing(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
}
