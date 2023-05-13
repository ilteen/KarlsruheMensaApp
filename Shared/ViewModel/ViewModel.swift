//
//  Settings.swift
//  Mensa
//
//  Created by Philipp on 12.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import Foundation

class ViewModel: ObservableObject {
    
    static let shared = ViewModel()
    
    @Published var showSettings = false
    @Published var canteenSelection = Canteens(rawValue: UserDefaults.standard.string(forKey: Constants.KEY_CHOSEN_CANTEEN) ?? "Mensa am Adenauerring") ?? Canteens.MENSA_ADENAUERRING
    @Published var priceGroupSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
    @Published var showAlert = false
    @Published var loading = true
    
    @Published var onlyVegan: Bool {
        didSet {
            UserDefaults.standard.set(onlyVegan, forKey: "onlyVegan")
            if (onlyVegan && !onlyVegetarian) {
                onlyVegetarian.toggle()
            }
            else if (!onlyVegan && onlyVegetarian) {
                onlyVegetarian.toggle()
            }
            if (onlyVegan && !noPork) {
                noPork.toggle()
            }
            else if (!onlyVegan && noPork) {
                noPork.toggle()
            }
            if (onlyVegan && !noBeef) {
                noBeef.toggle()
            }
            else if (!onlyVegan && noBeef) {
                noBeef.toggle()
            }
            if (onlyVegan && !noFish) {
                noFish.toggle()
            }
            else if (!onlyVegan && noFish) {
                noFish.toggle()
            }
        }
    }
    
    @Published var onlyVegetarian: Bool {
        didSet {
            UserDefaults.standard.set(onlyVegan, forKey: "onlyVegetarian")
            if (onlyVegetarian && !noPork) {
                noPork.toggle()
            }
            else if (!onlyVegetarian && noPork) {
                noPork.toggle()
            }
            if (onlyVegetarian && !noBeef) {
                noBeef.toggle()
            }
            else if (!onlyVegetarian && noBeef) {
                noBeef.toggle()
            }
            if (onlyVegetarian && !noFish) {
                noFish.toggle()
            }
            else if (!onlyVegetarian && noFish) {
                noFish.toggle()
            }
        }
    }
    
    @Published var noPork: Bool {
        didSet {
            UserDefaults.standard.set(onlyVegan, forKey: "noPork")
        }
    }
    
    @Published var noBeef: Bool {
        didSet {
            UserDefaults.standard.set(onlyVegan, forKey: "noBeef")
        }
    }
    
    @Published var noFish: Bool {
        didSet {
            UserDefaults.standard.set(onlyVegan, forKey: "noFish")
        }
    }
    
    @Published var canteen: Canteen? = nil
    
    func areCanteensNil() -> Bool {
        return self.canteen == nil
    }
    
    func getFoodLines(selectedDay: Int) -> [FoodLine] {
        return self.canteen?.foodOnDayX[selectedDay] ?? []
    }
    
    private init() {
        self.onlyVegan = UserDefaults.standard.bool(forKey: "onlyVegan")
        self.onlyVegetarian = UserDefaults.standard.bool(forKey: "onlyVegetarian")
        self.noPork = UserDefaults.standard.bool(forKey: "noPork")
        self.noBeef = UserDefaults.standard.bool(forKey: "noBeef")
        self.noFish = UserDefaults.standard.bool(forKey: "noFish")
    }
}

enum Canteens: String, CaseIterable {
    case MENSA_ADENAUERRING = "Mensa am Adenauerring"
    case MENSERIA_ERZBERGER = "Menseria Erzbergerstraße"
    case MENSA_GOTTESAUE = "Mensa Schloss Gottesaue"
    case MENSERIA_HOLZGARTEN = "Menseria Holzgartenstraße"
    case MENSA_MOLTKE = "Mensa Moltke"
    case MENSERIA_MOLTKE = "Menseria Moltkestraße"
    case CAFETERIA_TIEFENBRONNER = "Cafetaria Tiefenbronner Straße"
}
