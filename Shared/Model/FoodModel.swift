//
//  FoodModel.swift
//  Mensa
//
//  Created by Philipp on 11.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import Foundation

struct FoodModel: Codable {
    var meal: String
    var dish: String
    var bio: Bool
    var fish: Bool
    var pork: Bool
    var pork_aw: Bool
    var cow: Bool
    var cow_aw: Bool
    var vegan: Bool
    var veg: Bool
    var mensa_vit: Bool
    var price_1: Float
    var price_2: Float
    var price_3: Float
    var price_4: Float
    var price_flag: Int
    var add: [String]
    var info: String
}

