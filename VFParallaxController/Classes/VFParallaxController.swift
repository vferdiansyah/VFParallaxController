//
//  VFParallaxController.swift
//  VFParallaxController
//
//  Created by Veri Ferdiansyah on 09/01/2016.
//  Copyright (c) 2016 Veri Ferdiansyah. All rights reserved.
//

import MapKit
import UIKit

let kScreenHeightWithoutStatusBar = UIScreen.main.bounds.size.height - 20
let kScreenWidth = UIScreen.main.bounds.size.width
let kStatusBarHeight = 20
let kYDownTableView = kScreenHeightWithoutStatusBar - 40
let kDefaultHeaderHeight = 100.0
let kMinHeaderHeight = 10.0
let kDefaultYOffset = (UIScreen.main.bounds.size.height == 480.0) ? -200.0 : -250.0
let kFullYOffset = -200.0
let kMinYOffsetToReach = -30
let kOpenShutterLatitudeMinus = 0.005
let kCloseShutterLatitudeMinus = 0.018

open class VFParallaxController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIGestureRecognizerDelegate {
	var tableView: UITableView!
	var mapView: MKMapView!
	var mapViewTappedGesture: UITapGestureRecognizer!
	var tableViewTappedGesture: UITapGestureRecognizer!
	var mapHeight: Double = 1000.0
	var isShutterOpened: Bool = false
	var isMapDisplayed: Bool = false

	// MARK: - Initializers

