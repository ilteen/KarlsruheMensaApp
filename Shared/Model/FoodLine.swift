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
    var order: Int = 0
    
    init(name: String, foods: [Food]) {
        self.name = name
        self.foods = foods
        if (foods.isEmpty) {self.order += 20} //all closed foodlines will be displayed at the very bottom
        self.closingText = Constants.EMPTY
    }
    
    init(name: String, closingText: String) {
        self.name = name
        self.closingText = Constants.EMPTY
        self.foods = []
        self.closingText = closingText
    }
    
    static func < (lhs: FoodLine, rhs: FoodLine) -> Bool {
        return lhs.order < rhs.order
    }
    
    static func == (lhs: FoodLine, rhs: FoodLine) -> Bool {
        return lhs.name == rhs.name
    }
}
