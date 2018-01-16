//
//  TrackPlayerViewController.swift
//  MusicSearch
//
//  Created by Mark on 1/13/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit
import SDWebImage
import AVFoundation
import AVKit

class TrackPlayerViewController: UIViewController {
	@IBOutlet weak var albumImage: UIImageView!
	@IBOutlet weak var albumName: UILabel!
	@IBOutlet weak var artistName: UILabel!
	@IBOutlet weak var trackName: UILabel!
	@IBOutlet weak var totalDuration: UILabel!
	@IBOutlet weak var timeElaspeLabel: UILabel!
	@IBOutlet weak var timeSlider: UISlider!
	@IBOutlet weak var lyricsTextView: UITextView!
	@IBOutlet weak var playNPauseButton: UIButton!
	
	var currentTrack: Track?
	
	private var player: AVPlayer!
	private var isVideoPlaying = false
	private lazy var lyricsService = LyricsScrapingService.shareInstance
	
	override func viewDidLoad() {
        super.viewDidLoad()
		setupUI()
		
		if let track = currentTrack {
			initializeTrack(track: track)
			lyricsService.fetchLyrics(of: track.name, from: track.artist) { (lyricsResult) in
				
				DispatchQueue.main.async {
					guard let lyrics = lyricsResult else {
						self.lyricsTextView.text = "No lyrics Found"
						return
					}
					
					self.lyricsTextView.text = lyrics
				}
			}
		}
    }
	
	private func setupUI() {
		// clear nav bar
		let bar = self.navigationController?.navigationBar
		bar?.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
		bar?.shadowImage = UIImage()
		bar?.backgroundColor = UIColor.clear
	}
	
	private func initializeTrack(track: Track) {
		albumName.text = track.albumName
		albumImage.sd_setImage(with: track.albumImageUrl, completed: nil)
		artistName.text = track.artist
		trackName.text = track.name
		
		player = AVPlayer(url: track.previewUrl!)
		
		// add observer for the duration when currentItem is first available / inialized
		player.currentItem?.addObserver(self, forKeyPath: "duration", options: [.new, .initial], context: nil)
		
		// add observer for time change in playing item
		addTimeObserver()
	}
	
	// add obsever for time change in player currentItem
	private func addTimeObserver() {
		let interval = CMTime(seconds: 0.5, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
		let mainQueue = DispatchQueue.main
		
		// call back func when time change
		_ = player.addPeriodicTimeObserver(forInterval: interval, queue: mainQueue) { [weak self] time in
			guard let currentItem = self?.player.currentItem else { return }
			
			if currentItem.currentTime() == currentItem.duration {
				// when we reach duration then pause player and rewind back to begining
				self?.stop()
				self?.player.seek(to: kCMTimeZero)
			}
			
			// update time slider
			self?.timeSlider.value = Float(currentItem.currentTime().seconds)
			
			// update current time value
			self?.timeElaspeLabel.text = self?.getTimeString(from: currentItem.currentTime())
		}
	}
	
	@IBAction func dismissAction() {
		stop()
		navigationController?.popViewController(animated: true)
	}
	
	// When tapped on forward, we fastforward 3 seconds
	@IBAction func forward(_ sender: UIButton) {
		guard let duration = player.currentItem?.duration else { return }
		let currentPlayTime = CMTimeGetSeconds(player.currentTime())
		let newTimePlayTime = currentPlayTime + 3.0
		
		// forward only if newtime is less than duration
		if newTimePlayTime < CMTimeGetSeconds(duration) {
			let time = CMTimeMake(Int64(newTimePlayTime * 1000), 1000)
			player.seek(to: time)
		}
	}
	
	@IBAction func rewind(_ sender: UIButton) {
		let currentPlayTime = CMTimeGetSeconds(player.currentTime())
		var newTimePlayTime = currentPlayTime - 3.0
		
		if newTimePlayTime < 0 {
			newTimePlayTime = 0.0
		}
		
		//
		let time = CMTimeMake(Int64(newTimePlayTime * 1000), 1000)
		player.seek(to: time)
	}
	
	private func stop() {
		isVideoPlaying = false
		player.pause()
		playNPauseButton.setImage(UIImage(named: "player_play_button"), for: .normal)
		playNPauseButton.setImage(UIImage(named: "player_play_button_pressed"), for: .highlighted)
	}
	
	private func start() {
		isVideoPlaying = true
		player.play()
		playNPauseButton.setImage(UIImage(named: "player_pause_button"), for: .normal)
		playNPauseButton.setImage(UIImage(named: "player_pause_button_pressed"), for: .highlighted)
	}
	
	@IBAction func pauseOrStart(_ sender: UIButton) {
		if isVideoPlaying {
			stop()
		} else {
			start()
		}
	}
	
	@IBAction func changeProgress(_ sender: UISlider) {
		player.seek(to: CMTimeMake(Int64(sender.value * 1000), 1000))
	}
	
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		// whenever the value of player currentItem changes, the observer is notified
		// we check keyPath to see if current notification is from the duration observer, since we might have
		// obserers on other objects
		if keyPath == "duration", let durationSec = player.currentItem?.duration.seconds, durationSec > 0.0 {
			totalDuration.text = getTimeString(from: (player.currentItem!.duration))
			timeSlider.maximumValue = Float(durationSec)
			timeSlider.minimumValue = 0
		}
	}
	
	func getTimeString(from time: CMTime) -> String {
		let totalSeconds = CMTimeGetSeconds(time)
		let hr = Int(totalSeconds/3600)
		let min = Int(totalSeconds/60)
		let sec = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
	
		if hr > 0 {
			 return String(format: "%02i : %02i : %02i", hr, min, sec)
		} else {
			return String(format: "%02i : %02i", min, sec)
		}
	}
}