	override open func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
		setupMapView()
	}

	override open func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	func setupTableView() {
		tableView = UITableView.init(frame: CGRect(x: 0, y: 20, width: CGFloat(kScreenWidth), height: CGFloat(kScreenHeightWithoutStatusBar)))
		tableView.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: CGFloat(kDefaultHeaderHeight)))
		tableView.backgroundColor = UIColor.clear

		mapViewTappedGesture = UITapGestureRecognizer.init(target: self, action: #selector(mapViewTappedHandler))
		tableViewTappedGesture = UITapGestureRecognizer.init(target: self, action: #selector(tableViewTappedHandler))
		tableViewTappedGesture.delegate = self

		tableView.tableHeaderView?.addGestureRecognizer(mapViewTappedGesture)
		tableView.addGestureRecognizer(tableViewTappedGesture)

		tableView.dataSource = self
		tableView.delegate = self

		view.addSubview(tableView)
	}

	func setupMapView() {
		mapView = MKMapView.init(frame: CGRect(x: 0, y: CGFloat(kDefaultYOffset), width: CGFloat(kScreenWidth), height: CGFloat(kScreenHeightWithoutStatusBar)))
		mapView.showsUserLocation = true
		mapView.delegate = self
		self.view.insertSubview(mapView, belowSubview: tableView)
	}

	// MARK: - Internal Methods

	@objc func mapViewTappedHandler(_ gesture: UIGestureRecognizer) -> Void {
		if (!isShutterOpened) {
			openShutter()
		}
	}

	@objc func tableViewTappedHandler(_ gesture: UIGestureRecognizer) -> Void {
		if (isShutterOpened) {
			closeShutter()
		}
	}

	func openShutter() {
		UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {
			self.tableView.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: CGFloat(kMinHeaderHeight)))
			self.tableView.frame = CGRect(x: 0, y: CGFloat(kYDownTableView), width: self.tableView.frame.size.width, height: self.tableView.frame.size.height)
			self.mapView.frame = CGRect(x: 0, y: CGFloat(kFullYOffset), width: self.mapView.frame.size.width, height: CGFloat(self.mapHeight))
			}) { (finished) in
				self.tableView.allowsSelection = false
				self.tableView.isScrollEnabled = false
				self.isShutterOpened = true

				self.zoomToUserLocation(self.mapView.userLocation, minLatitude: kOpenShutterLatitudeMinus, animated: true)
		}
	}

	func closeShutter() {
		UIView.animate(withDuration: 0.2, delay: 0.1, options: .curveEaseOut, animations: {
			self.tableView.tableHeaderView = UIView.init(frame: CGRect(x: 0, y: CGFloat(kDefaultYOffset), width: self.view.frame.size.width, height: CGFloat(kDefaultHeaderHeight)))
			self.tableView.frame = CGRect(x: 0, y: CGFloat(kStatusBarHeight), width: self.tableView.frame.size.width, height: self.tableView.frame.size.height)
			self.mapView.frame = CGRect(x: 0, y: CGFloat(kDefaultYOffset), width: self.mapView.frame.size.width, height: CGFloat(kScreenHeightWithoutStatusBar))
		}) { (finished) in
			self.tableView.allowsSelection = true
			self.tableView.isScrollEnabled = true
			self.isShutterOpened = false

			self.zoomToUserLocation(self.mapView.userLocation, minLatitude: kCloseShutterLatitudeMinus, animated: true)
		}
	}

	func zoomToUserLocation(_ userLocation: MKUserLocation, minLatitude: Double, animated: Bool) {
		if (userLocation.isEqual(nil)) {
			return
		}

		var loc = userLocation.coordinate
		loc.latitude = loc.latitude - minLatitude

		var region = MKCoordinateRegion.init(center: loc, span: MKCoordinateSpanMake(0.05, 0.05))
		region = mapView.regionThatFits(region)
		mapView.setRegion(region, animated: animated)
	}

	// MARK: - UITableViewDelegate Methods

	open func scrollViewDidScroll(_ scrollView: UIScrollView) {
		let scrollOffset = scrollView.contentOffset.y
		var mapViewHeaderFrame = mapView.frame

		if (scrollOffset < 0) {
			mapViewHeaderFrame.origin.y = CGFloat(kDefaultYOffset) - (scrollOffset / 2)
		} else {
			mapViewHeaderFrame.origin.y = CGFloat(kDefaultYOffset) - scrollOffset
		}

		mapView.frame = mapViewHeaderFrame

		if (tableView.contentOffset.y < CGFloat(kMinYOffsetToReach)) {
			if (!isMapDisplayed) {
				isMapDisplayed = true
			}
		} else {
			if (isMapDisplayed) {
				isMapDisplayed = false
			}
		}
	}

	open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if (isMapDisplayed) {
			openShutter()
		}
	}

	// MARK: - UITableViewDataSource Methods

	open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 20
	}

	open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell = UITableViewCell()

		if (indexPath.row == 0) {
			if (cell.isEqual(nil)) {
				cell = UITableViewCell.init(style: .default, reuseIdentifier: "firstCell")

				let cellBounds = cell.layer.bounds
				let shadowFrame = CGRect(x: cellBounds.origin.x, y: cellBounds.origin.y, width: tableView.frame.size.width, height: 10.0)
				let shadowPath = UIBezierPath.init(rect: shadowFrame).cgPath

				cell.layer.shadowPath = shadowPath
				cell.layer.shadowOffset = CGSize(width: -2, height: -2)
				cell.layer.shadowColor = UIColor.gray.cgColor
				cell.layer.shadowOpacity = 0.75
			}
		} else {
			if (cell.isEqual(nil)) {
				cell = UITableViewCell.init(style: .default, reuseIdentifier: "otherCell")
			}
		}

		cell.textLabel?.text = "Hello, World!"

		return cell
	}

	open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		let totalRow = tableView.numberOfRows(inSection: indexPath.section)

		if (indexPath.row == totalRow - 1) {
			let cellsHeight = CGFloat(totalRow) * cell.frame.size.height
			let tableHeight = tableView.frame.size.height - (tableView.tableHeaderView?.frame.size.height)!

			if ((cellsHeight - tableView.frame.origin.y) < tableHeight) {
				let footerHeight = tableHeight - cellsHeight
				tableView.tableFooterView = UIView.init(frame: CGRect(x: 0, y: 0, width: CGFloat(kScreenWidth), height: footerHeight))
				tableView.tableFooterView?.backgroundColor = UIColor.white
			}
		}
	}

	// MARK: - MKMapViewDelegate Methods

	open func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
		if (isShutterOpened) {
			zoomToUserLocation(mapView.userLocation, minLatitude: kOpenShutterLatitudeMinus, animated: true)
		} else {
			zoomToUserLocation(mapView.userLocation, minLatitude: kCloseShutterLatitudeMinus, animated: true)
		}
	}

	// MARK: - UIGestureRecognizerDelegate Methods

	open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
		if (gestureRecognizer == tableViewTappedGesture) {
			return isShutterOpened
		}

		return true
	}
}
