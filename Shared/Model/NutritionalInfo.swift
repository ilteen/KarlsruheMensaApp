//
//  NutritionalInfo.swift
//  Mensa
//
//  Created by Philipp on 13.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import Foundation

struct NutritionalInfo: Codable {
    var energy: String
    var proteins: String
    var carbohydrates: String
    var sugar: String
    var fat: String
    var saturatedFat: String
    var salt: String
    var co2Value: String
    var co2Score: String
    var waterValue: String
    var waterScore: String
    var animalWelfareScore: String
    var rainforestScore: String
}
