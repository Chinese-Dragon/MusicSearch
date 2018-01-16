//
//  AppDelegate.swift
//  MusicSearch
//
//  Created by Mark on 1/10/18.
//  Copyright © 2018 Mark. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		UIApplication.shared.statusBarStyle = .lightContent
		return true
	}
}

