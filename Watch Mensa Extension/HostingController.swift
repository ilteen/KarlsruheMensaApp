//
//  HostingController.swift
//  Watch Mensa Extension
//
//  Created by Philipp on 13.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import WatchKit
import Foundation
import SwiftUI

class HostingController: WKHostingController<ContentView> {
    override var body: ContentView {
        return ContentView(showAlert: false)
    }
}
