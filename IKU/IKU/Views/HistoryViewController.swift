//
//  HistoryViewController.swift
//  IKU
//
//  Created by Moon Jongseek on 2022/11/11.
//

import UIKit
import AVFoundation

final class HistoryViewController: UIViewController {
    // MARK: - Properties
    private var eyeSegmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["왼쪽 눈", "오른쪽 눈"])// ["Left", "Right"]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleTextAttributes([.font: UIFont.nexonGothicFont(ofSize: 13)], for: .normal)
        view.setTitleTextAttributes([.font: UIFont.nexonGothicFont(ofSize: 13, weight: .bold)], for: .selected)
        view.selectedSegmentIndex = 0
        return view
    }()
    
    private var todayStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "우리아이의 사시각 오늘도 검사완료!"
        label.font = .nexonGothicFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        
        label.backgroundColor = .white
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    private var ikuCalendarView: IKUCalendarView = {
        let view = IKUCalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var ikuChartView: IKUChartView = {
        let view = IKUChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    lazy private var testButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.tintColor = .black
        button.backgroundColor = .ikuLightGray
        button.setTitle("검사하기", for: .normal)
        button.titleLabel?.font = .nexonGothicFont(ofSize: 20, weight: .bold)
        button.addTarget(self, action: #selector(touchTestButton(_:)), for: .touchUpInside)
        
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        
//        self.view.addSubview(button)
        return button
    }()
    
    // MARK: - Methods
    private func configureNavigationBar() {
        
    }
    
    private func setupLayoutConstraint() {
        view.addSubview(todayStatusLabel)
        view.addSubview(ikuCalendarView)
        view.addSubview(ikuChartView)
        view.addSubview(eyeSegmentedControl)
        
        NSLayoutConstraint.activate([
            todayStatusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            todayStatusLabel.heightAnchor.constraint(equalToConstant: 60),
            todayStatusLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            todayStatusLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ikuCalendarView.topAnchor.constraint(equalTo: todayStatusLabel.bottomAnchor, constant: 18),
            ikuCalendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ikuCalendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ikuChartView.topAnchor.constraint(equalTo: ikuCalendarView.bottomAnchor, constant: 18),
            ikuChartView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ikuChartView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            eyeSegmentedControl.topAnchor.constraint(equalTo: ikuChartView.topAnchor, constant: 8),
            eyeSegmentedControl.trailingAnchor.constraint(equalTo: ikuChartView.trailingAnchor, constant: -8),
            eyeSegmentedControl.widthAnchor.constraint(equalTo: ikuChartView.widthAnchor, multiplier: 0.5),
            eyeSegmentedControl.heightAnchor.constraint(equalTo: ikuChartView.heightAnchor, multiplier: 0.2),
        ])
    }
    
    private func goToCoverTestView() {
        let navigationController = UINavigationController()
        let coverTestViewController = CoverTestViewController()
        navigationController.navigationBar.tintColor = .white
        navigationController.view.backgroundColor = .white
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(coverTestViewController, animated: true)
        self.present(navigationController, animated: true)
    }
    
    // MARK: - Objc-C Methods
    @objc private func touchTestButton(_ sender: UIButton) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] permission in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if permission {
                    self.goToCoverTestView()
                } else {
                    self.showAlertPermissionSetting(title: "Require Camera Permission",
                                                    message: "사시각 측정을 위해 카메라 권한이 필요합니다.\n설정으로 이동하시겠습니까?")
                }
            }
        }
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ikuBackground
        configureNavigationBar()
        setupLayoutConstraint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ikuCalendarView.commitCalendarViewUpdate()
    }
}
