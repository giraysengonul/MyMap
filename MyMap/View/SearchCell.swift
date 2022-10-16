//
//  SearchCell.swift
//  MyMap
//
//  Created by hakkı can şengönül on 16.10.2022.
//

import UIKit
import MapKit
protocol SearchCellDelegate: AnyObject {
    func distanceFromUser(location: CLLocation)-> CLLocationDistance?
}
class SearchCell: UITableViewCell {
    // MARK: - Properties
    var mapItem: MKMapItem?{
        didSet{ configureCell() }
    }
    weak var delegate: SearchCellDelegate?
    private let dimension: CGFloat = 32
    private lazy var imageContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .mainPink
        locationImageView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(locationImageView)
        NSLayoutConstraint.activate([
            locationImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            locationImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            locationImageView.heightAnchor.constraint(equalToConstant: 20),
            locationImageView.widthAnchor.constraint(equalToConstant: 20)
        ])
        return view
    }()
    private let locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .mainPink
        imageView.image = #imageLiteral(resourceName: "baseline_location_on_white_24pt_3x")
        return imageView
    }()
    private let locationTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.text = "Coffee Shop"
        return label
    }()
    private let locationDistanceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .lightGray
        return label
    }()
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
// MARK: - Helpers
extension SearchCell{
    private func setup(){
        selectionStyle = .none
        //imageContainerView setup
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false
        imageContainerView.layer.cornerRadius = dimension / 2
        addSubview(imageContainerView)
        //locationTitleLabel setup
        locationTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(locationTitleLabel)
        //locationDistanceLabel setup
        locationDistanceLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(locationDistanceLabel)
    }
    private func layout(){
        //imageContainerView layout
        NSLayoutConstraint.activate([
            imageContainerView.heightAnchor.constraint(equalToConstant: dimension),
            imageContainerView.widthAnchor.constraint(equalToConstant: dimension),
            imageContainerView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageContainerView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8)
        ])
        //locationTitleLabel layout
        NSLayoutConstraint.activate([
            locationTitleLabel.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            locationTitleLabel.leadingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: 8)
        ])
        //locationDistanceLabel layout
        NSLayoutConstraint.activate([
            locationDistanceLabel.leadingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: 8),
            imageContainerView.bottomAnchor.constraint(equalTo: locationDistanceLabel.bottomAnchor,constant: -4)
        ])
    }
    private func configureCell(){
        locationTitleLabel.text = mapItem?.name
        let distanceFormatter = MKDistanceFormatter()
        distanceFormatter.unitStyle = .abbreviated
        guard let mapItemLocation = mapItem?.placemark.location else{ return }
        guard let distanceFromUser = delegate?.distanceFromUser(location: mapItemLocation) else { return }
        let distanceString = distanceFormatter.string(fromDistance: distanceFromUser)
        locationDistanceLabel.text = distanceString
    }
}
