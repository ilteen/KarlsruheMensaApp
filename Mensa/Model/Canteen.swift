//
//  Canteen.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct Canteen: Comparable {
    var name: String
    var foodOnDayX: [Int:[FoodLine]]
    var additionalInfo: String
    var order: Int
    
    init(shortName: String, foodOnDayX: [Int:[FoodLine]]) {
        (self.name, self.order) = Canteen.getNameAndOrder(shortName: shortName)
        self.foodOnDayX = foodOnDayX
        self.additionalInfo = ""
    }
    
    static func < (lhs: Canteen, rhs: Canteen) -> Bool {
        return lhs.order < rhs.order
    }
    
    static func == (lhs: Canteen, rhs: Canteen) -> Bool {
        return lhs.name == rhs.name
    }
    
    static func getNameAndOrder(shortName: String) -> (String, Int) {
        switch shortName {
            case "adenauerring":
                return ("Mensa am Adenauerring", 0)
            case "erzberger":
                return ("Mensa Erzbergstraße", 1)
            case "gottesaue":
                return ("Mensa Schloss Gottesaue", 2)
            case "holzgarten":
                return ("Mensa Holzgartenstraße", 3)
            case "moltke":
                return ("Mensa Moltke", 4)
            case "tiefenbronner":
                return ("Mensa Tiefenbronner Straße", 5)
            case "x1moltkestrasse":
            	return ("Cafétaria Moltkestraße 30", 6)
            default:
                return (shortName, 7)
        }
    }
}


