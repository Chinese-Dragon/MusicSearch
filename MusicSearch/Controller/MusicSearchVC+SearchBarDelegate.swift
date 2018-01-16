//
//  MusicSearchVC+SearchBarDelegate.swift
//  MusicSearch
//
//  Created by Mark on 1/13/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import Foundation
import UIKit

extension MusicSearchViewController: UISearchBarDelegate, UISearchResultsUpdating {
	
	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
		dismissKeyboard()
	}
	
	func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
		view.addGestureRecognizer(tapRecognizer)
	}
	
	func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
		view.removeGestureRecognizer(tapRecognizer)
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		searchBar.setShowsCancelButton(true, animated: true)
		guard let queryText = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
			!queryText.isEmpty else {
				self.matchingTracks.removeAll()
				return
		}
		print(queryText)
		
		showNetworkIndicators()
		queryService.getSearchResults(searchTerm: queryText) { (tracks, error) in
			
			if let trackResults = tracks {
				DispatchQueue.main.async {
					self.hideNetworkIndicatros()
					self.matchingTracks = trackResults

				}
			}
			
			if !error.isEmpty {
				print("Search Error \(error)")
			}
		}
	}
}
