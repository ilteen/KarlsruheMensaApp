//
//  Watch_MensaApp.swift
//  Watch Mensa Watch App
//
//  Created by Philipp on 27.10.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import SwiftUI

@main
struct MensaWatchApp: App {
    
    @StateObject private var phoneMessaging = PhoneMessaging.shared
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView().environmentObject(phoneMessaging)
            }
        }
    }
}
