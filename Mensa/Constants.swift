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
    static let DASH = "-"
    
    // date formats
    static let DATE_FORMAT_EEEE = "EEEE"
    static let DATE_FORMAT_LLLL = "LLLL"
    
    // language prefixes
    static let LANGUAGE_PREFIX_DE = "de"
    
    // localizable strings
    static let NO_INTERNET = NSLocalizedString("noInternet", comment: EMPTY)
    static let CONNECT = NSLocalizedString("connect", comment: EMPTY)
    static let OKAY = NSLocalizedString("Okay", comment: EMPTY)
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
    static let IMAGE_INFO = "info.circle"
    static let IMAGE_SETTINGS = "gear"
    static let IMAGE_CIRCLE_FILL = "circle.fill"
    
    // canteens
    static let CANTEEN_ADENAUERRING = NSLocalizedString("Mensa am Adenauerring", comment: EMPTY)
    static let CANTEEN_ERZEBERGER = NSLocalizedString("Mensa Erzbergerstraße", comment: EMPTY)
    static let CANTEEN_GOTTESAUE = NSLocalizedString("Mensa Schloss Gottesaue", comment: EMPTY)
    static let CANTEEN_HOLZGARTEN = NSLocalizedString("Mensa Holzgartenstraße", comment: EMPTY)
    static let CANTEEN_MOLTKE = NSLocalizedString("Mensa Moltke", comment: EMPTY)
    static let CANTEEN_TIEFENBRONNER = NSLocalizedString("Mensa Tiefenbronner Straße", comment: EMPTY)
    static let CANTEEN_CAFETERIA_MOLTKE = NSLocalizedString("Cafétaria Moltkestraße 30", comment: EMPTY)
    
    // food lines
    static let FOOD_LINE_1 = "Linie 1"
    static let FOOD_LINE_2 = "Linie 2"
    static let FOOD_LINE_3 = "Linie 3"
    static let FOOD_LINE_4_5 = "Linie 4/5"
    static let FOOD_LINE_UPDATE = "L6 Update"
    static let FOOD_WAHLESSEN_1 = "Wahlessen 1"
    static let FOOD_WAHLESSEN_2 = "Wahlessen 2"
    static let FOOD_WAHLESSEN_3 = "Wahlessen 3"
    static let FOOD_GUT_UND_GUENSTIG = "Gut und Günstig"
    static let FOOD_GUT_UND_GUENSTIG_2 = "Gut und Güstig 2"
    static let FOOD_PIZZA = "[pizza]werk Pizza"
    static let FOOD_PASTA = "[pizza]werk Pasta"
    static let FOOD_SALAT_DESSERT = "[pizza]werk Salate/Vorspeisen"
    static let FOOD_AKTION = "[kœri]werk"
    static let FOOD_CURRYQUEEN = "[kœri]werk"
    static let FOOD_BUFFET = "Buffet"
    static let FOOD_SCHNITZELBAR = "Schnitzelbar"
    static let FOOD_HEISSTHEKE = "Cafeteria Heiße Theke"
    static let FOOD_CAFETERIA = "Cafetaria ab 14:30"
    static let FOOD_ABEND = "Spätausgabe/Abendessen"
    static let FOOD_LINE_CLOSED = NSLocalizedString("closed", comment: EMPTY)
    
    // api
    static let API_DATE = "date"
    static let API_IMPORT_DATE = "import_date"
    static let API_CLOSING_TEXT = "closing_text"
    static let API_NODATA = "nodata"
    // api login
    static let API_URL = "https://www.sw-ka.de/json_interface/canteen/"
    static let API_USERNAME = "jsonapi"
    static let API_PASSWORD = "AhVai6OoCh3Quoo6ji"
    static let API_LOGIN_FORMAT = "%@:%@"
    static let API_HTTP_METHOD = "GET"
    static let API_AUTHORIZATION = "Authorization"
    // api abbreviations
    static let API_ABBREVIATIONS_LINE_1 = "l1"
    static let API_ABBREVIATIONS_LINE_2 = "l2"
    static let API_ABBREVIATIONS_LINE_3 = "l3"
    static let API_ABBREVIATIONS_LINE_4_5 = "l45"
    static let API_ABBREVIATIONS_LINE_UPDATE = "update"
    static let API_ABBREVIATIONS_WAHLESSEN_1 = "wahl1"
    static let API_ABBREVIATIONS_WAHLESSEN_2 = "wahl2"
    static let API_ABBREVIATIONS_WAHLESSEN_3 = "wahl3"
    static let API_ABBREVIATIONS_GUT_UND_GUENSTIG = "gut"
    static let API_ABBREVIATIONS_GUT_UND_GUENSTIG_2 = "gut2"
    static let API_ABBREVIATIONS_PIZZA = "pizza"
    static let API_ABBREVIATIONS_PASTA = "pasta"
    static let API_ABBREVIATIONS_SALAT_DESSERT = "salat_dessert"
    static let API_ABBREVIATIONS_AKTION = "aktion"
    static let API_ABBREVIATIONS_CURRYQUEEN = "curryqueen"
    static let API_ABBREVIATIONS_BUFFET = "buffet"
    static let API_ABBREVIATIONS_SCHNITZELBAR = "schnitzelbar"
    static let API_ABBREVIATIONS_HEISSTHEKE = "heisstheke"
    static let API_ABBREVIATIONS_CAFETERIA = "nmtisch"
    static let API_ABBREVIATIONS_ABEND = "abend"
    static let API_ABBREVIATIONS_CANTEEN_ADENAUERRING = "adenauerring"
    static let API_ABBREVIATIONS_CANTEEN_ERZBERGER = "erzberger"
    static let API_ABBREVIATIONS_CANTEEN_GOTTESAUE = "gottesaue"
    static let API_ABBREVIATIONS_CANTEEN_HOLZGARTEN = "holzgarten"
    static let API_ABBREVIATIONS_CANTEEN_MOLTKE = "moltke"
    static let API_ABBREVIATIONS_CANTEEN_TIEFENBRONNER = "tiefenbronner"
    static let API_ABBREVIATIONS_CANTEEN_CAFETERIA_MOLTKE = "x1moltkestrasse"
    
    
}
