//
//  Constants.swift
//  Mensa
//
//  Created by André Wilhelm on 16.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

public class Constants {
    
    static let EMPTY = ""
    static let SPACE = " "
    static let DOT = "."
    static let COMMA = ","
    static let DASH = " - "
    
    // date formats
    static let DATE_FORMAT_EEEE = "EEEE"
    static let DATE_FORMAT_LLLL = "LLLL"
    static let CANTEEN_CLOSING = 15 //15:00
    static let DAYS_PER_WEEK = 7
    
    // language prefixes
    static let LANGUAGE_PREFIX_DE = "de"
    
    // localizable strings
    static let NO_INTERNET = NSLocalizedString("noInternet", comment: EMPTY)
    static let CONNECT = NSLocalizedString("connect", comment: EMPTY)
    static let TRY_AGAIN = NSLocalizedString("try again", comment: EMPTY)
    static let CANTEEN = NSLocalizedString("Canteen", comment: EMPTY)
    static let PRICE_GROUP = NSLocalizedString("PriceGroup", comment: EMPTY)
    static let STUDENTS = NSLocalizedString("Students", comment: EMPTY)
    static let GUESTS = NSLocalizedString("Guests", comment: EMPTY)
    static let ATTENDANTS = NSLocalizedString("Attendants", comment: EMPTY)
    static let PUPILS = NSLocalizedString("Pupils", comment: EMPTY)
    static let SETTINGS = NSLocalizedString("Settings", comment: EMPTY)
    static let DONE = NSLocalizedString("Done", comment: EMPTY)
    static let SATURDAY = NSLocalizedString("Saturday", comment: EMPTY)
    static let SUNDAY = NSLocalizedString("Sunday", comment: EMPTY)
    
    // colors
    static let COLOR_ACCENT: Color = .green
    
    // keys
    static let KEY_CHOSEN_CANTEEN = "chosenCanteen"
    static let KEY_CHOSEN_PRICE_GROUP = "chosenPriceGroup"
    
    // images
    static let IMAGE_SETTINGS = "gear"
    static let IMAGE_CIRCLE_FILL = "circle.fill"
    
    // canteens
    static let CANTEEN_AMOUNT = 6
    static let CANTEEN_ADENAUERRING = NSLocalizedString("Mensa am Adenauerring", comment: EMPTY)
    static let CANTEEN_ERZEBERGER = NSLocalizedString("Mensa Erzbergerstraße", comment: EMPTY)
    static let CANTEEN_GOTTESAUE = NSLocalizedString("Mensa Schloss Gottesaue", comment: EMPTY)
    static let CANTEEN_HOLZGARTEN = NSLocalizedString("Mensa Holzgartenstraße", comment: EMPTY)
    static let CANTEEN_MOLTKE = NSLocalizedString("Mensa Moltke", comment: EMPTY)
    static let CANTEEN_TIEFENBRONNER = NSLocalizedString("Mensa Tiefenbronner Straße", comment: EMPTY)
    static let CANTEEN_CAFETERIA_MOLTKE = NSLocalizedString("Cafétaria Moltkestraße 30", comment: EMPTY)
    
    // food lines
    static let FOOD_LINE_CLOSED = NSLocalizedString("closed", comment: EMPTY)
    
    static let ENERGY = NSLocalizedString("Energy", comment: "")
    static let PROTEINS = NSLocalizedString("Protein", comment: "")
    static let CARBOHYDRATES = NSLocalizedString("Carbohydrates", comment: "")
    static let SUGAR = NSLocalizedString("  - Sugars", comment: "")
    static let FAT = NSLocalizedString("Fat", comment: "")
    static let SATURATED_FAT = NSLocalizedString("  - Saturated Fat", comment: "")
    static let SALT = NSLocalizedString("Salt", comment: "")
    static let CO2_VALUE = NSLocalizedString("CO₂", comment: "")
    static let CO2_SCORE = NSLocalizedString("CO₂ Score", comment: "")
    static let WATER_VALUE = NSLocalizedString("Water", comment: "")
    static let WATER_SCORE = NSLocalizedString("Water Score", comment: "")
    static let ANIMAL_WELFARE_SCORE = NSLocalizedString("Animal Welfare", comment: "")
    static let RAINFOREST_SCORE = NSLocalizedString("Rainforest", comment: "")
    
    //apple watch ui
    static let WATCH_TODAY = NSLocalizedString("Today", comment: EMPTY)
    static let WATCH_TOMORROW = NSLocalizedString("Tomorrow", comment: EMPTY)
    static let WATCH_DATOMORROW = "Übermorgen"
    static let WATCH_LOADING = NSLocalizedString("loading...", comment: EMPTY)
    static let WATCH_CALENDAR_IMAGE = "calendar"
    static let WATCH_ARROW_RIGHT = "arrow.right"
    static let WATCH_ARROW_LEFT = "arrow.left"
    
    // api login
    static let API_URL = "https://www.sw-ka.de/de/hochschulgastronomie/speiseplan/"
    // api abbreviations
    static let API_ABBREVIATIONS_CANTEEN_ADENAUERRING = "mensa_adenauerring"
    static let API_ABBREVIATIONS_CANTEEN_ERZBERGER = "mensa_erzberger"
    static let API_ABBREVIATIONS_CANTEEN_GOTTESAUE = "mensa_gottesaue"
    static let API_ABBREVIATIONS_CANTEEN_HOLZGARTEN = "mensa_holzgarten"
    static let API_ABBREVIATIONS_CANTEEN_MOLTKE = "mensa_moltke"
    static let API_ABBREVIATIONS_CANTEEN_TIEFENBRONNER = "mensa_tiefenbronner"
    static let API_ABBREVIATIONS_CANTEEN_MENSERIA_MOLTKE = "mensa_x1moltkestrasse"
    
    
}
