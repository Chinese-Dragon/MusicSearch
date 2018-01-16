//
//  Song.swift
//  MusicSearch
//
//  Created by Mark on 1/10/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import Foundation

struct Track {
  var artist: String
  var name: String
  var albumName: String?
  var albumImageUrl: URL?
  var previewUrl: URL?
  var lyrics: String? // Track can be instrument which does not have lyrics
}
