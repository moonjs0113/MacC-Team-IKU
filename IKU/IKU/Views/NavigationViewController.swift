//
//  NavigationViewController.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/11.
//

import UIKit

class NavigationViewController: UIViewController {
    private let button: UIButton = {
        let uibutton = UIButton()
        uibutton.setTitle("button", for: .normal)
        uibutton.isEnabled = true
        return uibutton
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        button.addTarget(self, action: #selector(buttonTouched(_:)), for: .touchUpInside)
    }
    
    private func configureViews() {
        view.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc private func buttonTouched(_ sender: UIButton?) {
        guard let url = Bundle.main.url(forResource: "Example", withExtension: "mp4") else { return }
        let selectPhotoViewController = SelectPhotoViewController(urlPath: url, degrees: [:], selectedEye: .left, recommandedUncoverFrameTime: 2.5, recommandedCoverFrameTime: 5.5)
        navigationController?.pushViewController(selectPhotoViewController, animated: true)
        let backItem = UIBarButtonItem()
        backItem.title = ""
        backItem.tintColor = .white
        navigationItem.backBarButtonItem = backItem
    }
}
