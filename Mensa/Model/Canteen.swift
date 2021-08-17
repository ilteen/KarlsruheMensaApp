//
//  Canteen.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

class Canteen: Comparable, ObservableObject {
    @Published var name: String
    @Published var foodOnDayX: [Int:[FoodLine]]
    @Published var additionalInfo: String
    @Published var order: Int
    
    init(shortName: String, foodOnDayX: [Int:[FoodLine]]) {
        (self.name, self.order) = Canteen.getNameAndOrder(shortName: shortName)
        self.foodOnDayX = foodOnDayX
        self.additionalInfo = Constants.EMPTY
    }
    
    init(canteen: Canteen, daysSinceLastFetching: Int) {
        self.name = canteen.name
        self.foodOnDayX = canteen.foodOnDayX.mapKeys({$0 - daysSinceLastFetching}).filter({$0.key >= 0})
        self.additionalInfo = canteen.additionalInfo
        self.order = canteen.order
    }
    
    //dummy init
    init() {
        self.name = "Bla"
        self.order = 0
        self.foodOnDayX = [0:[FoodLine(shortName: Constants.API_ABBREVIATIONS_LINE_1, foods: [Food(name: "Test", bio: false, allergens: [], prices: [2.0, 1.0, 3.0,4.0], foodClass: FoodClass.vegetarian)])]]
        self.additionalInfo = Constants.EMPTY
    }
    
    static func < (lhs: Canteen, rhs: Canteen) -> Bool {
        return lhs.order < rhs.order
    }
    
    static func == (lhs: Canteen, rhs: Canteen) -> Bool {
        return lhs.name == rhs.name
    }
    
    static func getNameAndOrder(shortName: String) -> (String, Int) {
        switch shortName {
            case Constants.API_ABBREVIATIONS_CANTEEN_ADENAUERRING:
                return (Constants.CANTEEN_ADENAUERRING, 0)
            case Constants.API_ABBREVIATIONS_CANTEEN_ERZBERGER:
                return (Constants.CANTEEN_ERZEBERGER, 1)
            case Constants.API_ABBREVIATIONS_CANTEEN_GOTTESAUE:
                return (Constants.CANTEEN_GOTTESAUE, 2)
            case Constants.API_ABBREVIATIONS_CANTEEN_HOLZGARTEN:
                return (Constants.CANTEEN_HOLZGARTEN, 3)
            case Constants.API_ABBREVIATIONS_CANTEEN_MOLTKE:
                return (Constants.CANTEEN_MOLTKE, 4)
            case Constants.API_ABBREVIATIONS_CANTEEN_TIEFENBRONNER:
                return (Constants.CANTEEN_TIEFENBRONNER, 5)
        case Constants.API_ABBREVIATIONS_CANTEEN_CAFETERIA_MOLTKE:
            	return (Constants.CANTEEN_CAFETERIA_MOLTKE, 6)
            default:
                return (shortName, 7)
        }
    }
}

