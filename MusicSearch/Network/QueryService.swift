//
//  MusicAPIClient.swift
//  MusicSearch
//
//  Created by Mark on 1/10/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import Foundation

class QueryService: NSObject {
	static let shareInstance = QueryService()
	private override init () {}
	
	typealias JSONDictionary = [String: Any]
	typealias QueryResult = ([Track]?, String) -> ()
	
	private var tracks = [Track]()
	private var errorMessage = ""
	
	private let defaultSession = URLSession(configuration: .default)
	private var dataTask: URLSessionTask?
	
	func getSearchResults(searchTerm: String, completion: @escaping QueryResult) {
		// cancel the previous dataTask to prepare to the new dask if there was any
		dataTask?.cancel()
		
		if var components = URLComponents(string: URLs.iTunesSearchEndPoint) {
			components.query = URLs.iTunesSearchQuery + searchTerm
			guard let url = components.url else { return }
			
			dataTask = defaultSession.dataTask(with: url) { (data, response, error) in
				// defer make sure to get call before we exist the block
				defer { self.dataTask = nil}
				
				guard error == nil else {
					return
				}
				
				guard let data = data, let response = response as? HTTPURLResponse, response.statusCode == 200 else {
					return
				}
				
				self.updateSearchResults(data)
				
				DispatchQueue.main.async {
					completion(self.tracks, self.errorMessage)
				}
			}
			
			dataTask?.resume()
		}
	}
	
	func updateSearchResults(_ data: Data) {
		var jsonResponse: JSONDictionary?
		
		// clean all the traks before we update to the new onces
		tracks.removeAll()
		
		do {
			jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary
		} catch let error {
			errorMessage += "JSONSerialization error: \(error.localizedDescription) \n"
			return
		}
		
		// check if we can get array of result from json
		guard let resultArray = jsonResponse!["results"] as? [Any] else {
			errorMessage += "Dictionary does not contain results key \n"
			return
		}
		
		// parse each result into our model
		for trackResult in resultArray {
			if let trackDictionary = trackResult as? JSONDictionary,
				let previewUrlStr = trackDictionary["previewUrl"] as? String,
				let previewURL = URL(string: previewUrlStr),
				let name = trackDictionary["trackName"] as? String,
				let artistName = trackDictionary["artistName"] as? String,
				let albumName = trackDictionary["collectionName"] as? String,
				let albumImageUrlStr = trackDictionary["artworkUrl100"] as? String,
				let albumImageURL = URL(string: albumImageUrlStr) {
				
				// construct the new track
				let newTrack = Track(artist: artistName, name: name, albumName: albumName, albumImageUrl: albumImageURL, previewUrl: previewURL, lyrics: nil)
				
				tracks.append(newTrack)
			} else {
				errorMessage += "Problem parsing trackDictionary \n"
			}
		}
	}
}
