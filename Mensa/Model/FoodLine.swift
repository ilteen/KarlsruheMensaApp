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
        if (foods.isEmpty) {self.order += 20} //all closed foodlines will be displayed at the very bottom
        self.closingText = Constants.EMPTY
    }
    
    init(shortName: String, closingText: String) {
        (self.name, self.order) = FoodLine.getNameAndOrder(shortName: shortName)
        self.order += 20 //all closed foodlines will be displayed at the very bottom
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
            case Constants.API_ABBREVIATIONS_LINE_1:
                return (Constants.FOOD_LINE_1, 0)
            case Constants.API_ABBREVIATIONS_LINE_2:
                return (Constants.FOOD_LINE_2, 1)
            case Constants.API_ABBREVIATIONS_LINE_3:
                return (Constants.FOOD_LINE_3, 2)
            case Constants.API_ABBREVIATIONS_LINE_4_5:
                return (Constants.FOOD_LINE_4_5, 3)
            case Constants.API_ABBREVIATIONS_LINE_UPDATE:
                return (Constants.FOOD_LINE_UPDATE, 4)
            case Constants.API_ABBREVIATIONS_WAHLESSEN_1:
                return (Constants.FOOD_WAHLESSEN_1, 5)
            case Constants.API_ABBREVIATIONS_WAHLESSEN_2:
                return (Constants.FOOD_WAHLESSEN_2, 6)
            case Constants.API_ABBREVIATIONS_WAHLESSEN_3:
                return (Constants.FOOD_WAHLESSEN_3, 7)
            case Constants.API_ABBREVIATIONS_GUT_UND_GUENSTIG:
                return (Constants.FOOD_GUT_UND_GUENSTIG, 8)
            case Constants.API_ABBREVIATIONS_GUT_UND_GUENSTIG_2:
                return (Constants.FOOD_GUT_UND_GUENSTIG_2, 9)
            case Constants.API_ABBREVIATIONS_PIZZA:
                return (Constants.FOOD_PIZZA, 10)
            case Constants.API_ABBREVIATIONS_PASTA:
                return (Constants.FOOD_PASTA, 11)
            case Constants.API_ABBREVIATIONS_SALAT_DESSERT:
                return (Constants.FOOD_SALAT_DESSERT, 12)
            case Constants.API_ABBREVIATIONS_AKTION:
                return (Constants.FOOD_AKTION, 13)
            case Constants.API_ABBREVIATIONS_CURRYQUEEN:
                return (Constants.FOOD_CURRYQUEEN, 14)
            case Constants.API_ABBREVIATIONS_BUFFET:
                return (Constants.FOOD_BUFFET, 15)
            case Constants.API_ABBREVIATIONS_SCHNITZELBAR:
                return (Constants.FOOD_SCHNITZELBAR, 16)
            case Constants.API_ABBREVIATIONS_HEISSTHEKE:
                return (Constants.FOOD_HEISSTHEKE, 17)
            case Constants.API_ABBREVIATIONS_CAFETERIA:
                return (Constants.FOOD_CAFETERIA, 18)
            case Constants.API_ABBREVIATIONS_ABEND:
                return (Constants.FOOD_ABEND, 19)
            default:
                return (shortName, 50)
        }
    }
}
