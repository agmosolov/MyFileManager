//
//  DocumentViewController.swift
//  MyFileManager
//
//  Created by Александр Мосолов on 07.10.2025.
//


import UIKit

class DocumentViewController: UITableViewController {

    var documents: [String] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Photos"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addPhoto))

        tableView.separatorStyle = .none
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        loadDocuments()
    }

    func loadDocuments() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            documents = try fileManager.contentsOfDirectory(atPath: documentsURL.path)
            
            let isAscending = UserDefaults.standard.bool(forKey: "isAscending")
            
            documents.sort {
                isAscending ? $0 < $1 : $0 > $1
            }
            
            tableView.reloadData()
        } catch {
            print("Ошибка при получении содержимого директории: \(error)")
        }
    }

    @objc func addPhoto() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return documents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)

        // Создаем или находим imageView
        let imageView: UIImageView
        if let existingImageView = cell.contentView.viewWithTag(1) as? UIImageView {
            imageView = existingImageView
        } else {
            imageView = UIImageView()
            imageView.tag = 1
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
            imageView.translatesAutoresizingMaskIntoConstraints = false
            cell.contentView.addSubview(imageView)

            // Устанавливаем ограничения для imageView
            NSLayoutConstraint.activate([
                imageView.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 10),
                imageView.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor),
                imageView.widthAnchor.constraint(equalToConstant: 50), // ширина изображения
                imageView.heightAnchor.constraint(equalToConstant: 50) // высота изображения
            ])
        }

        // Загружаем изображение
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(documents[indexPath.row])

        if let imageData = try? Data(contentsOf: fileURL),
           let image = UIImage(data: imageData) {
            imageView.image = image
        } else {
            imageView.image = nil
        }

        // Устанавливаем текст для textLabel
        cell.textLabel?.text = documents[indexPath.row]

        // Устанавливаем ограничения для textLabel, чтобы текст был рядом с изображением
        cell.textLabel?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            cell.textLabel!.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 10),
            cell.textLabel!.centerYAnchor.constraint(equalTo: cell.contentView.centerYAnchor)
        ])

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(documents[indexPath.row])
        
        if let imageData = try? Data(contentsOf: fileURL),
           let image = UIImage(data: imageData) {
            let detailsVC = DetailsViewController()
            detailsVC.image = image
            navigationController?.pushViewController(detailsVC, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent(documents[indexPath.row])

            do {
                try fileManager.removeItem(at: fileURL)
                documents.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            } catch {
                print("Ошибка при удалении файла: \(error)")
            }
        }
    }
    
    
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension DocumentViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        dismiss(animated: true)

        guard let image = info[.originalImage] as? UIImage else { return }
        guard let data = image.pngData() else { return }

        let alertController = UIAlertController(title: "Имя файла", message: "Введите имя для файла", preferredStyle: .alert)
        alertController.addTextField { textField in
            textField.placeholder = "Имя файла"
        }
        let saveAction = UIAlertAction(title: "Сохранить", style: .default) { [unowned self, alertController] _ in
            let textField = alertController.textFields![0]
            let fileName = (textField.text ?? UUID().uuidString) + ".png"

            let fileManager = FileManager.default
            let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
            let fileURL = documentsURL.appendingPathComponent(fileName)

            do {
                try data.write(to: fileURL)
                loadDocuments()
            } catch {
                print("Ошибка при сохранении файла: \(error)")
            }
        }
        alertController.addAction(saveAction)
        alertController.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alertController, animated: true)
    }
}
