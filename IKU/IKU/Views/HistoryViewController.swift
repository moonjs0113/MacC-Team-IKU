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
    lazy private var eyeSegmentedControl: UISegmentedControl = {
        let view = UISegmentedControl(items: ["왼쪽", "오른쪽"])// ["Left", "Right"]
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setTitleTextAttributes([.font: UIFont.nexonGothicFont(ofSize: 13)], for: .normal)
        view.setTitleTextAttributes([.font: UIFont.nexonGothicFont(ofSize: 13, weight: .bold)], for: .selected)
        view.selectedSegmentIndex = 0
        self.view.addSubview(view)
        return view
    }()
    
    lazy private var todayStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "우리아이의 사시각 오늘도 검사완료!"
        label.font = .nexonGothicFont(ofSize: 17)
        label.textColor = .black
        label.textAlignment = .center
        
        label.backgroundColor = .white
        label.layer.cornerRadius = 10
        label.clipsToBounds = true
        
        self.view.addSubview(label)
        return label
    }()
    
    lazy private var ikuCalendarView: IKUCalendarView = {
        let view = IKUCalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }()
    
    lazy private var ikuChartView: IKUChartView = {
        let view = IKUChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
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
        
        self.view.addSubview(button)
        return button
    }()
    
    // MARK: - Methods
    private func setupLayoutConstraint() {
        NSLayoutConstraint.activate([
            eyeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 11),
            eyeSegmentedControl.heightAnchor.constraint(equalToConstant: 42),
            eyeSegmentedControl.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            eyeSegmentedControl.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            todayStatusLabel.topAnchor.constraint(equalTo: eyeSegmentedControl.bottomAnchor, constant: 11),
            todayStatusLabel.heightAnchor.constraint(equalToConstant: 60),
            todayStatusLabel.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            todayStatusLabel.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ikuCalendarView.topAnchor.constraint(equalTo: todayStatusLabel.bottomAnchor, constant: 18),
            ikuCalendarView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ikuCalendarView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            ikuChartView.topAnchor.constraint(equalTo: ikuCalendarView.bottomAnchor, constant: 18),
            ikuChartView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            ikuChartView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            
            testButton.topAnchor.constraint(equalTo: ikuChartView.bottomAnchor, constant: 18),
            testButton.heightAnchor.constraint(equalToConstant: 52),
            testButton.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            testButton.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
        ])
    }
    
    private func goToCoverTestView() {
        let navigationController = UINavigationController()
        let coverTestViewController = CoverTestViewController()
        navigationController.view.backgroundColor = .white
        navigationController.modalPresentationStyle = .fullScreen
        navigationController.pushViewController(coverTestViewController, animated: true)
        self.present(navigationController, animated: true)
    }
    
    private func showAlertPermissionSetting() {
        let alert = UIAlertController(title: "Require Camera Permission",
                                      message: "사시각 측정을 위해 카메라 권한이 필요합니다.\n설정으로 이동하시겠습니까?",
                                      preferredStyle: .alert)
        let ok = UIAlertAction(title: "예", style: .default) { [weak self] _ in
            self?.openSystemSetting()
        }
        let cancel = UIAlertAction(title: "아니오", style: .cancel)
        alert.addAction(ok)
        alert.addAction(cancel)
        present(alert, animated: true)
    }
    
    // MARK: - Objc-C Methods
    @objc private func touchTestButton(_ sender: UIButton) {
        AVCaptureDevice.requestAccess(for: .video) { [weak self] permission in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if permission { self.goToCoverTestView() }
                else { self.showAlertPermissionSetting() }
            }
        }
    }
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .ikuBackground
        setupLayoutConstraint()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ikuCalendarView.commitCalendarViewUpdate()
    }
}
