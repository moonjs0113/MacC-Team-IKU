//
//  SceneDelegate.swift
//  IKU
//
//  Created by Shin Jae Ung on 2022/11/10.
//

import UIKit
import SwiftUI

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)
        
        //탭바컨트롤러의 생성
        let tabBarVC = UITabBarController()
        
     
        //첫번째 화면은 일단
        let testVC = ViewController()
        let historyVC = HistoryViewController()
        let dictionaryVC = InformationViewController()//DictionaryViewController()
        
        //탭바 이름들 설정
        testVC.title = "사시검사"
        historyVC.title = "히스토리"
        dictionaryVC.title = "백과사전"
        
        //탭바로 사용하기 위한 뷰 컨트롤러들 설정
        tabBarVC.setViewControllers([testVC,historyVC,dictionaryVC], animated: false)
        tabBarVC.modalPresentationStyle = .fullScreen
        tabBarVC.tabBar.backgroundColor = .ikuBackground
        tabBarVC.selectedIndex = 1
        
        //탭바 이미지 설정
        guard let items = tabBarVC.tabBar.items else { return }
        items[0].image = UIImage(systemName: "magnifyingglass")
        items[1].image = UIImage(systemName: "calendar")
        items[2].image = UIImage(systemName: "book")

        window?.rootViewController = tabBarVC
        window?.makeKeyAndVisible()
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}

