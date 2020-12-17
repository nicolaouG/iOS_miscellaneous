//
//  DemoMapsViewController.swift
//  DemoNavigationProject
//
//  Created by george on 22/05/2020.
//  Copyright © 2020 George Nicolaou. All rights reserved.
//

import UIKit
import SnapKit
import MapKit
import GoogleMaps       /// pod 'GoogleMaps'
import GoogleMapsUtils  /// pod 'Google-Maps-iOS-Utils'
import FontAwesome_swift

/**
 Notes:
 - https://sites.google.com/site/gmapsdevelopment/
 - Google maps directions API requires billing info
 */

/**
 Show directions in AppleMaps if available or in GoogleMaps as a fallback
 
 Google maps requires:
 <key>LSApplicationQueriesSchemes</key>
 <array>
     <string>comgooglemaps</string>
     <string>googlechromes</string>
 </array>

 */

class DemoMapsViewController: UIViewController {
    let googleMapsApiKey = "AIzaSyAWBgXHE2fFarBBNHUMd61OKWbfp0JqZvc"///"AIzaSyDZ622DW-3n3Ca3di4GdyYbMKv2D-CrHEQ"
    var currentLocation: CLLocation?
    let appleMapsAnnotId = "MerchantAnnotation"
        
    var dummyDestinationsUS: [CLLocation] = {
        let pos1 = CLLocation(latitude: 37.734804, longitude: -122.502779)
        let pos2 = CLLocation(latitude: 37.762123, longitude: -122.435672)
        let pos3 = CLLocation(latitude: 37.808334, longitude: -122.440480)
        return [pos1, pos2, pos3]
    }()
    
    var dummyDestinationsCY: [CLLocation] = {
        let pos1 = CLLocation(latitude: 34.8601073, longitude: 32.4550152)
        let pos2 = CLLocation(latitude: 34.88275, longitude: 32.4819)
        let pos3 = CLLocation(latitude: 34.9125401, longitude: 32.4257815)
        let pos4 = CLLocation(latitude: 34.9361563, longitude: 32.4072286)
        let pos5 = CLLocation(latitude: 34.95636, longitude: 32.39297)
        let pos6 = CLLocation(latitude: 35.0056242, longitude: 32.4046299)
        let pos7 = CLLocation(latitude: 34.9556729, longitude: 32.4222236)
        let pos8 = CLLocation(latitude: 34.9816269, longitude: 32.4546969)
        let pos9 = CLLocation(latitude: 34.9808601, longitude: 32.4492174)
        let pos10 = CLLocation(latitude: 35.0368445, longitude: 32.4239366)
        let pos11 = CLLocation(latitude: 34.939907, longitude: 32.4617291)
        let pos12 = CLLocation(latitude: 34.9246399, longitude: 32.473288)
        let pos13 = CLLocation(latitude: 34.9427168, longitude: 32.4454359)
        return [pos1, pos2, pos3, pos4, pos5, pos6, pos7, pos8, pos9, pos10, pos11, pos12, pos13]
    }()
        
    var googleMapsMarkers: [GMSMarker] = []
    var googleMapsPolylines: [GMSPolyline] = []

