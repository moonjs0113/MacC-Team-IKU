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
        let view = UISegmentedControl(items: ["왼쪽 눈", "오른쪽 눈"])
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
    
    lazy private var ikuCalendarView: IKUCalendarView = {
        let view = IKUCalendarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(view)
        return view
    }()
    
    private var ikuChartView: IKUChartView = {
        let view = IKUChartView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    
    // MARK: - Methods
    private func setupNavigationController() {
        let backItem = UIBarButtonItem()
        backItem.title = ""
        navigationItem.backBarButtonItem = backItem
    }
    
    private func setupCalendarView() {
        ikuCalendarView.didSelectDayView = goToResultView
        ikuCalendarView.goToHistoryListView = goToHistoryListView
    }
    
    private func setupLayoutConstraint() {
        view.addSubview(todayStatusLabel)
        view.addSubview(ikuChartView)
        ikuChartView.addSubview(eyeSegmentedControl)
        
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
    
    private func fetchData() {
        do {
            let persistenceManager = try PersistenceManager()
            ikuCalendarView.calendarView.data = try persistenceManager.fetchVideo(.all)
            let todayData = try persistenceManager.fetchVideo(.at(day: Date.now))
            todayStatusLabel.text = todayData.isEmpty ? "Please start today’s starabismus test!" : "Lisa’s strabismus test completed!"
        } catch {
            // TODO: Merge 후 수정
            self.showAlertController(title: "데이터 불러오기 실패", message: "검사 결과를 불러오는데 실패하였습니다.", completeHandler: {})
        }
    }
    
    private func goToResultView(data: [(videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)]) {
        // TODO: - 결과뷰 Present
        guard let resultViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ResultViewController") as? ResultViewController else {
            return
        }
        
        resultViewController.prepareData(data: data)
        resultViewController.root = .history
        navigationController?.pushViewController(resultViewController, animated: true)
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
    
    private func goToHistoryListView() {
        let historyListViewController = HistoryListViewController()
        navigationController?.pushViewController(historyListViewController, animated: true)
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
        setupNavigationController()
        setupCalendarView()
        setupLayoutConstraint()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        ikuCalendarView.commitCalendarViewUpdate()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        ikuCalendarView.commitCalendarViewUpdate()
    }
}
