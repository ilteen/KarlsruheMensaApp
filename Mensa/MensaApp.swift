//
//  MensaApp.swift
//  Mensa
//
//  Created by Philipp on 27.10.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation
import SwiftUI

@main
struct MensaApp: App {
    
    @StateObject private var connectivityRequestHandler = WatchConnectivityHandler.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView().environmentObject(connectivityRequestHandler)
        }
    }
}
