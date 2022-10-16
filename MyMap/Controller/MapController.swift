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
        mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        enableLocationService()
    }
    private func layout(){
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            view.trailingAnchor.constraint(equalTo: mapView.trailingAnchor),
            view.bottomAnchor.constraint(equalTo: mapView.bottomAnchor)
        ])
    }
    private func centerMapOnUserLocation(){
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
    }
}
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
