//
//  WatchFoodView.swift
//  Watch Mensa Extension
//
//  Created by Philipp on 16.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct WatchFoodView: View {
    
    let foodOnDayX: [Int:[FoodLine]]
    @Binding var priceGroup: Int
    @Binding var daySelection: Double
    
    var body: some View {
        let foodLines = foodOnDayX[Int(daySelection)] ?? []
        return List {
            ForEach(foodLines) { foodLine in
                if (foodLine.closingText != "") {
                    Section(header: Text(foodLine.name)) {
                        ClosedRow(info: foodLine.closingText)
                    }
                }
                else {
                    if (!foodLine.foods.isEmpty) {
                        Section(header: Text(foodLine.name)) {
                            ForEach(foodLine.foods, id: \.name) { food in
                                FoodRow(food: food, priceGroup: self.$priceGroup)
                            }.padding(.bottom, 5)
                        }
                    }
                }
            }
        }
    }
}

struct WatchFoodView_Previews: PreviewProvider {
    static var previews: some View {
        WatchFoodView(foodOnDayX: [:], priceGroup: .constant(0), daySelection: .constant(0))
    }
}
