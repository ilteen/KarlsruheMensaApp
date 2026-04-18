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

    private var selectedDay: Int {
        Int(daySelection)
    }

    private var selectedDayFoodLines: [FoodLine] {
        foodOnDayX[selectedDay] ?? []
    }

    private var listIdentity: String {
        let contentSignature = selectedDayFoodLines.map { foodLine in
            let foods = foodLine.foods.map(\.name).joined(separator: "|")
            return "\(foodLine.name)#\(foodLine.closingText)#\(foods)"
        }.joined(separator: "||")
        return "\(selectedDay)::\(contentSignature)"
    }
    
    var body: some View {
        List {
            ForEach(Array(selectedDayFoodLines.enumerated()), id: \.offset) { _, foodLine in
                if (foodLine.closingText != Constants.EMPTY) {
                    Section(header: Text(foodLine.name)) {
                        ClosedRow(info: foodLine.closingText)
                    }
                }
                else {
                    if (!foodLine.foods.isEmpty) {
                        Section(header: Text(foodLine.name)) {
                            ForEach(foodLine.foods) { food in
                                FoodRow(food: food, priceGroup: self.$priceGroup)
                            }.padding(.bottom, 5)
                        }
                    }
                }
            }
        }
        .id(listIdentity)
    }
}

struct WatchFoodView_Previews: PreviewProvider {
    static var previews: some View {
        WatchFoodView(foodOnDayX: [:], priceGroup: .constant(0), daySelection: .constant(0))
    }
}
