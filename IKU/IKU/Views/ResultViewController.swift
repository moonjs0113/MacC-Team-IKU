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
    //예상사시각
    @IBOutlet weak var titleLabel: UILabel!
    //왼쪽, 오른쪽 사진
    @IBOutlet weak var uncoveredEye: UIImageView!
    @IBOutlet weak var coveredeye: UIImageView!
    //예상 사시각
    @IBOutlet weak var memoTitle: UILabel!
    //몇도인지 나타내는 라벨
    @IBOutlet weak var angleResult: UILabel!
    //단계 15칸 스택
    @IBOutlet weak var result: UIStackView!
    //다시검사하기버튼
    @IBOutlet weak var backSelectPhotoView: UIButton!
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
    
    //예상 값 변수를 resultAngle로 정의하고 10으로 초기화 시킴 -> 받아오는 값
    var resultAngle: Int = 10

    
//오른쪽 눈인지 왼쪽 눈인지 선택하는 값 -> 기본값으 0(왼쪽)
//    var selectEye
    
//    var selectEye: String = "오른쪽"
    
//  1. 이전에서 오른쪽 왼쪽 중 뭔지 정의가 되어있다면 그냥 가져 온다.
//    var selectEyepreview: String = "오른쪽"
//    var selectEye: Eye = .왼쪽
    //            switch selectEye {
    //            case .왼쪽:
    //        titleLabel.text = "우리 아이의 왼쪽 눈 검사의 결과입니다."
    //            case .오른쪽:
    //        titleLabel.text = "우리 아이의 오른쪽 눈 검사의 결과입니다."
    //            }
    
//  2. 0,1값으로 이전 뷰가 정의되어 있다면 이런식으로 메칭시킨다.
    
//    enum Eye: Int {
//        case 왼쪽 = 0
//        case 오른쪽 = 1
//    }
    var numberEye: Int = 0
    //            var selectEye = "왼쪽"
    //            switch selectEye {
    //            case .왼쪽:
    //                selectEye = "왼쪽"
    //            case .오른쪽:
    //                selectEye = "오른쪽"
    //            }
    
//  3.
//            var selectEye: Eye = .right
//            switch selectEye {
//            case "왼쪽":
//                selectEye = "왼쪽"
//            case "오른쪽":
//                selectEye = "오른쪽"
//            default:
//                break
//            }

    
    override func viewDidLoad() {
        super.viewDidLoad()
//        print(Eye(rawValue: 1) ?? "")
        
//     1.결과
//        titleLabel.text = "우리 아이의 \(selectEyepreview)눈 검사의 결과입니다."
 

//        2. enum을 왈용한다.
//        var selectEye = Eye(rawValue: numberEye)!
//        titleLabel.text = "우리 아이의 \(selectEye) 눈 검사의 결과입니다."
        titleLabel.text = "우리 아이의 \(numberEye == 0 ? "왼쪽" : "오른쪽") 눈 검사의 결과입니다."
        

//                3.오른쪽 왼쪽 값을 받아와 title에 입력한다.
//      titleLabel.text = "우리 아이의 \(selectEye) 눈 검사의 결과입니다."
//
    
        
        //앞에 뷰에 있던 값을 가져온다.
        uncoveredEye.image = UIImage(named: "uncoverEye")
        coveredeye.image = UIImage(named: "coverEye")
        
        //resultAnlge 값을 불러와 View에 나타낸다.
        angleResult.text = "\(resultAngle) 도"
        //resultAngle만 글자를 키운다.
    
        
        //resultAngle값에 맞춰 pint를 찍어준다.
        
        
        resultmemoLabel.numberOfLines = 2
        resultmemoLabel.textColor = UIColor.black
        resultmemoLabel.text = "우리아이가 일상생활에 큰 불편함을 느낀다면 \n안과를 방문해여 전문적인 검사가 필요합니다."
        
        //단계에 다른 멘트를 다르게 해줘야한다.
        legalLabel.text = " 간단한 셀프 테스트입니다. 정학한 진단은 병원을 방문하여 의사와 상\n담바랍니다. 영상 퐐영 기기 혹은 주변 환경에 따라 검사 결과가 달라\n질 수 있습니다. 훈련된 전문가로부터 진단을 받기를 권고합니다. 이\n앱에서 나온 결과를 진단 혹은 치료 계획의 일환으로 쓰지는 마십시오."
        
//        func playVideo() {
//            guard let path = Bundle.main.path(forResource: "resultVideo", ofType: "mp4") else { debugPrint("Mp4 not found "); return }
//
//            let player = AVPlayer(url: URL(fileURLWithPath: path))
//
//            let PlayerController = AVPlayerViewController()
//            PlayerController.player = player
////            present(PlayerController, animated: true) {
////
////                player.play()
////            }
//        }
    }

    @IBAction func backSelectPhotoView(_ sender: Any) {
        // 다시 검사하기 버튼을 누르면 촬영 시작뷰로 넘어간다.
    }
    
    @IBAction func storageResult(_ sender: Any) {
        guard let path = Bundle.main.path(forResource: "resultVideo", ofType: "MOV") else { debugPrint("Mp4 not found "); return }
        
        let url = URL(fileURLWithPath: path)
        
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        }, completionHandler: { (success, error) in
            if success {
                print("success")
            } else if let error = error {
                print(error)
            }
        })
        
    }
}