    lazy var googleMapsView: GMSMapView = {
        let m = GMSMapView()
        m.settings.compassButton = true
        m.settings.myLocationButton = true
        m.settings.indoorPicker = true /// floors
        m.delegate = self
        /// push compass down and location up
        m.padding.top = buttonsStack.frame.maxY - (navigationController?.navigationBar.frame.maxY ?? 0)
        if #available(iOS 13.0, *), self.traitCollection.userInterfaceStyle == .dark {
            do {
                m.mapStyle = try GMSMapStyle(jsonString: GoogleMapsStyle.night.json())
            } catch {
              NSLog("One or more of the map styles failed to load. \(error)")
            }
        } else {
            do {
                m.mapStyle = try GMSMapStyle(jsonString: GoogleMapsStyle.standard.json())
            } catch {
              NSLog("One or more of the map styles failed to load. \(error)")
            }
        }
        return m
    }()
 
    lazy var clusterManager: GMUClusterManager = {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(mapView: googleMapsView, clusterIconGenerator: iconGenerator)
        renderer.delegate = self
        let m = GMUClusterManager(map: googleMapsView, algorithm: algorithm, renderer: renderer)
        m.setDelegate(self, mapDelegate: self)
        return m
    }()
    
    lazy var appleMapsView: MKMapView = {
        let m = MKMapView()
        m.delegate = self
        m.showsScale = false
        m.showsUserLocation = true
        m.pointOfInterestFilter = .includingAll
        m.showsBuildings = true
        m.showsCompass = false
        return m
    }()
    
    lazy var locationManager: CLLocationManager = {
        let m = CLLocationManager()
        m.delegate = self
        m.desiredAccuracy = kCLLocationAccuracyBest //kCLLocationAccuracyHundredMeters
        return m
    }()
    
    lazy var mapTypeSegment: UISegmentedControl = {
        let s = UISegmentedControl(items: ["Standard", "Satellite"])
        s.selectedSegmentIndex = 0
        s.addTarget(self, action: #selector(mapTypeChanged), for: .valueChanged)
        if #available(iOS 13.0, *) {
            s.selectedSegmentTintColor = .systemBlue
            s.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .normal)
        } else {
            s.backgroundColor = .white
            s.tintColor = .systemBlue
        }
        return s
    }()
    
    lazy var buttonsStack: UIStackView = {
        let s = UIStackView()
        s.axis = .vertical
        s.distribution = .equalSpacing
        s.alignment = .fill
        return s
    }()
    
    lazy var closeButton: UIButton = {
        let b = UIButton(type: .system)
        let image = UIImage.fontAwesomeIcon(name: .timesCircle, style: .solid, textColor: .systemBlue, size: CGSize(width: 30, height: 30))
        b.tintColor = .systemBlue
        b.clipsToBounds = true
        b.setImage(image, for: .normal)
        b.addTarget(self, action: #selector(closeButtonClicked), for: .touchUpInside)
        return b
    }()
    
    lazy var locationButton: UIButton = {
        let b = UIButton(type: .system)
        let image = UIImage.fontAwesomeIcon(name: .locationArrow, style: .solid, textColor: .systemBlue, size: CGSize(width: 34, height: 34))
        b.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        b.tintColor = .systemBlue
        b.setImage(image, for: .normal)
        b.clipsToBounds = true
        b.roundCorners(.top, radius: 6)
        b.addTarget(self, action: #selector(locationButtonClicked), for: .touchUpInside)
        return b
    }()
    
    lazy var directionsButton: CustomActivityButton = {
        let b = CustomActivityButton()
        b.backgroundColor = .clear
        let image = UIImage.fontAwesomeIcon(name: .directions, style: .solid, textColor: .systemBlue, size: CGSize(width: 36, height: 36))
        let image2 = UIImage.fontAwesomeIcon(name: .stopCircle, style: .solid, textColor: .systemBlue, size: CGSize(width: 36, height: 36))
        b.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        b.tintColor = .systemBlue
        b.setImage(image, for: .normal)
        b.setImage(image2, for: .selected)
        b.clipsToBounds = true
        b.roundCorners(.bottom, radius: 6)
        b.addTarget(self, action: #selector(directionsMenuButtonClicked), for: .touchUpInside)
        b.isSelected = false
        b.tag = 0
        return b
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeVariables()
        configureUI()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        /// for the google maps style
        guard #available(iOS 13.0, *),
            traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection),
            appleMapsView.isHidden else { return }
                let style: GoogleMapsStyle = traitCollection.userInterfaceStyle == .dark ? .night : .standard
                changeGoogleMapsStyle(to: style)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if currentLocation != nil {
            activateLocationServices()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if currentLocation != nil {
            stopLocationServices()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    
    func initializeVariables() {
        checkLocationPermission()
    }
    
    func configureUI() {
        view.addSubview(appleMapsView)
        view.addSubview(mapTypeSegment)
        view.addSubview(buttonsStack)
        
        let stackSeparatorView = UIView()
        stackSeparatorView.backgroundColor = locationButton.backgroundColor
        stackSeparatorView.snp.makeConstraints({ make in
            make.width.equalTo(36)
            make.height.equalTo(13)
        })
        
        let line = UIView()
        line.backgroundColor = .systemBlue
        stackSeparatorView.addSubview(line)
        line.snp.makeConstraints({ make in
            make.centerY.equalToSuperview()
            make.width.equalTo(36)
            make.height.equalTo(1)
        })
        
        buttonsStack.addArrangedSubview(locationButton)
        buttonsStack.addArrangedSubview(stackSeparatorView)
        buttonsStack.addArrangedSubview(directionsButton)
        
        let isSmallScreen = UIScreen.main.bounds.width <= 320
        let navbarHeight = navigationController?.navigationBar.frame.height ?? 0
        let statusbarHeight = navbarHeight == 0 ? 0 : view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        
        mapTypeSegment.snp.makeConstraints({ make in
            make.centerX.equalToSuperview()
            if isSmallScreen {
                make.width.equalToSuperview().multipliedBy(0.6)
            } else {
                make.width.equalToSuperview().multipliedBy(0.7)
            }
            make.top.equalToSuperview().offset(navbarHeight + statusbarHeight + 16)
        })
        appleMapsView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
        buttonsStack.snp.makeConstraints({ make in
            make.top.equalTo(mapTypeSegment.snp.bottom).offset(24)
            make.right.equalToSuperview().offset(-20)
        })
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            /// wait for the navBar / tabBar to load (if any)
            if self.isModal {
                self.addCloseButton()
            }
        }
    }
    
    func addCloseButton() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints({ make in
            make.top.height.equalTo(mapTypeSegment)
            make.right.equalToSuperview().offset(-20)
            make.width.equalTo(closeButton.snp.height)
        })
    }
    
    func changeGoogleMapsStyle(to style: GoogleMapsStyle) {
        do {
            googleMapsView.mapStyle = try GMSMapStyle(jsonString: style.json())
        } catch {
            NSLog("Map style failed to load. \(error)")
        }
    }
    
    @objc func mapTypeChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            if appleMapsView.isHidden {
                googleMapsView.mapType = .normal
            } else {
                appleMapsView.mapType = .standard
            }
        case 1:
            if appleMapsView.isHidden {
                googleMapsView.mapType = .satellite
            } else {
                appleMapsView.mapType = .satellite
            }
        default:
            break
        }
    }
    
    @objc func directionsMenuButtonClicked() {
        guard !dummyDestinationsCY.isEmpty else {
            print("Nowhere to navigate")
            return
        }

        if directionsButton.isSelected {
            navigateInApp() /// to stop directions
        } else {
            promptMapsAppSelection()
        }
    }
    
    @objc func locationButtonClicked() {
        if let location = currentLocation {
            centerMapOnUserLocation(lastLocation: location)
        } else {
            print("Current location is unknown. Check GPS signal or location permission in settings.")
        }
    }
    
    @objc func closeButtonClicked() {
        dismiss(animated: true, completion: nil)
    }
}


