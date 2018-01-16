//
//  TrackCell.swift
//  MusicSearch
//
//  Created by Mark on 1/10/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit
import SDWebImage

class TrackCell: UITableViewCell {
  @IBOutlet weak var albumImage: UIImageView!
  @IBOutlet weak var trackName: UILabel!
  @IBOutlet weak var artistNAlbumName: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
  }
  
  func configure(with track: Track) {
    albumImage.sd_setImage(with: track.albumImageUrl, completed: nil)
    trackName.text = track.name
    artistNAlbumName.text = "\(track.artist) • \(track.albumName ?? "UnKnown")"
  }
}
