//
//  DictionatyViewController.swift
//  IKU
//
//  Created by kwon ji won on 2022/11/17.
//

import UIKit

class DictionaryViewController: UIViewController {
    
    let mainLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        makeAutoLayout()

    }
    
    func setup() {
        
        mainLabel.text = "백과사전이 들어갈 뷰입니다"
        
        view.addSubview(mainLabel)
        
        view.backgroundColor = .ikuBackgroundBlue
        
    }
    
    func makeAutoLayout(){
        mainLabel.translatesAutoresizingMaskIntoConstraints = false
        mainLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        mainLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    


}
