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
    var resultAngle: Int = 10
    var numberEye: Int = 0
    var angleNum: Int = 11
    var url: URL?
    var eyeImages: (leftImage: UIImage, rightImage: UIImage) = (UIImage(), UIImage())
    
    // MARK: - Methods
    func prepareData(leftImage: UIImage, rightImage: UIImage) {
        eyeImages.leftImage = leftImage
        eyeImages.rightImage = rightImage
    }
    
    func setupNavigationBar() {
        let label = UILabel()
        label.text = "검사결과"
        label.font = .nexonGothicFont(ofSize: 17, weight: .bold)
        label.textColor = .black
        label.textAlignment = .center
        navigationItem.titleView = label

        let barButtonItemImage = UIImage(systemName: "xmark",
                                         withConfiguration: UIImage.SymbolConfiguration(pointSize: 17, weight: .medium, scale: .medium))
        let barButtonItem = UIBarButtonItem(image: barButtonItemImage,
                                            style: .plain,
                                            target: self,
                                            action: #selector(dismiss(_:)))
        barButtonItem.tintColor = .black
        navigationItem.setRightBarButton(barButtonItem, animated: true)
    }
    
    func fetchUI() {
        for k in 0...14 {
            resultPicker.arrangedSubviews[k].alpha = 0
        }
        resultPicker.arrangedSubviews[angleNum-1].alpha = 1

        for i in angleNum...14 {
            result.arrangedSubviews[i].alpha = 0.5
        }
    
        titleLabel.text = "우리 아이의 \(numberEye == 0 ? "왼쪽" : "오른쪽") 눈 검사의 결과입니다."
        
        angleResult.text = "\(resultAngle) 도"

        resultmemoLabel.numberOfLines = 2
        resultmemoLabel.textColor = UIColor.black
        
        //멘트 수정해 주세요!
        switch angleNum {
        case 0...4:
            resultmemoLabel.text = "우리 아이의 눈은 아주 건강합니다. \n걱정마셈요"
        case 5...9:
            resultmemoLabel.text = "우리아이가 일상생활에 큰 불편함을 느낀다면 \n안과를 방문해여 전문적인 검사가 필요합니다."
        case 10...14:
            resultmemoLabel.text = "우리아이가 마이 아파요.. \n빨리 병원 가세요! 이러다 다~ 죽어~ "
        default:
            print("Error")
        }
        
        uncoveredEye.image = eyeImages.leftImage
        coveredeye.image = eyeImages.rightImage
        
        legalLabel.numberOfLines = 10
        legalLabel.text = " 간단한 셀프 테스트입니다. 정학한 진단은 병원을 방문하여 의사와 상담바랍니다. 영상 퐐영 기기 혹은 주변 환경에 따라 검사 결과가 달라질 수 있습니다. 훈련된 전문가로부터 진단을 받기를 권고합니다. 이 앱에서 나온 결과를 진단 혹은 치료 계획의 일환으로 사용하지 마십시오."
    }
    
    @objc func dismiss(_ sender: UIBarButtonItem) {
        showAlertController(title: "다시 검사하기", message: "입력된 정보가 사라집니다.\n취소하시겠습니까?") {
            self.dismiss(animated: true)
        }
    }
    
    // MARK: - IBOutlets
    //예상사시각
    @IBOutlet weak var titleLabel: UILabel!
    //왼쪽, 오른쪽 사진
    @IBOutlet weak var uncoveredEye: UIImageView!
    @IBOutlet weak var coveredeye: UIImageView!
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
    @IBOutlet weak var resultmemoLabel: UILabel!
    //검사결과 요약 글
    @IBOutlet weak var legalLabel: UILabel!
    //법 조항?
    @IBOutlet weak var dangerLabel: UILabel!
    
    // MARK: - IBActions
    @IBAction func restartTest(_ sender: Any) {
        showAlertController(title: "입력 실행 취소", message: "입력된 정보가 사라집니다.\n취소하시겠습니까?") {
            self.navigationController?.popToRootViewController(animated: true)
        }
        
    }
    
    @IBAction func storageResult(_ sender: Any) {
        guard let url else { return }
        PHPhotoManager.share.saveVideo(url: url) {
            DispatchQueue.main.async { [weak self] in
                guard let tabBarController = self?.presentingViewController as? UITabBarController else { return }
                tabBarController.selectedIndex = 1
                self?.dismiss(animated: true)
            }
        } errorHandler: {
            DispatchQueue.main.async { [weak self] in
                self?.showAlertPermissionSetting(title: "Require Library Permission",
                                                 message: "동영상 저장을 위해 사진첩 권한이 필요합니다.\n설정으로 이동하시겠습니까?")
            }
        }
    }
    
    // MARK: - Delegates And DataSources
    
    // MARK: - Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        fetchUI()
    }
}
