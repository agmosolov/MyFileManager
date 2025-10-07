//
//  DetailsViewController.swift
//  MyFileManager
//
//  Created by Александр Мосолов on 07.10.2025.
//

import UIKit

class DetailsViewController: UIViewController {
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white

        if let image = image {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFit
            imageView.frame = view.bounds
            imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            view.addSubview(imageView)
        }
    }
}
