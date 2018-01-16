//
//  ViewController.swift
//  MusicSearch
//
//  Created by Mark on 1/10/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class MusicSearchViewController: UIViewController {
	
	@IBOutlet weak var tableview: UITableView!
	var searchBar: UISearchBar!
	var searchController: UISearchController!
	
	var matchingTracks: [Track] = [] {
		didSet {
			if view.window != nil {
				tableview.reloadData()
			}
		}
	}
	
	lazy var queryService = QueryService.shareInstance
	lazy var tapRecognizer: UITapGestureRecognizer = {
		var recognizer = UITapGestureRecognizer(target:self, action: #selector(dismissKeyboard))
		return recognizer
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupUI()
	}
}

// MARK: - Helder Methods
extension MusicSearchViewController {
	private func setupUI() {
		tableview.rowHeight = UITableViewAutomaticDimension
		tableview.estimatedRowHeight = 100
		
		// clear nav bar
		let bar = self.navigationController?.navigationBar
		bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		bar?.shadowImage = UIImage()
		bar?.backgroundColor = UIColor.clear
		
		// setup search
		searchController = UISearchController(searchResultsController: nil)
		
		// configure searchController
		searchController.searchResultsUpdater = self
		searchController.dimsBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		// Set this to false, since we want the search bar accessible at all times.
		
		// configure searchbar
		searchBar = searchController.searchBar
		searchBar.sizeToFit()
		searchBar.placeholder = "Search..."
		searchBar.delegate = self
		searchBar.searchBarStyle = .minimal
		
		// change searchbar text color
		let textFieldInsideSearchBar = searchBar.value(forKey: "searchField") as! UITextField
		textFieldInsideSearchBar.textColor = .white
		
		// Add searchbar to nav bar
		// Fallback on earlier versions
		navigationItem.titleView = searchController.searchBar
		
		definesPresentationContext = true
	}
	
	func showNetworkIndicators() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = true
	}
	
	func hideNetworkIndicatros() {
		UIApplication.shared.isNetworkActivityIndicatorVisible = false
	}
	
	@objc func dismissKeyboard() {
		searchBar.resignFirstResponder()
		searchBar.setShowsCancelButton(false, animated: true)
	}
	
	func playTrack(_ track: Track) {
		let playerViewController = AVPlayerViewController()
		
		let player = AVPlayer(url: track.previewUrl!)
		playerViewController.player = player
		present(playerViewController, animated: true, completion: nil)
		player.play()
	}
}

// MARK: - Tableview Delegate Methods
extension MusicSearchViewController: UITableViewDelegate, UITableViewDataSource {
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return matchingTracks.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "TrackCell", for: indexPath) as! TrackCell
		
		let currentTrack = matchingTracks[indexPath.row]
		cell.configure(with: currentTrack)
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let selectedTrack = matchingTracks[indexPath.row]
		let targetVC = storyboard?.instantiateViewController(withIdentifier: "TrackPlayerViewController") as! TrackPlayerViewController
		targetVC.currentTrack = selectedTrack
		navigationController?.pushViewController(targetVC, animated: true)
	}
}
