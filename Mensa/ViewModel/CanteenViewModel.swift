//
//  Canteens.swift
//  Mensa
//
//  Created by Philipp on 17.08.21.
//  Copyright © 2021 Philipp. All rights reserved.
//

import Foundation

class CanteenViewModel: ObservableObject {
    
    //singleton
    static var viewModel = CanteenViewModel(canteens: nil)
    
    @Published var canteens: [Canteen]? = nil
    @Published var dateOfLastFetching: Date
    
    init(canteens: [Canteen]?) {
        self.canteens = canteens
        self.dateOfLastFetching = Date()
    }
    
    func areCanteensNil() -> Bool {
        return self.canteens == nil
    }
    
    func setCanteens(canteens: [Canteen]?, date: Date) {
        self.canteens = canteens
        self.dateOfLastFetching = date
    }
    
    func getFoodLines(selectedCanteen: Int, selectedDay: Int) -> [FoodLine] {
        return self.canteens?[selectedCanteen].foodOnDayX[selectedDay] ?? []
    }
}
