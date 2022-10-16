//
//  MapController.swift
//  MyMap
//
//  Created by hakkı can şengönül on 16.10.2022.
//

import UIKit
import MapKit
import CoreLocation
class MapController: UIViewController {
    // MARK: - Properties
    var mapView: MKMapView!
    var locationManager: CLLocationManager!
    var searchInputView: SearchInputView!
    private lazy var centerMapButton: UIButton = {
        let button = UIButton(type: .system)
        let image = #imageLiteral(resourceName: "location-arrow-flat")
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleCenterLocation), for: .touchUpInside)
        return button
    }()
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        style()
        layout()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        centerMapOnUserLocation()
    }
}
// MARK: - Helpers
extension MapController{
    private func style(){
        view.backgroundColor = .white
        //mapView style
        mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        enableLocationService()
        //searchInputView style
        searchInputView = SearchInputView()
        searchInputView.delegate = self
        searchInputView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(searchInputView)
        //centerMapButton style
        centerMapButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(centerMapButton)
    }
    private func layout(){
        //mapView layout
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: mapView.bottomAnchor)
        ])
        //searchInputView layout
        NSLayoutConstraint.activate([
            searchInputView.heightAnchor.constraint(equalToConstant: view.frame.height),
            view.bottomAnchor.constraint(equalTo: searchInputView.bottomAnchor, constant: -(view.frame.height - 88)),
            searchInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: searchInputView.trailingAnchor)
        ])
        //centerMapButton layout
        NSLayoutConstraint.activate([
            centerMapButton.widthAnchor.constraint(equalToConstant: 50),
            centerMapButton.heightAnchor.constraint(equalToConstant: 50),
            searchInputView.topAnchor.constraint(equalTo: centerMapButton.bottomAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: centerMapButton.trailingAnchor, constant: 16)
            
        ])
    }
    private func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
// MARK: - SearchInputViewDelegate
extension MapController: SearchInputViewDelegate{
    func animateCenterMapButton(expansionState: SearchInputView.ExpansionState, hideButton: Bool) {
        switch expansionState{
        case .NotExpanded:
            UIView.animate(withDuration: 0.25) {
                self.centerMapButton.frame.origin.y -= 270
            }
            if hideButton{
                self.centerMapButton.alpha = 0
            }else{
                self.centerMapButton.alpha = 1
            }
        case .PartiallyExpanded:
            if hideButton{
                self.centerMapButton.alpha = 0
            }else{
                UIView.animate(withDuration: 0.25) {
                    self.centerMapButton.frame.origin.y += 260
                }
            }
        case .FullyExpanded:
            UIView.animate(withDuration: 0.25) {
                self.centerMapButton.alpha = 1
            }
        }
    }
}
// MARK: - Selectors
extension MapController{
    @objc func handleCenterLocation(_ sender: UIButton){
        centerMapOnUserLocation()
    }
}
// MARK: - CLLocationManagerDelegate
extension MapController: CLLocationManagerDelegate{
    func enableLocationService(){
        locationManager = CLLocationManager()
        locationManager.delegate = self
        switch locationManager.authorizationStatus{
        case .notDetermined:
            print("notDetermined")
            DispatchQueue.main.async {
                let controller = LocationRequestController()
                controller.locationmanager = self.locationManager
                controller.modalPresentationStyle = .fullScreen
                self.present(controller, animated: true)
            }
        case .restricted:
            print("restricted")
        case .denied:
            print("denied")
        case .authorizedAlways:
            print("authorizedAlways")
        case .authorizedWhenInUse:
            print("authorizedWhenInUse")
        @unknown default:
            print("notDetermined")
        }
    }
}
