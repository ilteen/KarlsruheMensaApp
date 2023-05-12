//
//  Food.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct Food: Codable {
    var name: String
    var bio: Bool
    var allergens: [String]
    var prices: [Float]
    var foodClass: FoodClass
    var priceInfo: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case bio
        case allergens
        case prices
        case foodClass
        case priceInfo
    }
    
    init(name: String, bio: Bool, allergens: [String], prices: [Float], foodClass: FoodClass) {
        self.name = name
        self.bio = bio
        self.allergens = allergens
        self.prices = prices
        self.foodClass = foodClass
        self.priceInfo = Constants.EMPTY
    }
    
    init(closingText: String) {
        self.name = Constants.EMPTY
        self.bio = false
        self.allergens = []
        self.prices = []
        self.foodClass = FoodClass.vegan
        self.priceInfo = Constants.EMPTY
    }
    
    init(foodModel: FoodModel) {
        self.name = foodModel.meal + Constants.SPACE + foodModel.dish
        self.bio = foodModel.bio
        self.allergens = foodModel.add
        self.prices = [foodModel.price_1, foodModel.price_2, foodModel.price_3, foodModel.price_4]
        self.foodClass = foodModel.fish ? FoodClass.fish : foodModel.pork ? FoodClass.pork : foodModel.pork_aw ? FoodClass.porkLocal : foodModel.cow ? FoodClass.beef : foodModel.cow_aw ? FoodClass.beefLocal : foodModel.vegan ? FoodClass.vegan : FoodClass.nothing
        self.priceInfo = foodModel.info
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.bio = try container.decode(Bool.self, forKey: .bio)
        self.allergens = try container.decode([String].self, forKey: .allergens)
        self.prices = try container.decode([Float].self, forKey: .prices)
        self.foodClass = try container.decode(FoodClass.self, forKey: .foodClass)
        self.priceInfo = try container.decode(String.self, forKey: .priceInfo)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(bio, forKey: .bio)
        try container.encode(allergens, forKey: .allergens)
        try container.encode(prices, forKey: .prices)
        try container.encode(foodClass, forKey: .foodClass)
        try container.encode(priceInfo, forKey: .priceInfo)
    }
}


enum FoodClass: Codable {
    case vegetarian
    case vegan
    case beef
    case beefLocal
    case pork
    case porkLocal
    case fish
    case nothing
}
