//
//  HistoryListViewController.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/24.
//

import UIKit

class HistoryListViewController: UIViewController {
    // MARK: - Properties
    
    // MARK: - Methods
    private func setupNavigationController() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
        self.title = "List"
        
        let barButtonItemImage = UIImage(systemName: "bookmark",
                                         withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium))
        let barButtonItem = UIBarButtonItem(image: barButtonItemImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(filterBookmark(_:)))
        barButtonItem.tintColor = .black
        navigationItem.setRightBarButtonItems([barButtonItem], animated: true)
    }
    
    @objc func filterBookmark(_ sender: UIBarButtonItem) {
        
    }
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ikuBackground
        setupNavigationController()
    }

}
