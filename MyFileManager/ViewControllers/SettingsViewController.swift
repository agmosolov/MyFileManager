//
//  SettingsViewController.swift
//  MyFileManager
//
//  Created by Александр Мосолов on 07.10.2025.
//

import UIKit

class SettingsViewController: UITableViewController {

    enum Setting: Int, CaseIterable {
        case sorting
        case changePassword
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Настройки"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Setting.allCases.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let setting = Setting(rawValue: indexPath.row)!

        switch setting {
        case .sorting:
            cell.textLabel?.text = "Сортировка"
            let isAscending = UserDefaults.standard.bool(forKey: "isAscending")
            cell.accessoryType = isAscending ? .checkmark : .none
        case .changePassword:
            cell.textLabel?.text = "Изменить пароль"
        }

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let setting = Setting(rawValue: indexPath.row)!

        switch setting {
        case .sorting:
            toggleSorting()
        case .changePassword:
            presentPasswordCreation()
        }
    }

    private func toggleSorting() {
        let isAscending = UserDefaults.standard.bool(forKey: "isAscending")
        UserDefaults.standard.set(!isAscending, forKey: "isAscending")
        tableView.reloadData()
    }

    private func presentPasswordCreation() {
        let passwordVC = PasswordViewController()
        passwordVC.modalPresentationStyle = .fullScreen
        present(passwordVC, animated: true)
    }
}
