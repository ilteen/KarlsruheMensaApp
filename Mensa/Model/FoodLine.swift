//
//  FoodLine.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct FoodLine: Identifiable, Comparable {
    
    var name: String
    var foods: [Food]
    var closingText: String
    var id: String {name}
    var order: Int

    init(shortName: String, foods: [Food]) {
        (self.name, self.order) = FoodLine.getNameAndOrder(shortName: shortName)
        self.foods = foods
        self.closingText = ""
    }
    
    init(shortName: String, closingText: String) {
        (self.name, self.order) = FoodLine.getNameAndOrder(shortName: shortName)
        self.foods = []
        self.closingText = closingText
    }
    
    static func < (lhs: FoodLine, rhs: FoodLine) -> Bool {
        return lhs.order < rhs.order
    }
    
    static func == (lhs: FoodLine, rhs: FoodLine) -> Bool {
        return lhs.name == rhs.name
    }
    
    static func getNameAndOrder(shortName: String) -> (String, Int) {
        switch shortName {
            case "l1":
                return ("Linie 1", 0)
            case "l2":
                return ("Linie 2", 1)
            case "l3":
                return ("Linie 3", 2)
            case "l45":
                return ("Linie 4/5", 3)
            case "update":
                return ("L6 Update", 4)
            case "wahl1":
                return ("Wahlessen 1", 5)
            case "wahl2":
                return ("Wahlessen 2", 6)
            case "wahl3":
                return ("Wahlessen 3", 7)
            case "gut":
            	return ("Gut und Günstig", 8)
            case "gut2":
                return ("Gut und Güstig 2", 9)
            case "pizza":
                return ("[pizza]werk Pizza", 10)
            case "pasta":
                return ("[pizza]werk Pasta", 11)
            case "salat_dessert":
                return ("[pizza]werk Salate/Vorspeisen", 12)
            case "aktion":
            	return ("[kœri]werk", 13)
            case "curryqueen":
                return ("[kœri]werk", 14)
            case "buffet":
                return ("Buffet", 15)
            case "schnitzelbar":
                return ("Schnitzelbar", 16)
            case "heisstheke":
            	return ("Cafeteria Heiße Theke", 17)
            case "nmtisch":
                return ("Cafetaria ab 14:30", 18)
            case "abend":
                return ("Spätausgabe/Abendessen", 19)
            default:
                return (shortName, 20)
        }
    }
}
