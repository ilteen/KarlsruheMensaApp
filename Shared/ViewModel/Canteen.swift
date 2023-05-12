//
//  Canteen.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

class Canteen: ObservableObject {
    @Published var name: String
    @Published var foodOnDayX: [Int:[FoodLine]]
    
    init(name: String, foodOnDayX: [Int:[FoodLine]]) {
        self.name = name
        self.foodOnDayX = foodOnDayX
    }
}

