//
//  InformationViewController.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/18.
//

import UIKit
import Combine

class InformationViewController: UIViewController {
    // MARK: - Properties
    var profileData: String? = "더미데이터"
    
    private var anyCancellable = Set<AnyCancellable>()
    
    // UI
    private var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "우리아이의 프로필을 작성해주세요."
        label.font = .nexonGothicFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        return label
    }()
    
    lazy private var profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "person"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .black
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .ikuLightGray
        imageView.bindLayout(anyCancellable: &self.anyCancellable)
        return imageView
    }()
    
    lazy private var photoButton: UIView = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .ikuDarkGray
        button.bindLayout(anyCancellable: &self.anyCancellable)
        button.addTarget(self, action: #selector(touchUpPhotoButton(_:)), for: .touchUpInside)
        
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(profileImageView)
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            profileImageView.widthAnchor.constraint(equalTo: view.heightAnchor),
            profileImageView.heightAnchor.constraint(equalTo: view.heightAnchor),
            profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            profileImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            button.widthAnchor.constraint(equalTo: profileImageView.widthAnchor, multiplier: 1/3),
            button.heightAnchor.constraint(equalTo: profileImageView.heightAnchor, multiplier: 1/3),
            button.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            button.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
        ])
        
        return view
    }()
    
    var nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .nexonGothicFont(ofSize: 17)
        return textField
    }()
    
    var ageTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .nexonGothicFont(ofSize: 17)
        return textField
    }()
    
    var hospitalTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.font = .nexonGothicFont(ofSize: 17)
        return textField
    }()
    
    let textFieldTitle: [String] = ["닉네임", "연령", "병원 즐겨찾기"]
    
    lazy var textFieldStackView: UIStackView = {
        let nameTextField = createTextFieldUI(self.nameTextField, textFieldTitle[0])
        let ageTextField = createTextFieldUI(self.ageTextField, textFieldTitle[1])
        let hospitalTextField = createTextFieldUI(self.hospitalTextField, textFieldTitle[2])
        
        let stackView = UIStackView(arrangedSubviews: [nameTextField, ageTextField, hospitalTextField])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    lazy var completeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(profileData == nil ? "저장하기" : "수정하기", for: .normal)
        button.titleLabel?.font = .nexonGothicFont(ofSize: 20, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = .ikuBlue
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(touchUpCompleteButton(_:)), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Methods
    private func createTextFieldUI(_ textField: UITextField, _ string: String) -> UIView {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = string
        label.font = .nexonGothicFont(ofSize: 13)
        label.textColor = .ikuCalendarWeeklyTitle
        label.textAlignment = .left
        
        view.addSubview(label)
        view.addSubview(textField)
        
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 12),
            label.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),

            textField.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -10),
            textField.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            view.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        return view
    }
    
    private func setupNavigationBar() {
        let label = UILabel()
        label.text = "프로필"
        label.font = .nexonGothicFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        navigationItem.titleView = label
    }
    
    private func setupLayoutConstraint() {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.addSubview(titleLabel)
        scrollView.addSubview(photoButton)
        scrollView.addSubview(textFieldStackView)
        view.addSubview(scrollView)
        view.addSubview(completeButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            titleLabel.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor, constant: 30),
            titleLabel.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            titleLabel.widthAnchor.constraint(equalTo: scrollView.widthAnchor),

            photoButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            photoButton.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor, multiplier: 3/10),
            photoButton.widthAnchor.constraint(equalTo: scrollView.contentLayoutGuide.widthAnchor, multiplier: 3/10),
            photoButton.centerXAnchor.constraint(equalTo: scrollView.contentLayoutGuide.centerXAnchor),
            
            textFieldStackView.topAnchor.constraint(equalTo: photoButton.bottomAnchor, constant: 30),
            textFieldStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            textFieldStackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            
            completeButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 10),
            completeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -15),
            completeButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            completeButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            completeButton.heightAnchor.constraint(equalToConstant: 60),
        ])
    }
    
    @objc private func touchUpPhotoButton(_ sender: UIButton) {
        print(#function)
    }
    
    @objc private func touchUpCompleteButton(_ sender: UIButton) {
        print(#function)
    }
    
    // MARK: - IBOutlets
    
    // MARK: - IBActions
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ikuBackground
        addEndEditingGesture()
        setupNavigationBar()
        setupLayoutConstraint()
        
    }
}
