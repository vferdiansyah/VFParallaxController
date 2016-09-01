//
//  VFParallaxController.swift
//  VFParallaxController
//
//  Created by Veri Ferdiansyah on 09/01/2016.
//  Copyright (c) 2016 Veri Ferdiansyah. All rights reserved.
//

import MapKit
import UIKit

let kScreenHeightWithoutStatusBar = UIScreen.mainScreen().bounds.size.height - 20
let kScreenWidth = UIScreen.mainScreen().bounds.size.width
let kStatusBarHeight = 20
let kYDownTableView = kScreenHeightWithoutStatusBar - 40
let kDefaultHeaderHeight = 100.0
let kMinHeaderHeight = 10.0
let kDefaultYOffset = (UIScreen.mainScreen().bounds.size.height == 480.0) ? -200.0 : -250.0
let kFullYOffset = -200.0
let kMinYOffsetToReach = -30
let kOpenShutterLatitudeMinus = 0.005
let kCloseShutterLatitudeMinus = 0.018

public class VFParallaxController: UIViewController, UITableViewDelegate, UITableViewDataSource, MKMapViewDelegate, UIGestureRecognizerDelegate {
	var tableView: UITableView!
	var mapView: MKMapView!
	var mapViewTappedGesture: UITapGestureRecognizer!
	var tableViewTappedGesture: UITapGestureRecognizer!
	var mapHeight: Double = 1000.0
	var isShutterOpened: Bool = false
	var isMapDisplayed: Bool = false

	// MARK: - Initializers

	override public func viewDidLoad() {
		super.viewDidLoad()

		setupTableView()
		setupMapView()
	}

	override public func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}

	func setupTableView() {
		tableView = UITableView.init(frame: CGRectMake(0, 20, CGFloat(kScreenWidth), CGFloat(kScreenHeightWithoutStatusBar)))
		tableView.tableHeaderView = UIView.init(frame: CGRectMake(0, 0, view.frame.size.width, CGFloat(kDefaultHeaderHeight)))
		tableView.backgroundColor = UIColor.clearColor()

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
		mapView = MKMapView.init(frame: CGRectMake(0, CGFloat(kDefaultYOffset), CGFloat(kScreenWidth), CGFloat(kScreenHeightWithoutStatusBar)))
		mapView.showsUserLocation = true
		mapView.delegate = self
		self.view.insertSubview(mapView, belowSubview: tableView)
	}

	// MARK: - Internal Methods

	@objc func mapViewTappedHandler(gesture: UIGestureRecognizer) -> Void {
		if (!isShutterOpened) {
			openShutter()
		}
	}

	@objc func tableViewTappedHandler(gesture: UIGestureRecognizer) -> Void {
		if (isShutterOpened) {
			closeShutter()
		}
	}

	func openShutter() {
		UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseOut, animations: {
			self.tableView.tableHeaderView = UIView.init(frame: CGRectMake(0, 0, self.view.frame.size.width, CGFloat(kMinHeaderHeight)))
			self.tableView.frame = CGRectMake(0, CGFloat(kYDownTableView), self.tableView.frame.size.width, self.tableView.frame.size.height)
			self.mapView.frame = CGRectMake(0, CGFloat(kFullYOffset), self.mapView.frame.size.width, CGFloat(self.mapHeight))
			}) { (finished) in
				self.tableView.allowsSelection = false
				self.tableView.scrollEnabled = false
				self.isShutterOpened = true

				self.zoomToUserLocation(self.mapView.userLocation, minLatitude: kOpenShutterLatitudeMinus, animated: true)
		}
	}

	func closeShutter() {
		UIView.animateWithDuration(0.2, delay: 0.1, options: .CurveEaseOut, animations: {
			self.tableView.tableHeaderView = UIView.init(frame: CGRectMake(0, CGFloat(kDefaultYOffset), self.view.frame.size.width, CGFloat(kDefaultHeaderHeight)))
			self.tableView.frame = CGRectMake(0, CGFloat(kStatusBarHeight), self.tableView.frame.size.width, self.tableView.frame.size.height)
			self.mapView.frame = CGRectMake(0, CGFloat(kDefaultYOffset), self.mapView.frame.size.width, CGFloat(kScreenHeightWithoutStatusBar))
		}) { (finished) in
			self.tableView.allowsSelection = true
			self.tableView.scrollEnabled = true
			self.isShutterOpened = false

			self.zoomToUserLocation(self.mapView.userLocation, minLatitude: kCloseShutterLatitudeMinus, animated: true)
		}
	}

	func zoomToUserLocation(userLocation: MKUserLocation, minLatitude: Double, animated: Bool) {
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

	public func scrollViewDidScroll(scrollView: UIScrollView) {
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

	public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		if (isMapDisplayed) {
			openShutter()
		}
	}

	// MARK: - UITableViewDataSource Methods

	public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 20
	}

	public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
		var cell: UITableViewCell = UITableViewCell()

		if (indexPath.row == 0) {
			if (cell.isEqual(nil)) {
				cell = UITableViewCell.init(style: .Default, reuseIdentifier: "firstCell")

				let cellBounds = cell.layer.bounds
				let shadowFrame = CGRectMake(cellBounds.origin.x, cellBounds.origin.y, tableView.frame.size.width, 10.0)
				let shadowPath = UIBezierPath.init(rect: shadowFrame).CGPath

				cell.layer.shadowPath = shadowPath
				cell.layer.shadowOffset = CGSize(width: -2, height: -2)
				cell.layer.shadowColor = UIColor.grayColor().CGColor
				cell.layer.shadowOpacity = 0.75
			}
		} else {
			if (cell.isEqual(nil)) {
				cell = UITableViewCell.init(style: .Default, reuseIdentifier: "otherCell")
			}
		}

		cell.textLabel?.text = "Hello, World!"

		return cell
	}

	public func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
		let totalRow = tableView.numberOfRowsInSection(indexPath.section)

		if (indexPath.row == totalRow - 1) {
			let cellsHeight = CGFloat(totalRow) * cell.frame.size.height
			let tableHeight = tableView.frame.size.height - (tableView.tableHeaderView?.frame.size.height)!

			if ((cellsHeight - tableView.frame.origin.y) < tableHeight) {
				let footerHeight = tableHeight - cellsHeight
				tableView.tableFooterView = UIView.init(frame: CGRectMake(0, 0, CGFloat(kScreenWidth), footerHeight))
				tableView.tableFooterView?.backgroundColor = UIColor.whiteColor()
			}
		}
	}

	// MARK: - MKMapViewDelegate Methods

	public func mapView(mapView: MKMapView, didUpdateUserLocation userLocation: MKUserLocation) {
		if (isShutterOpened) {
			zoomToUserLocation(mapView.userLocation, minLatitude: kOpenShutterLatitudeMinus, animated: true)
		} else {
			zoomToUserLocation(mapView.userLocation, minLatitude: kCloseShutterLatitudeMinus, animated: true)
		}
	}

	// MARK: - UIGestureRecognizerDelegate Methods

	public func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
		if (gestureRecognizer == tableViewTappedGesture) {
			return isShutterOpened
		}

		return true
	}
}
