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
        self.window = UIWindow(windowScene: windowScene)
//        let firstViewController = UINavigationController()
        let firstViewController = UIHostingController(rootView: SF_StoryView())
        window?.rootViewController = firstViewController
        window?.makeKeyAndVisible()
//        firstViewController.setNavigationBarHidden(false, animated: true)
//        firstViewController.pushViewController(NavigationViewController(), animated: true)
    }

    func sceneDidDisconnect(_ scene: UIScene) {}

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}

