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

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        loadDocuments()
    }

    func loadDocuments() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        do {
            documents = try fileManager.contentsOfDirectory(atPath: documentsURL.path)
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

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(documents[indexPath.row])
        
        if let imageData = try? Data(contentsOf: fileURL),
           let image = UIImage(data: imageData) {
            cell.imageView?.image = image
            cell.textLabel?.text = nil
        } else {
            cell.textLabel?.text = "Не удалось загрузить изображение"
            cell.imageView?.image = nil
        }

        return cell
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

        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let filename = UUID().uuidString + ".png"
        let fileURL = documentsURL.appendingPathComponent(filename)

        do {
            try data.write(to: fileURL)
            loadDocuments()
        } catch {
            print("Ошибка при сохранении файла: \(error)")
        }
    }
}
