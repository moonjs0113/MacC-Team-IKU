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
    
    enum ResultGuideText: String {
        case strabismus = "If the angle is more than 5 degrees (10PD),\nThere is a possibility that is a strabismus"
        //"수평 사시각이 5도(10PD)가 넘으면\n사시 스팩트럼 안에 들어갈 가능성이 있습니다."
        case normal = "If the angle is less than 5 degrees (10PD),\nThere is a possibility that isn't a strabismus"
        // "수평 사시각이 5도(10PD) 이하이면\n사시 스팩트럼 안에 들어가지 않을 가능성이 있습니다."
    }
    
    var resultAngle: Double {
        return (abs(angle.0 - angle.1) * 180 / .pi).roundSecondPoint
    }
    
    var angle: (Double, Double) = (0.0, 0.0)
    var selectedTime: (uncover: Double, cover: Double) = (0.0, 0.0)
    var numberEye: Eye = .left
    var isStrabismus: Bool {
        resultAngle >= 5.0
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
    
    var isReplayButtonHidden: Bool = true
    
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
    
    private func setButtonAttributedString(buttonText: String) {
        let attributedText = NSMutableAttributedString(string: buttonText)
        attributedText.addAttributes([.underlineStyle: NSUnderlineStyle.thick.rawValue,
                                      .underlineColor: UIColor.ikuBlue,
                                      .font: UIFont.nexonGothicFont(ofSize: 17, weight: .bold),
                                      .foregroundColor: UIColor.ikuBlue,
                                     ],
                                     range: NSRange(location: 0, length: buttonText.count))
        guideButton.setAttributedTitle(attributedText, for: .normal)
        
        let attributedHighlightedText = NSMutableAttributedString(string: buttonText)
        attributedHighlightedText.addAttributes([.underlineStyle: NSUnderlineStyle.thick.rawValue,
                                      .underlineColor: UIColor.ikuBlue.withAlphaComponent(0.5),
                                      .font: UIFont.nexonGothicFont(ofSize: 17, weight: .bold),
                                      .foregroundColor: UIColor.ikuBlue.withAlphaComponent(0.5),
                                     ],
                                     range: NSRange(location: 0, length: buttonText.count))
        guideButton.setAttributedTitle(attributedHighlightedText, for: .highlighted)
    }
    
    func fetchUI() {
        let attributedStr = NSMutableAttributedString(string: "\(resultAngle)º")
        attributedStr.addAttribute(.font, value: UIFont.systemFont(ofSize: 28, weight: .bold), range: ("\(resultAngle)º" as NSString).range(of: "º"))
        degreeLabel.attributedText = attributedStr
        
        prizmLabel.text = "(\(resultAngle*2)PD)"
        
        resultGuideLabel.text = (isStrabismus ? ResultGuideText.strabismus : ResultGuideText.normal).rawValue
        
        setButtonAttributedString(buttonText: isStrabismus ? "What should I do?" : "If you worried about Strabismus.")
        
        uncoveredEye.image = eyeImages.leftImage
        coveredeye.image = eyeImages.rightImage
        
        if root == .test {
            segmentedControl.removeFromSuperview()
        } else {
            segmentedControl.selectedSegmentIndex = (numberEye == .left ? 0 : 1)
        }
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
        
        numberEye = (dbData.measurementResult.isLeftEye ? .left : .right)
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
        showAlertController(title: "Cancel input action", message: "The information disappears.\nDo you want to cancel?") {
            self.dismiss(animated: true)
        }
    }
    
    @objc func bookmarkResult(_ sender: UIBarButtonItem) {
        do {
            let persistenceManager = try PersistenceManager()
            var localIdentifier = ""
            if dbData.count > 1 {
                localIdentifier = dbData[segmentedControl.selectedSegmentIndex].measurementResult.localIdentifier
            } else {
                localIdentifier = dbData.first?.measurementResult.localIdentifier ?? ""
            }
            try persistenceManager.updateVideo(withLocalIdentifier: localIdentifier, bookmarked: !isBookMarked)
            isBookMarked = !isBookMarked
        } catch {
            self.showAlertController(title: "Bookmark Save failed", message: "Failed to save bookmark.", isAddCancelAction: false) { }
        }
    }
    
    @objc func deleteResult(_ sender: UIBarButtonItem) {
        showAlertController(title: "Test Result Delete", message: "Recovery after deletion is not possible.\nAre you sure you want to delete?") {
            do {
                let persistenceManager = try PersistenceManager()
                var localIdentifier = ""
                if self.dbData.count > 1 {
                    localIdentifier = self.dbData[self.segmentedControl.selectedSegmentIndex].measurementResult.localIdentifier
                } else {
                    localIdentifier = self.dbData.first?.measurementResult.localIdentifier ?? ""
                }
                try persistenceManager.deleteVideo(withLocalIdentifier: localIdentifier)
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
    
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var degreeLabel: UILabel!
    @IBOutlet weak var prizmLabel: UILabel!
    
    @IBOutlet weak var resultGuideLabel: UILabel!
    
    @IBOutlet weak var guideButton: UIButton!
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var testAgainButton: UIButton!
    @IBOutlet weak var replayButton: UIButton! {
        didSet {
            replayButton.isHidden = isReplayButtonHidden
        }
    }
    
    // MARK: - IBActions
    @IBAction func restartTest(_ sender: Any) {
        showAlertController(title: "Test Again", message: "The information disappears.\nAre you sure you want to cancel?") {
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
    
    @IBAction func goToGuideView(_ sender: UIButton) {
        //TODO: - Connect GuideView
        let careGuideViewController = CareGuideView.controller
        careGuideViewController.modalPresentationStyle = .overFullScreen
        careGuideViewController.view.backgroundColor = .black.withAlphaComponent(0.5)
        present(careGuideViewController, animated: true)
    }
    
    @IBAction func replayButtonTouched(_ sender: UIButton) {
        guard let url = dbData.first?.videoURL else { return }
        let selectPhotoViewController = SelectPhotoViewController(urlPath: url, degrees: degrees)
        navigationController?.pushViewController(selectPhotoViewController, animated: true)
    }
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupUI()
        if root != .test {
            if let dbData = (numberEye == .left ? dbData.first : dbData.last) {
                fetchDBData(dbData: dbData)
            }
        }
        fetchUI()
    }
}
