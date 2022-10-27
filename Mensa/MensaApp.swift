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
    
    var body: some Scene {
        WindowGroup {
            ContentView(canteenViewModel: CanteenViewModel(canteens: nil), showAlert: false)
        }
    }
}
