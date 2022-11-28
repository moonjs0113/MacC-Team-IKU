//
//  ResultViewController.swift
//  IKU
//
//  Created by kwon ji won on 2022/11/15.
//

import UIKit
import AVKit
import Foundation
import Photos

class ResultViewController: UIViewController {
    // MARK: - Properties
    enum Root {
        case test
        case history_calendar
        case history_list
    }
    
    var resultAngle: Double {
        return (abs(angle.0 - angle.1) * 180 / .pi).roundSecondPoint
    }
    
    var angle: (Double, Double) = (0.0, 0.0)
    var selectedTime: (uncover: Double, cover: Double) = (0.0, 0.0)
    var numberEye: Eye = .left
    var angleNum: Int {
        //TODO: - 계산된 resultAngle로 위험도를 어떻게 결정할 것인지 논의 필요
        return Int(resultAngle) > 14 ? 14 : Int(resultAngle)
    }
    var url: URL?
    var degrees: [Double: Double] = [:]
    var eyeImages: (leftImage: UIImage, rightImage: UIImage) = (UIImage(), UIImage())
    var isBookMarked = false {
        didSet {
            let barButtonItemImage = UIImage(systemName: isBookMarked ? "bookmark.fill" : "bookmark",
                                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium))
            barButtonItem.image = barButtonItemImage
        }
    }
    var root: Root = .test
    
    var dbData: [(videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)] = []
    
    var barButtonItem: UIBarButtonItem = UIBarButtonItem()
    
    // MARK: - Methods
    func prepareData(data: [(videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)], showedEye: Eye
                      = .left) {
        self.dbData = data
        self.numberEye = showedEye
    }
    
    func setupNavigationBar() {
        let label = UILabel()
        label.text = "Test Result"
        label.font = .nexonGothicFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        navigationItem.titleView = label
        
        let items = makeBarButtonItemList()
        navigationItem.setRightBarButtonItems(items, animated: true)
    }
    
    func setupUI() {
        segmentedControl.isEnabled = (dbData.count == 2)
        dbData.sort {
            let prev = $0.measurementResult.isLeftEye ? 0 : 1
            let next = $1.measurementResult.isLeftEye ? 0 : 1
            return prev < next
        }
    }
    
    func makeBarButtonItemList() -> [UIBarButtonItem] {
        switch root {
        case .test:
            let barButtonItemImage = UIImage(systemName: "xmark",
                                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium))
            barButtonItem = UIBarButtonItem(image: barButtonItemImage,
                                                style: .plain,
                                                target: self,
                                                action: #selector(dismiss(_:)))
            barButtonItem.tintColor = .black
            return [barButtonItem]
        case .history_list, .history_calendar:
            let barButtonItemImage = UIImage(systemName: "bookmark",
                                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium))
            barButtonItem = UIBarButtonItem(image: barButtonItemImage,
                                                style: .plain,
                                                target: self,
                                                action: #selector(bookmarkResult(_:)))
            barButtonItem.tintColor = .black
            
            let deleteBarButtonItemImage = UIImage(systemName: "trash",
                                             withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium))
            let deletebarButtonItem = UIBarButtonItem(image: deleteBarButtonItemImage,
                                                style: .plain,
                                                target: self,
                                                action: #selector(deleteResult(_:)))
            deletebarButtonItem.tintColor = .black
            return [deletebarButtonItem, barButtonItem]
        }
    }
    
    func fetchUI() {
        for k in 0...14 {
            resultPicker.arrangedSubviews[k].alpha = 0
        }
        
        resultPicker.arrangedSubviews[angleNum].alpha = 1

        for i in 0...angleNum {
            result.arrangedSubviews[i].alpha = 1
        }
        
        angleResult.text = "\(resultAngle)"

        
        //멘트 수정해 주세요!
        switch angleNum {
        case 0...4:
            resultmemoLabel.text = "child's eyes are healthy. \nIf child feels great inconvenience in daily life,please visit a specialist and have a professional test."
        case 5...9:
            resultmemoLabel.text = "Please check your child's strabismus carefully.\nIf child feels great inconvenience in daily life,please visit a specialist and have a professional test."
        case 10...14:
            resultmemoLabel.text = "There is something wrong with eyes. \nPlease visit an hospital as soon as possible for accurate test"
        default:
            print("Error")
        }
        
        uncoveredEye.image = eyeImages.leftImage
        coveredeye.image = eyeImages.rightImage
        
        if root == .test {
            segmentedControl.removeFromSuperview()
        } else {
            segmentedControl.selectedSegmentIndex = (numberEye == .left ? 0 : 1)
        }
        
        legalLabel.numberOfLines = 10
        legalLabel.text = "This service is a simple self-test. Not diagnosis App.\nFor accurate test, please visit the hospital.\nThe test results may depending on the imaging device or the surrounding environment.\nDo not write results from this app as part of a diagnosis or treatment plan."
        legalLabel.font = .nexonGothicFont(ofSize: 11)
        
    }
    
    func fetchDBData(dbData: (videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)) {
        var time = CMTimeMake(value: Int64(dbData.measurementResult.timeOne * 10), timescale: 10)
        let asset = AVURLAsset(url: dbData.videoURL)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.requestedTimeToleranceBefore = .zero
        generator.requestedTimeToleranceAfter = .zero
        generator.generateCGImageAsynchronously(for: time) { image, _, _ in
            DispatchQueue.main.async { [weak self] in
                if let image = image {
                    self?.uncoveredEye.image = UIImage(cgImage: image)
                }
            }
        }
        time = CMTimeMake(value: Int64(dbData.measurementResult.timeTwo * 10), timescale: 10)
        generator.generateCGImageAsynchronously(for: time) { image, _, _ in
            DispatchQueue.main.async { [weak self] in
                if let image = image {
                    self?.coveredeye.image = UIImage(cgImage: image)
                }
            }
        }
        
        angle = (dbData.angles[dbData.measurementResult.timeOne] ?? 0.0,
                 dbData.angles[dbData.measurementResult.timeTwo] ?? 0.0)
        
        saveButton.isHidden = true
        testAgainButton.isHidden = !(Calendar.current.compare(Date.now, to: dbData.measurementResult.creationDate, toGranularity: .day) == .orderedSame)
    }
    
    private func saveData() {
        guard let url else { return }
        do {
            let persistenceManager = try PersistenceManager()
            try persistenceManager.save(videoURL: url,
                                         withARKitResult: degrees,
                                         isLeftEye: (numberEye == .left),
                                         uncoveredPhotoTime: selectedTime.uncover,
                                         coveredPhotoTime: selectedTime.cover)
            dismiss(animated: true)
            (presentingViewController as? UITabBarController)?.selectedIndex = 1
        } catch {
            showAlertController(title: "Save failed", message: "Failed to save test result", isAddCancelAction: false) { }
        }
    }
    
    private func checkPreviousData(data: (videoURL: URL, angles: [Double: Double], measurementResult: MeasurementResult)) -> Bool {
        let isSameDate = Calendar.current.compare(.now, to: data.measurementResult.creationDate, toGranularity: .day) == .orderedSame
        let isSameEye = (data.measurementResult.isLeftEye ? .left : .right) == numberEye
        return isSameDate && isSameEye
    }
    
    @objc func dismiss(_ sender: UIBarButtonItem) {
        showAlertController(title: "Restart", message: "Save") {
            self.dismiss(animated: true)
        }
    }
    
    @objc func bookmarkResult(_ sender: UIBarButtonItem) {
        do {
            let persistenceManager = try PersistenceManager()
            try persistenceManager.updateVideo(withLocalIdentifier: dbData[segmentedControl.selectedSegmentIndex].measurementResult.localIdentifier, bookmarked: !isBookMarked)
            isBookMarked = !isBookMarked
        } catch {
            self.showAlertController(title: "북마크 저장 실패", message: "북마크 저장에 실패했습니다.", isAddCancelAction: false) { }
        }
    }
    
    @objc func deleteResult(_ sender: UIBarButtonItem) {
        showAlertController(title: "Test Result Delete", message: "Recovery after deletion is not possible. \nAre you sure you want to delete?") {
            do {
                let persistenceManager = try PersistenceManager()
                try persistenceManager.deleteVideo(withLocalIdentifier: self.dbData[self.segmentedControl.selectedSegmentIndex].measurementResult.localIdentifier)
                self.navigationController?.popViewController(animated: true)
            } catch {
                self.showAlertController(title: "Delete failed", message: "Failed to delete test result", isAddCancelAction: false) { }
            }
        }
    }
    
    // MARK: - IBOutlets
    // 왼쪽, 오른쪽 사진
    @IBOutlet weak var uncoveredEye: UIImageView!
    @IBOutlet weak var coveredeye: UIImageView!
    // 왼쪽 오른쪽
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    //예상 사시각
    @IBOutlet weak var memoTitle: UILabel!
    //몇도인지 나타내는 라벨
    @IBOutlet weak var angleResult: UILabel!
    //단계 피커 스택
    @IBOutlet weak var resultPicker: UIStackView!
    //단계 15칸 스택
    @IBOutlet weak var result: UIStackView!
    //안전
    @IBOutlet weak var safeLabel: UILabel!
    //주의
    @IBOutlet weak var carefulLabel: UILabel!
    //검사요망
    @IBOutlet weak var worriedLabel: UILabel!
    @IBOutlet weak var resultmemoLabel: UILabel!
    //검사결과 요약 글
    @IBOutlet weak var legalLabel: UILabel!
    //법 조항?
    @IBOutlet weak var dangerLabel: UILabel!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var testAgainButton: UIButton!
    
    // MARK: - IBActions
    @IBAction func restartTest(_ sender: Any) {
        showAlertController(title: "Cancel input action", message: "The information disappears.\nAre you sure you want to cancel?") {
            switch self.root {
            case .test:
                self.navigationController?.popToRootViewController(animated: true)
            default:
                let root = self.navigationController?.viewControllers.first
                let navigationController = UINavigationController()
                let coverTestViewController = CoverTestViewController()
                coverTestViewController.selectedEye = self.numberEye
                navigationController.navigationBar.tintColor = .white
                navigationController.view.backgroundColor = .white
                navigationController.modalPresentationStyle = .fullScreen
                navigationController.pushViewController(coverTestViewController, animated: true)
                self.navigationController?.popToRootViewController(animated: true)
                root?.present(navigationController, animated: true)
            }
        }
    }
    
    @IBAction func storageResult(_ sender: Any) {
        do {
            let persistenceManager = try PersistenceManager()
            let todayData = try persistenceManager.fetchVideo(.at(day: .now))
            if todayData.filter({ checkPreviousData(data: $0) }).isEmpty {
                saveData()
            } else {
                showAlertController(title: "Result Already exists.", message: "The \(numberEye == .left ? "left" : "right") eye test result already exists. Delete existing test results and save new test results?") { [weak self] in
                    guard let self = self else { return }
                    guard let previousData =  todayData.filter({ self.checkPreviousData(data: $0) }).first else {
                        return
                    }
                    do {
                        try persistenceManager.deleteVideo(withLocalIdentifier: previousData.measurementResult.localIdentifier)
                        self.saveData()
                    } catch {
                        self.showAlertController(title: "Delete failed", message: "Failed to delete test result", isAddCancelAction: false) { }
                    }
                }
            }
        } catch {
            showAlertController(title: "Save failed", message: "Failed to save test result", isAddCancelAction: false) { }
        }
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        numberEye = (sender.selectedSegmentIndex == 0 ? .left : .right)
        fetchDBData(dbData: dbData[sender.selectedSegmentIndex])
        fetchUI()
    }
    
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        if root != .test {
            if let dbData = (numberEye == .left ? dbData.first : dbData.last) {
                fetchDBData(dbData: dbData)
            }
        }
        fetchUI()
    }
}
