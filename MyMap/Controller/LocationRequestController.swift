//
//  LocationRequestController.swift
//  MyMap
//
//  Created by hakkı can şengönül on 16.10.2022.
//

import UIKit
class LocationRequestController: UIViewController {
    // MARK: - Properties
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "blue-pin")
        return imageView
    }()
    private let allowLocationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        let attributedText = NSMutableAttributedString(string: "Allow Location\n", attributes: [.font: UIFont.boldSystemFont(ofSize: 24)])
        attributedText.append(NSAttributedString(string: "Please enable location services so that we can track your movements", attributes: [.font: UIFont.systemFont(ofSize: 16)]))
        label.attributedText = attributedText
        label.numberOfLines = 0
        return label
    }()
    private lazy var enableLocationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Enable Location", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(handleRequestLocation), for: .touchUpInside)
        return button
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
}
// MARK: - Helpers
extension LocationRequestController{
    private func style(){
        view.backgroundColor = .white
        //imageView style
        imageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(imageView)
        //allowLocationLabel style
        allowLocationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(allowLocationLabel)
        //enableLocationButton style
        enableLocationButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(enableLocationButton)
    }
    private func layout(){
        //imageView layout
        NSLayoutConstraint.activate([
            imageView.heightAnchor.constraint(equalToConstant: 200),
            imageView.widthAnchor.constraint(equalToConstant: 200),
            imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 140)
        ])
        //allowLocationLabel layout
        NSLayoutConstraint.activate([
            allowLocationLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 32),
            allowLocationLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            view.trailingAnchor.constraint(equalTo: allowLocationLabel.trailingAnchor, constant: 32)
        ])
        //enableLocationButton layout
        NSLayoutConstraint.activate([
            enableLocationButton.heightAnchor.constraint(equalToConstant: 50),
            enableLocationButton.topAnchor.constraint(equalTo: allowLocationLabel.bottomAnchor, constant: 24),
            enableLocationButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 32),
            view.trailingAnchor.constraint(equalTo: enableLocationButton.trailingAnchor, constant: 32)
        ])
    }
}
// MARK: - Selectors
extension LocationRequestController{
    @objc func handleRequestLocation(_ sender: UIButton){
    }
}
