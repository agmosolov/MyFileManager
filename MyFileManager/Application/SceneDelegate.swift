//
//  SceneDelegate.swift
//  MyFileManager
//
//  Created by Александр Мосолов on 07.10.2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        window = UIWindow(windowScene: windowScene)

        let passwordVC = PasswordViewController()
        window?.rootViewController = passwordVC
        window?.makeKeyAndVisible()
    }
}
