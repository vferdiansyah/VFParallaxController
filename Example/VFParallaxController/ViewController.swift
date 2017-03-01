//
//  ViewController.swift
//  VFParallaxController
//
//  Created by Veri Ferdiansyah on 09/01/2016.
//  Copyright (c) 2016 Veri Ferdiansyah. All rights reserved.
//

import MapKit
import UIKit
import VFParallaxController

class ViewController: VFParallaxController, CLLocationManagerDelegate {
	var locationManager: CLLocationManager!

    override func viewDidLoad() {
        super.viewDidLoad()

		locationManager = CLLocationManager()
		locationManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

	override var preferredStatusBarStyle : UIStatusBarStyle {
		return .default
	}

	// MARK: - CLLocationManagerDelegate Methods

	func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
		switch status {
		case .notDetermined:
			manager.requestWhenInUseAuthorization()
			break
		case .authorizedWhenInUse:
			manager.startUpdatingLocation()
			break
		case .authorizedAlways:
			manager.startUpdatingLocation()
			break
		case .restricted:
			break
		case .denied:
			break
		}
	}
}
