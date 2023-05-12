//
//  Settings.swift
//  Mensa
//
//  Created by Philipp on 12.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import Foundation

class Settings: ObservableObject {
    
    static let shared = Settings()
    
    private init() {}
    
    @Published var showSettings = false
    @Published var canteenSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_CANTEEN)
    @Published var priceGroupSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
    @Published var showAlert = false
    @Published var loading = true
}
