//
//  PasswordViewController.swift
//  MyFileManager
//
//  Created by Александр Мосолов on 07.10.2025.
//

import UIKit
import KeychainAccess

class PasswordViewController: UIViewController {

    private let keychain = Keychain(service: "com.agmosolov.MyFileManager")
    private var isCreatingPassword = true
    private var firstPasswordEntry: String?
    private var failedAttempts = 0
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите пароль"
        textField.isSecureTextEntry = true
        textField.borderStyle = .roundedRect
        return textField
    }()
    
    private let actionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать пароль", for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        
        let savedPassword = try? keychain.get("password")
        if savedPassword != nil {
            configureForPasswordEntry()
        } else {
            configureForPasswordCreation()
        }
    }
    
    private func setupUI() {
        view.addSubview(passwordTextField)
        view.addSubview(actionButton)
        
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        actionButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            passwordTextField.widthAnchor.constraint(equalToConstant: 200),
            
            actionButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            actionButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        actionButton.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
    }
    
    private func configureForPasswordCreation() {
        isCreatingPassword = true
        firstPasswordEntry = nil
        failedAttempts = 0
        actionButton.setTitle("Создать пароль", for: .normal)
        passwordTextField.text = ""
    }
    
    private func configureForPasswordEntry() {
        isCreatingPassword = false
        failedAttempts = 0
        actionButton.setTitle("Введите пароль", for: .normal)
        passwordTextField.text = ""
    }
    
    @objc private func actionButtonTapped() {
        guard let password = passwordTextField.text, password.count >= 4 else {
            showError("Пароль должен содержать минимум 4 символа.")
            return
        }
        
        if isCreatingPassword {
            if firstPasswordEntry == nil {
                firstPasswordEntry = password
                passwordTextField.text = ""
                actionButton.setTitle("Повторите пароль", for: .normal)
            } else if firstPasswordEntry == password {
                try? keychain.set(password, key: "password")
                showMainInterface()
            } else {
                showError("Пароли не совпадают.")
                configureForPasswordCreation() // Сброс состояния
            }
        } else {
            let savedPassword = try? keychain.get("password")
            if savedPassword == password {
                showMainInterface()
            } else {
                failedAttempts += 1
                if failedAttempts >= 2 {
                    showError("Две неудачные попытки. Создайте новый пароль.")
                    configureForPasswordCreation() // Сброс состояния после 2-й ошибки
                } else {
                    showError("Неправильный пароль. Попробуйте еще раз.")
                }
            }
        }
    }
    
    private func showError(_ message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    private func showMainInterface() {
        let tabBarController = UITabBarController()
        
        let documentsVC = DocumentViewController()
        let documentsNav = UINavigationController(rootViewController: documentsVC)
        documentsNav.tabBarItem = UITabBarItem(title: "Файлы", image: UIImage(systemName: "doc.text"), tag: 0)

        let settingsVC = SettingsViewController()
        let settingsNav = UINavigationController(rootViewController: settingsVC)
        settingsNav.tabBarItem = UITabBarItem(title: "Настройки", image: UIImage(systemName: "gear"), tag: 1)

        tabBarController.viewControllers = [documentsNav, settingsNav]
        tabBarController.modalPresentationStyle = .fullScreen
        
        present(tabBarController, animated: true)
    }
}
