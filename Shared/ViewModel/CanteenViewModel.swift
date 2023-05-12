//
//  Canteens.swift
//  Mensa
//
//  Created by Philipp on 17.08.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import Foundation

class CanteenViewModel: ObservableObject {

    static let shared = CanteenViewModel()
    
    private init() {}

    @Published var canteen: Canteen? = nil
    @Published var dateOfLastFetching: Date = Date()

    
    func areCanteensNil() -> Bool {
        return self.canteen == nil
    }
    
    func setCanteens(canteen: Canteen?, date: Date) {
        self.canteen = canteen
        self.dateOfLastFetching = date
    }
    
    func getFoodLines(selectedDay: Int) -> [FoodLine] {
        return self.canteen?.foodOnDayX[selectedDay] ?? []
    }
}
