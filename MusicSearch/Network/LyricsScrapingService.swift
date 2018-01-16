//
//  LyricsScrapingService.swift
//  MusicSearch
//
//  Created by Mark on 1/14/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import Foundation
import SwiftSoup

class LyricsScrapingService: NSObject {
	static let shareInstance = LyricsScrapingService()
	private override init() {}
	
	typealias FetchLyricsHandler = (String?) -> ()
	
	var lyrics: String?
	
	func fetchLyrics(of trackName: String, from artistName: String, completion: @escaping FetchLyricsHandler) {
		guard let lyricsUrl = constructURL(with: trackName, and: artistName) else { return }
		let serialTaskQ = DispatchQueue(label: "serialQueue")
		let taskGroup = DispatchGroup()
		
		var htmlStr = ""
		// clean the old lyrics
		lyrics = nil
		
		taskGroup.enter()
		serialTaskQ.async(group: taskGroup) {
			do {
				htmlStr = try String(contentsOf: lyricsUrl)
			} catch let error as NSError {
				print("Error: \(error)")
			}
			taskGroup.leave()
		}
		
		taskGroup.enter()
		serialTaskQ.async(group: taskGroup) {
			// start parsinf the htmlStr
			if !htmlStr.isEmpty {
				do{
					let doc: Document = try SwiftSoup.parse(htmlStr)
					let nodeLists = try doc.select("div.js-lyric-text p.verse")
					for node in nodeLists {
						let htmlText = try node.html().replacingOccurrences(of: "<br>", with: "\n")
						self.lyrics = (self.lyrics ?? "") + htmlText + "\n \n"
					}
				}catch Exception.Error(let type, let message){
					print(message)
					print(type)
				}catch{
					print("error")
				}
			}
			taskGroup.leave()
		}
		
		taskGroup.notify(queue: .main) {
			// all tasks has complete
			completion(self.lyrics)
		}
	}
	
	private func constructURL(with trackName: String, and artist: String) -> URL?{
		let trackQuery = trackName.replacingOccurrences(of: " ", with: "-")
		let artistQuery = artist.replacingOccurrences(of: " ", with: "-")
		let query = "\(trackQuery)-lyrics-\(artistQuery)"
		let url = "\(URLs.lyricsSearchUrl)/\(query).html".lowercased()
		
		return URL(string: url)
	}
}
