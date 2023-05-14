//
//  Food.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

class Food: Codable, Identifiable, ObservableObject {
    var id = UUID()
    var name: String
    var bio: Bool
    var allergens: [String]
    var prices: [Float]
    var foodClass: FoodClass
    var priceInfo: String
    var nutritionalInfo: NutritionalInfo?
    @Published var showNutritionalInfo = false
    
    enum CodingKeys: String, CodingKey {
        case name
        case bio
        case allergens
        case prices
        case foodClass
        case priceInfo
        case nutritionalInfo
    }
    
    init(name: String, bio: Bool, allergens: [String], prices: [Float], foodClass: FoodClass, nutritionalInfo: NutritionalInfo?) {
        self.name = name
        self.bio = bio
        self.allergens = allergens
        self.prices = prices
        self.foodClass = foodClass
        self.priceInfo = Constants.EMPTY
        self.nutritionalInfo = nutritionalInfo
    }
    
    init(closingText: String) {
        self.name = Constants.EMPTY
        self.bio = false
        self.allergens = []
        self.prices = []
        self.foodClass = FoodClass.vegan
        self.priceInfo = Constants.EMPTY
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.bio = try container.decode(Bool.self, forKey: .bio)
        self.allergens = try container.decode([String].self, forKey: .allergens)
        self.prices = try container.decode([Float].self, forKey: .prices)
        self.foodClass = try container.decode(FoodClass.self, forKey: .foodClass)
        self.priceInfo = try container.decode(String.self, forKey: .priceInfo)
        self.nutritionalInfo = try container.decode(NutritionalInfo.self, forKey: .nutritionalInfo)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(bio, forKey: .bio)
        try container.encode(allergens, forKey: .allergens)
        try container.encode(prices, forKey: .prices)
        try container.encode(foodClass, forKey: .foodClass)
        try container.encode(priceInfo, forKey: .priceInfo)
        try container.encode(nutritionalInfo, forKey: .nutritionalInfo)
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
