//
//  Canteens.swift
//  Mensa
//
//  Created by Philipp on 17.08.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import Foundation

class Canteens: ObservableObject {
    @Published var canteens: [Canteen]?
    @Published var dateOfLastFetching: Date
    
    init(canteens: [Canteen]?) {
        self.canteens = canteens
        self.dateOfLastFetching = Date()
    }
    
    func fetchingFailed() -> Bool {
        return self.canteens == nil
    }
    
    func getFoodLines(selectedCanteen: Int, selectedDay: Int) -> [FoodLine] {
        return self.canteens?[selectedCanteen].foodOnDayX[selectedDay] ?? []
    }
}
