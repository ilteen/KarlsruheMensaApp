//
//  Canteen.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

class Canteen: ObservableObject, Codable {
    @Published var name: String
    @Published var foodOnDayX: [Int: [FoodLine]]
    
    enum CodingKeys: String, CodingKey {
        case name
        case foodOnDayX
    }
    
    init(name: String, foodOnDayX: [Int: [FoodLine]]) {
        self.name = name
        self.foodOnDayX = foodOnDayX
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.foodOnDayX = try container.decode([Int: [FoodLine]].self, forKey: .foodOnDayX)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(foodOnDayX, forKey: .foodOnDayX)
    }
}


