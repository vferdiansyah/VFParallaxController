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

	override func preferredStatusBarStyle() -> UIStatusBarStyle {
		return .Default
	}

	// MARK: - CLLocationManagerDelegate Methods

	func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
		switch status {
		case .NotDetermined:
			manager.requestWhenInUseAuthorization()
			break
		case .AuthorizedWhenInUse:
			manager.startUpdatingLocation()
			break
		case .AuthorizedAlways:
			manager.startUpdatingLocation()
			break
		case .Restricted:
			break
		case .Denied:
			break
		}
	}
}
