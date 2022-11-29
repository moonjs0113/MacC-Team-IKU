//
//  ViewController.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/10.
//

import UIKit

class ViewController: UIViewController {
    let mainLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        makeAutoLayout()

    }
    
    func setup() {
        
        mainLabel.text = "사시검사 뷰가 들어갑니다."
        
        view.addSubview(mainLabel)
        
        view.backgroundColor = .ikuBackgroundBlue
        
    }
    
    func makeAutoLayout(){
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    


}

