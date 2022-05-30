//
//  Food.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

class Food: ObservableObject {
    var name: String
    var bio: Bool
    var allergens: [String]
    var prices: [Float]
    var foodClass: FoodClass
    var priceInfo: String
    @Published var favorite: Bool = false
    
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
}

enum FoodClass {
    case vegetarian
    case vegan
    case beef
    case beefLocal
    case pork
    case porkLocal
    case fish
    case nothing
}