// MARK: - Location delegate

extension DemoMapsViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse || status == .authorizedAlways {
            activateLocationServices()
        } else {
            guard status != .notDetermined else { return } // default alert should appear
            showDeniedRestrictedAlert()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locations.isEmpty,
            let lastLocation = locations.last else { return }
        
        if currentLocation == nil {
            centerMapOnUserLocation(lastLocation: lastLocation)
        }
        
        currentLocation = lastLocation
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
    }
    
    
    func activateLocationServices() {
        locationManager.startUpdatingLocation()
    }
    
    func stopLocationServices() {
        locationManager.stopUpdatingLocation()
    }
    
    func checkLocationPermission() {
        if CLLocationManager.authorizationStatus() == .authorizedAlways || CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            activateLocationServices()
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func centerMapOnUserLocation(lastLocation: CLLocation) {
        if appleMapsView.isHidden {
            guard let coords = currentLocation?.coordinate else { return }
            googleMapsView.camera = GMSCameraPosition.camera(withTarget: coords, zoom: 13)
        } else {
            let coordinateRegion = MKCoordinateRegion(center: lastLocation.coordinate, latitudinalMeters: 2500, longitudinalMeters: 2500)
            appleMapsView.setRegion(coordinateRegion, animated: true)
        }
    }
    
    func showDeniedRestrictedAlert(){
        let alert = UIAlertController(title: NSLocalizedString("Location permission denied or restricted", comment: ""), message: NSLocalizedString("Enable access manually from settings", comment: ""), preferredStyle: .alert)
        alert.addAction(UIAlertAction.init(title: "OK", style: UIAlertAction.Style.cancel, handler: { _ in
            self.dismiss(animated: true, completion: nil) }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("Settings", comment: ""), style: UIAlertAction.Style.default, handler: { _ in
            self.goToSettings() }))
        present(alert, animated: true, completion: nil)
    }
    
    func goToSettings(){
        guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else { return }
        if UIApplication.shared.canOpenURL(settingsUrl) {
            UIApplication.shared.open(settingsUrl, completionHandler: nil)
        }
    }
}


