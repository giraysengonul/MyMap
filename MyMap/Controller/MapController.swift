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
    var route: MKRoute?
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
        centerMapOnUserLocation(shouldLoadAnnotations: true)
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
        mapView.delegate = self
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        enableLocationService()
        //searchInputView style
        searchInputView = SearchInputView()
        searchInputView.delegate = self
        searchInputView.mapController = self
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
    private func zoomToFit(selectedAnnotation: MKAnnotation?){
        if mapView.annotations.count == 0{ return }
        var topLeftCoordinate = CLLocationCoordinate2D(latitude: -90, longitude: 180)
        var bottomRightCoordinate = CLLocationCoordinate2D(latitude: 90, longitude: -180)
        if let selectedAnnotation = selectedAnnotation{
            for annotation in mapView.annotations{
                if let userAnno = annotation as? MKUserLocation{
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, userAnno.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, userAnno.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, userAnno.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, userAnno.coordinate.latitude)
                }
                if annotation.title == selectedAnnotation.title{
                    topLeftCoordinate.longitude = fmin(topLeftCoordinate.longitude, annotation.coordinate.longitude)
                    topLeftCoordinate.latitude = fmax(topLeftCoordinate.latitude, annotation.coordinate.latitude)
                    bottomRightCoordinate.longitude = fmax(bottomRightCoordinate.longitude, annotation.coordinate.longitude)
                    bottomRightCoordinate.latitude = fmin(bottomRightCoordinate.latitude, annotation.coordinate.latitude)
                }
            }
            var region = MKCoordinateRegion(center: CLLocationCoordinate2DMake(topLeftCoordinate.latitude - (topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 0.65, topLeftCoordinate.longitude + (bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 0.65), span: MKCoordinateSpan(latitudeDelta: fabs(topLeftCoordinate.latitude - bottomRightCoordinate.latitude) * 3.0, longitudeDelta: fabs(bottomRightCoordinate.longitude - topLeftCoordinate.longitude) * 3.0))
            region = mapView.regionThatFits(region)
            mapView.setRegion(region, animated: true)
        }
    }
    private func generatePolyline(forDestinationMapItem destinationMapItem: MKMapItem){
        let request = MKDirections.Request()
        request.source = MKMapItem.forCurrentLocation()
        request.destination = destinationMapItem
        request.transportType = .walking
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let response = response else{ return }
            self.route = response.routes[0]
            guard let polyline = self.route?.polyline else{ return }
            self.mapView.addOverlay(polyline)
        }
    }
    private func centerMapOnUserLocation(shouldLoadAnnotations: Bool){
        guard let coordinate = locationManager.location?.coordinate else { return }
        let coordinateRegion = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        mapView.setRegion(coordinateRegion, animated: true)
        if shouldLoadAnnotations{
            loadAnnotations(withSearchQuery: "Coffee Shops")
        }
    }
    private func searchBy(naturalLanguageQuery: String,region: MKCoordinateRegion, coordinate: CLLocationCoordinate2D, completion: @escaping(_ response: MKLocalSearch.Response?, _ error: NSError?)-> Void){
        let request = MKLocalSearch.Request()
        request.region = region
        request.naturalLanguageQuery = naturalLanguageQuery
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let response = response else{
                completion(nil,error! as NSError?)
                return
            }
            completion(response,nil)
        }
    }
    private func removeAnnotations(){
        mapView.annotations.forEach { annotation in
            if let annotation = annotation as? MKPointAnnotation {
                mapView.removeAnnotation(annotation)
            }
        }
    }
    private func loadAnnotations(withSearchQuery querry: String){
        guard let coordinate = locationManager.location?.coordinate else{ return }
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 2000, longitudinalMeters: 2000)
        searchBy(naturalLanguageQuery: querry, region: region, coordinate: coordinate) { response, error in
            response?.mapItems.forEach({ mapItem in
                let annotation = MKPointAnnotation()
                annotation.title = mapItem.name
                annotation.coordinate = mapItem.placemark.coordinate
                self.mapView.addAnnotation(annotation)
            })
            
            self.searchInputView.searchResults = response?.mapItems
        }
    }
}
// MARK: - MKMapViewDelegate
extension MapController: MKMapViewDelegate{
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let route = self.route{
            let polyline = route.polyline
            let lineRenderer = MKPolylineRenderer(overlay: polyline)
            lineRenderer.strokeColor = .mainBlue
            lineRenderer.lineWidth = 3
            return lineRenderer
        }
        return MKOverlayRenderer()
    }
}
// MARK: - SearchInputViewDelegate
extension MapController: SearchInputViewDelegate{
    func selectedAnnotation(withMapItem mapItem: MKMapItem) {
        mapView.annotations.forEach { annotation in
            if annotation.title == mapItem.name{
                self.mapView.selectAnnotation(annotation, animated: true)
                self.zoomToFit(selectedAnnotation: annotation)
            }
        }
    }
    func addPolyLine(forDestinationMapItem destinationMapItem: MKMapItem) {
        generatePolyline(forDestinationMapItem: destinationMapItem)
    }
    func handleSearch(withSearchText searchtext: String) {
        removeAnnotations()
        loadAnnotations(withSearchQuery : searchtext)
    }
    func animateCenterMapButton(expansionState: SearchInputView.ExpansionState, hideButton: Bool) {
        switch expansionState{
        case .NotExpanded:
            UIView.animate(withDuration: 0.25) {
                self.centerMapButton.frame.origin.y -= 250
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
        centerMapOnUserLocation(shouldLoadAnnotations: false)
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
// MARK: - SearchCellDelegate
extension MapController: SearchCellDelegate{
    func getDirections(forMapItem mapItem: MKMapItem) {
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeWalking])
    }
    
    func distanceFromUser(location: CLLocation) -> CLLocationDistance? {
        guard let userLocation = locationManager.location else { return nil }
        return userLocation.distance(from: location)
    }
}
