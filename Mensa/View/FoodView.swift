//
//  FoodView.swift
//  Mensa
//
//  Created by Philipp on 06.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI
 
struct FoodView: View {
    @ObservedObject var viewModel = ViewModel.shared
    var day: Int
    
    @State private var selectedFood: Food? = nil
    
    var body: some View {
        List {
            let foodLines = self.viewModel.getFoodLines(selectedDay: day)
            ForEach(foodLines) { foodLine in
                // Foodlines that are closed are handled separately
                if ((foodLine.closingText != Constants.EMPTY) || foodLine.foods.isEmpty) {
                    if (foodLine.foods.isEmpty) {
                        Section(header: Text(foodLine.name + Constants.DASH + Constants.FOOD_LINE_CLOSED)) {
                            ClosedRow(info: Constants.DASH)
                        }
                    } else {
                        Section(header: Text(foodLine.name)) {
                            ClosedRow(info: foodLine.closingText)
                        }
                    }
                } else {
                    let foods = removeUnwantedFood(foods: foodLine.foods)

                    if (!foods.isEmpty) {
                        Section(header: Text(foodLine.name)) {
                            ForEach(foods, id: \.name) { food in
                                FoodRow(food: food, priceGroup: self.$viewModel.priceGroupSelection)
                            }
                            .padding(.bottom, 5)
                        }
                    }
                }
            }
        }
    }
}


struct FoodView_Previews: PreviewProvider {
    static var previews: some View {
        FoodView(day: 0)
    }
}