// MARK: - Apple maps delegate

extension DemoMapsViewController: MKMapViewDelegate {
    func mapViewDidFailLoadingMap(_ mapView: MKMapView, withError error: Error) {
        print(error.localizedDescription)
    }
    
    func mapView(_ mapView: MKMapView, didFailToLocateUserWithError error: Error) {
        print(error.localizedDescription)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {}
    
    func mapViewWillStartRenderingMap(_ mapView: MKMapView) {}
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        /// for map directions
        if overlay is MKPolyline {
            let polyline = MKPolylineRenderer(overlay: overlay)
            polyline.strokeColor = .systemBlue
            polyline.lineWidth = 6
            return polyline
        }
        return MKOverlayRenderer()
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        addAppleMapsPOIMarkers(in: dummyDestinationsCY)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: appleMapsAnnotId)
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: appleMapsAnnotId)
        } else {
            annotationView?.annotation = annotation
        }
        
        annotationView?.canShowCallout = true
        annotationView?.image = #imageLiteral(resourceName: "marker_wht-circle").resizedImageWithinRect(rectSize: CGSize(width: 36, height: 36))
        annotationView?.centerOffset = CGPoint(x: 0, y: -18)
//        annotationView?.image = UIImage.fontAwesomeIcon(name: .mapMarkerAlt, style: .solid, textColor: MainApp.shared().theme.mainColor, size: CGSize(width: 36, height: 40))
//        annotationView?.centerOffset = CGPoint(x: 0, y: -20)
        return annotationView
    }
    
    func provideAppleMapsDirections(_ positions: [CLLocation]) {
        /// make the directions and prepare the markers
        var directions: [MKDirections] = []
        var markers: [MKAnnotation] = []
        
        for (i, pos) in positions.enumerated() {
            /// directions
            if i > 0 {
                let pos1 = MKMapItem(placemark: MKPlacemark(coordinate: positions[i-1].coordinate))
                let pos2 = MKMapItem(placemark: MKPlacemark(coordinate: pos.coordinate))
                
                let request = MKDirections.Request()
                request.source = pos1
                request.destination = pos2
                request.requestsAlternateRoutes = false
                request.transportType = .automobile
                
                let direction = MKDirections(request: request)
                directions.append(direction)
            }
            
            /// markers
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: pos.coordinate.latitude, longitude: pos.coordinate.longitude)
            pin.title = "stop \(i)"
            pin.subtitle = "merchant \(i)"
            
            let pinView = MKPinAnnotationView(annotation: pin, reuseIdentifier: appleMapsAnnotId)
            guard let annotation = pinView.annotation else { continue }
            markers.append(annotation)
        }
        
        var failedDirections = 0
        
        /// populate the map
        directions.forEach { (direction) in
            direction.calculate { [weak self] (response, error) in
                if direction == directions.last {
                    self?.directionsButton.stopLoading()
                }
                                
                if let error = error {
                    print(error.localizedDescription)
                    failedDirections += 1
                    /// if all failed
                    if failedDirections >= directions.count {
                        self?.askForDirectionsInGoogleMaps(positions)
                    }

//                    if (error as? MKError)?.errorCode == 2 { /// no directions found
//                        self?.askForDirectionsInGoogleMaps(positions)
//                    }
                } else {
                    /// add the marker annotations once (see delegate for more info)
//                    if direction == directions.first {
//                        self?.appleMapsView.removeAnnotations(self?.appleMapsView.annotations ?? [])
//                        self?.appleMapsView.addAnnotations(markers)
//                    }

                    /// add route
                    if let route = response?.routes.first {
                        self?.appleMapsView.addOverlays([route.polyline], level: .aboveRoads) /// needs renderer (see delegate)
                        if direction == directions.first {
                            self?.appleMapsView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func addAppleMapsPOIMarkers(in positions: [CLLocation]) {
        guard appleMapsView.annotations.isEmpty || (appleMapsView.annotations.count == 1 && appleMapsView.annotations.first is MKUserLocation) else { return } /// add them once
        
        for (i, pos) in positions.enumerated() {
            let pin = MKPointAnnotation()
            pin.coordinate = CLLocationCoordinate2D(latitude: pos.coordinate.latitude, longitude: pos.coordinate.longitude)
            pin.title = "stop \(i)"
            pin.subtitle = "merchant \(i)"
            
            let pinView = MKPinAnnotationView(annotation: pin, reuseIdentifier: appleMapsAnnotId)
            guard let annotation = pinView.annotation else { continue }
            appleMapsView.addAnnotation(annotation)
        }
    }
}


// MARK: - Google maps delegate

extension DemoMapsViewController: GMSMapViewDelegate {
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        locationButtonClicked()
        return true
    }
    
    func googleMapsSDKSetup() {
        GMSServices.provideAPIKey(googleMapsApiKey)
    }
    
    func askForDirectionsInGoogleMaps(_ positions: [CLLocation]) {
        let alert = UIAlertController(title: "Apple Maps issue", message: NSLocalizedString("Directions are not available from this location.", comment: ""), preferredStyle: .alert)
        let gm = UIAlertAction(title: NSLocalizedString("Show in Google Maps", comment: ""), style: .default) { _ in
            self.googleMapsSDKSetup()
            self.addGoogleMapsView()
            self.provideGoogleMapsDirections(positions)
        }
        let cancel = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
            self.navigateInApp() /// toggle directions
        }
        alert.addAction(gm)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func addGoogleMapsView() {
        guard !view.subviews.contains(googleMapsView) else { return }
        view.insertSubview(googleMapsView, aboveSubview: appleMapsView)
        appleMapsView.isHidden = true
        
        buttonsStack.subviews.forEach {
            if $0 != directionsButton {
                $0.removeFromSuperview()
            }
        }
        directionsButton.roundCorners(UIView.Corners.all, radius: 6)
        
        googleMapsView.isMyLocationEnabled = true
        googleMapsView.snp.makeConstraints({ make in
            make.edges.equalToSuperview()
        })
    }
 
    func centerAndZoomIn(_ positions: [CLLocation]) {
        var bounds = GMSCoordinateBounds()
        positions.forEach { (pos) in
            bounds = bounds.includingCoordinate(pos.coordinate)
        }

        let camera = GMSCameraUpdate.fit(bounds, with: UIEdgeInsets(top: 50, left: 40, bottom: 40, right: 40))
        googleMapsView.animate(with: camera)
    }
    
    func provideGoogleMapsDirections(_ positions: [CLLocation]) {
        self.directionsButton.stopLoading()
        guard let pos1 = positions.first else { return }
        googleMapsView.camera = GMSCameraPosition.camera(withTarget: pos1.coordinate, zoom: 12)
        // centerAndZoomIn(positions)
     
        var totalMarkers = positions.count
        let pathVertices = GMSMutablePath()
        var stops: String = ""
        
        for (i, pos) in positions.enumerated() {
            let coord = pos.coordinate
            
            /// add the paths
            pathVertices.add(coord)
            
            /// intermediate positions as waypoints
            if pos != positions.first && pos != positions.last {
                let separator = stops.isEmpty ? "" : "|"
                stops.append("\(separator)via:\(coord.latitude),\(coord.longitude)")
            }

            /// add the markers (skip the 1st one if it is the user location)
            if i == 0 && directionsButton.tag != 0 {
                continue
            }
            /// continue if markers already added
            if googleMapsMarkers.count >= totalMarkers {
                totalMarkers -= 1
                continue
            }

            let marker = GMSMarker()
            marker.position = CLLocationCoordinate2D(latitude: coord.latitude, longitude: coord.longitude)
            marker.title = "stop \(i)"
            marker.snippet = "merchant \(i)"
            if i < 4 {
                marker.icon = GMSMarker.markerImage(with: .black)
            } else {
                let img = #imageLiteral(resourceName: "marker_wht-circle").resizedImageWithinRect(rectSize: CGSize(width: 36, height: 36))
                marker.iconView = UIImageView(image: img)
            }
            marker.appearAnimation = .pop
            marker.map = googleMapsView
            googleMapsMarkers.append(marker)
        }
        
        /// add the previously calculated polylines
        if !googleMapsPolylines.isEmpty {
            googleMapsPolylines.forEach({ $0.map = googleMapsView })
            return
        }

        /// multicolor polyline
        let colors: [UIColor] = Array(repeating: UIColor.white, count: positions.count)
        for i in 0..<positions.count {
            if i != 0 {
                let path = GMSMutablePath()
                path.add(positions[i-1].coordinate)
                path.add(positions[i].coordinate)
                let polyline = GMSPolyline(path: path)
                polyline.strokeWidth = 6
                polyline.zIndex = 5
                polyline.strokeColor = colors[i-1]
                polyline.geodesic = true
                polyline.map = googleMapsView
                googleMapsPolylines.append(polyline)
             
                /// to appear like it has a border
                if colors[i-1] == .white {
                    let path = GMSMutablePath()
                    path.add(positions[i-1].coordinate)
                    path.add(positions[i].coordinate)
                    let polyline = GMSPolyline(path: path)
                    polyline.strokeWidth = 7
                    polyline.zIndex = 4
                    polyline.strokeColor = UIColor.black.withAlphaComponent(0.8)
                    polyline.geodesic = true
                    polyline.map = googleMapsView
                    googleMapsPolylines.append(polyline)
                }
            }
        }
        
        /*
         /// draw polyline
         let blue = GMSStrokeStyle.gradient(from: MainApp.shared().theme.mainColor, to: .systemBlue)
         let polyline = GMSPolyline(path: pathVertices)
         polyline.strokeWidth = 6
         //polyline.strokeColor = MainApp.shared().theme.mainColor
         polyline.spans = [GMSStyleSpan(style: blue)]
         polyline.geodesic = true
         polyline.map = googleMapsView
         */
        /*
         /// draw route (* requires billing for 'Directions API')
         guard positions.count > 2,
         let firstPos = positions.first,
         let lastPos = positions.last else { return }
         
         let outputFormat = "json"
         let origin = "origin=\(firstPos.coordinate.latitude),\(firstPos.coordinate.longitude)"
         let destination = "&destination=\(lastPos.coordinate.latitude),\(lastPos.coordinate.longitude)"
         let waypoints = "&waypoints=\(stops)"
         let mode = "&mode=driving"
         let urlStr = "https://maps.googleapis.com/maps/api/directions/\(outputFormat)?\(origin)\(destination)\(waypoints)\(mode)&key=\(googleMapsApiKey)"
         
         guard let url = URL(string: urlStr) else { return }
         let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
         DispatchQueue.main.async {
         self.directionsButton.stopLoading()
         if let err = error {
         showAlert(.error, err.localizedDescription, .bottom)
         } else if let data = data {
         do {
         let googleMapsResponse = try JSONDecoder().decode(GoogleMapsResponse.self, from: data)
         
         switch googleMapsResponse.status {
         case StatusCode.NOT_FOUND.rawValue:
         showAlert(.error, StatusCode.NOT_FOUND.error(), .bottom)
         case StatusCode.ZERO_RESULTS.rawValue:
         showAlert(.error, StatusCode.ZERO_RESULTS.error(), .bottom)
         case StatusCode.MAX_WAYPOINTS_EXCEEDED.rawValue:
         showAlert(.error, StatusCode.MAX_WAYPOINTS_EXCEEDED.error(), .bottom)
         case StatusCode.MAX_ROUTE_LENGTH_EXCEEDED.rawValue:
         showAlert(.error, StatusCode.MAX_ROUTE_LENGTH_EXCEEDED.error(), .bottom)
         case StatusCode.INVALID_REQUEST.rawValue:
         showAlert(.error, StatusCode.INVALID_REQUEST.error(), .bottom)
         case StatusCode.OVER_DAILY_LIMIT.rawValue:
         showAlert(.error, StatusCode.OVER_DAILY_LIMIT.error(), .bottom)
         default: break
         }
         
         googleMapsResponse.routes.forEach { (route) in
         let polyline = route.overviewPolyline
         let points = polyline.points
         let path = GMSPath(fromEncodedPath: points)
         let style = GMSStrokeStyle.gradient(from: MainApp.shared().theme.mainColor, to: .systemBlue)
         let pathPolyline = GMSPolyline(path: path)
         pathPolyline.strokeWidth = 6
         pathPolyline.spans = [GMSStyleSpan(style: style)]
         pathPolyline.geodesic = true
         pathPolyline.map = self.googleMapsView
         }
         
         } catch(let err2) {
         showAlert(.error, err2.localizedDescription, .bottom)
         }
         }
         }
         }
         task.resume()
         */
    }
}





// MARK: - GMUClusterManagerDelegate

extension DemoMapsViewController: GMUClusterManagerDelegate {
    func clusterManager(_ clusterManager: GMUClusterManager, didTap cluster: GMUCluster) -> Bool {
        let newCamera = GMSCameraPosition.camera(withTarget: cluster.position,
          zoom: googleMapsView.camera.zoom + 1)
        let update = GMSCameraUpdate.setCamera(newCamera)
        googleMapsView.moveCamera(update)
        return false
    }
    
    func clusterManager(_ clusterManager: GMUClusterManager, didTap clusterItem: GMUClusterItem) -> Bool {
        return false
    }
 
 
    func clusterMarkers(_ positions: [CLLocation]) {
        for i in 0..<positions.count {
            guard googleMapsMarkers.count > i else { return }
            let item = POIItem(marker: googleMapsMarkers[i])
            clusterManager.add(item)
        }
    }
}

// MARK: - GMUClusterRendererDelegate

extension DemoMapsViewController: GMUClusterRendererDelegate {
    func renderer(_ renderer: GMUClusterRenderer, markerFor object: Any) -> GMSMarker? {
        if let cluster = (object as? GMUStaticCluster) {
            // do something with the cluster marker
        } else if let poi = (object as? POIItem) {
            // return custom marker (with color, snippet etc)
            return poi.marker
        }
        return nil
    }
}



/// Point of Interest Item which implements the GMUClusterItem protocol.
class POIItem: NSObject, GMUClusterItem {
    var position: CLLocationCoordinate2D
    var marker: GMSMarker
    
    init(marker: GMSMarker) {
        self.marker = marker
        self.position = marker.position
    }
}







// MARK: - Open external app

/**
 modify plist 'LSApplicationQueriesSchemes'
 
 <key>LSApplicationQueriesSchemes</key>
 <array>
     <string>comgooglemaps</string>
     <string>waze</string>
     <string>dgis</string>
     <string>com.sygic.aura</string>
 </array>
 
 */

extension DemoMapsViewController {
    func promptMapsAppSelection() {
        self.directionsButton.stopLoading()
        var installedNavigationApps : [String] = ["Stay in app", "Apple Maps"] // always available
        
        if let googleMapsUrl = URL(string: "comgooglemaps://"), UIApplication.shared.canOpenURL(googleMapsUrl) {
            installedNavigationApps.append("Google Maps")
        }
        if let wazeMapsUrl = URL(string: "waze://"), UIApplication.shared.canOpenURL(wazeMapsUrl) {
            installedNavigationApps.append("Waze")
        }
        if let dgisMapsUrl = URL(string: "dgis://"), UIApplication.shared.canOpenURL(dgisMapsUrl) {
            installedNavigationApps.append("2GIS")
        }
        if let sygicMapsUrl = URL(string: "com.sygic.aura://"), UIApplication.shared.canOpenURL(sygicMapsUrl) {
            installedNavigationApps.append("Sygic")
        }
     
        /*
        /// not for Cyprus
        if let navigonMapsUrl = URL(string: "navigon://"), UIApplication.shared.canOpenURL(navigonMapsUrl) {
            installedNavigationApps.append("Navigon")
        }
        */
        
        let alert = UIAlertController(title: "Open in", message: nil, preferredStyle: .actionSheet)
        for app in installedNavigationApps {
            let button = UIAlertAction(title: app, style: .default) { (action) in
                let destination = self.dummyDestinationsCY.last?.coordinate ?? CLLocationCoordinate2D(latitude: 0, longitude: 0)
                
                switch app {
                case "Stay in app":
                    self.navigateInApp()
                case "Apple Maps":
                    self.openMapsToNavigate(to: destination)
                case "Google Maps":
                    self.openGoogleMapsToNavigate(to: destination)
                case "Waze":
                    self.openWazeToNavigate(to: destination)
                case "2GIS":
                    self.open2gisToNavigate(to: destination)
                case "Sygic":
                    self.openSygicToNavigate()
                /*
                case "Navigon": // not for Cyprus
                    self.openNavigonToNavigate()
                */
                default:
                    break
                }
            }
            alert.addAction(button)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (action) in }
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    func openSygicToNavigate(to coord: CLLocationCoordinate2D) {
        let lat = coord.latitude
        let lon = coord.longitude

        // '%7C' is '|' in ascii hex
        guard let sygicUrl = URL(string: "com.sygic.aura://coordinate%7C\(lon)%7C\(lat)%7Cshow") else {
            print("Navigation in Sygic failed")
            return
        }
        UIApplication.shared.open(sygicUrl, options: [:], completionHandler: nil)
    }
    
    func open2gisToNavigate(to coord: CLLocationCoordinate2D) {
        let lat = coord.latitude
        let lon = coord.longitude
        var baseUrlString = "dgis://2gis.cy/routeSearch/rsType/car/from/"

        if let userLoc = currentLocation?.coordinate {
            baseUrlString.append("\(userLoc.longitude),\(userLoc.latitude)/")
        }
        
        baseUrlString.append("to/\(lon),\(lat)")
        guard let dgisUrl = URL(string: baseUrlString) else {
            print("Navigation in 2GIS failed")
            return
        }
        UIApplication.shared.open(dgisUrl, options: [:], completionHandler: nil)
    }
    
    func openNavigonToNavigate(to coord: CLLocationCoordinate2D) {
        let lat = coord.latitude
        let lon = coord.longitude

        guard let navigonUrl = URL(string: "navigon://coordinate/\(title ?? "My destination")/\(lon),\(lat)") else {
            print("Navigation in Navigon failed")
            return
        }
        UIApplication.shared.open(navigonUrl, options: [:], completionHandler: nil)
    }
    
    func openWazeToNavigate(to coord: CLLocationCoordinate2D) {
        let lat = coord.latitude
        let lon = coord.longitude

        guard let wazeUrl = URL(string: "https://waze.com/ul?ll=\(lat),\(lon)&navigate=yes") else {
            print("Navigation in Waze failed")
            return
        }
        UIApplication.shared.open(wazeUrl, options: [:], completionHandler: nil)
    }
    
    func openGoogleMapsToNavigate(to coord: CLLocationCoordinate2D) {
        let lat = coord.latitude
        let lon = coord.longitude
        var googleMapsUrlStr = ""

        if let userLoc = currentLocation?.coordinate {
            /// navigate to coord
            googleMapsUrlStr = "comgooglemaps://?saddr=\(userLoc.latitude),\(userLoc.longitude)&daddr=\(lat),\(lon)&zoom=13&views=traffic"
            guard URL(string: googleMapsUrlStr) != nil else {
                print("Navigation in Google maps failed")
                return
            }
        } else {
            /// center map on coord
            googleMapsUrlStr = "comgooglemaps://?center=\(lat),\(lon)&zoom=13&views=traffic&q=\(lat),\(lon)"
            guard URL(string: googleMapsUrlStr) != nil else {
                print("Navigation in Google maps failed")
                return
            }
        }
        UIApplication.shared.open(URL(string: googleMapsUrlStr)!, options: [:], completionHandler: nil)
    }
    
    func openMapsToNavigate(to coord: CLLocationCoordinate2D) {
        let lat = coord.latitude
        let lon = coord.longitude

        let destinationLocation = CLLocation(latitude: lat, longitude: lon)
        let destinationMapItem = MKMapItem(placemark: MKPlacemark(coordinate: destinationLocation.coordinate))
        destinationMapItem.name = title
        
        MKMapItem.openMaps(with: [destinationMapItem], launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }

    func navigateInApp() {
        /// hide / show directions depending on the button state
        directionsButton.isSelected.toggle()
        
        if !directionsButton.isSelected {
            if appleMapsView.isHidden {
                googleMapsPolylines.forEach({ $0.map = nil })
                //googleMapsView.clear()
            } else {
                appleMapsView.removeOverlays(appleMapsView.overlays(in: .aboveRoads))
            }
            directionsButton.stopLoading()
            
            if directionsButton.tag != 0 {
                removeUserLocation(from: &dummyDestinationsCY)
                directionsButton.tag = 0
            }
        }
        else {
            directionsButton.startLoading()

            if directionsButton.tag == 0 {
                insertUserLocation(in: &dummyDestinationsCY, onSuccess: {
                    self.directionsButton.tag += 1 /// insert once
                })
                insertUserLocation(in: &dummyDestinationsUS)
            }
            
            if appleMapsView.isHidden {
                provideGoogleMapsDirections(dummyDestinationsCY)
//                provideGoogleMapsDirections(dummyDestinationsUS)
            } else {
                provideAppleMapsDirections(dummyDestinationsCY)
//                provideAppleMapsDirections(dummyDestinationsUS)
            }
        }
    }
    
    func insertUserLocation(in array: inout [CLLocation], onSuccess: (() -> Void)? = nil) {
        if let userLocation = currentLocation {
            array.insert(userLocation, at: 0)
            onSuccess?()
        } else {
            print("Current location is unknown. Check GPS signal or location permission in settings.")
        }
    }
    
    func removeUserLocation(from array: inout [CLLocation]) {
        array.remove(at: 0)
    }
}

