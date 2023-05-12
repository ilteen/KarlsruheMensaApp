//
//  FoodLine.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct FoodLine: Identifiable, Comparable, Codable {
    var name: String
    var foods: [Food]
    var closingText: String
    var id: String { name }
    var order: Int = 0
    
    enum CodingKeys: String, CodingKey {
        case name
        case foods
        case closingText
        case order
    }
    
    init(name: String, foods: [Food]) {
        self.name = name
        self.foods = foods
        if foods.isEmpty {
            self.order += 20 // All closed foodlines will be displayed at the very bottom
        }
        self.closingText = Constants.EMPTY
    }
    
    init(name: String, closingText: String) {
        self.name = name
        self.foods = []
        self.closingText = closingText
    }
    
    static func < (lhs: FoodLine, rhs: FoodLine) -> Bool {
        return lhs.order < rhs.order
    }
    
    static func == (lhs: FoodLine, rhs: FoodLine) -> Bool {
        return lhs.name == rhs.name
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.foods = try container.decode([Food].self, forKey: .foods)
        self.closingText = try container.decode(String.self, forKey: .closingText)
        self.order = try container.decode(Int.self, forKey: .order)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(foods, forKey: .foods)
        try container.encode(closingText, forKey: .closingText)
        try container.encode(order, forKey: .order)
    }
}

