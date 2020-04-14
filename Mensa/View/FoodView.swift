//
//  FoodView.swift
//  Mensa
//
//  Created by Philipp on 06.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI
 
struct FoodView: View {
    
    let foodLines: [FoodLine]
    @Binding var priceGroup: Int
    
    var body: some View {
        List {
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

struct FoodView_Previews: PreviewProvider {
    static var previews: some View {
        FoodView(foodLines: [], priceGroup: .constant(0))
    }
}

struct FoodRow: View {
    let food: Food
    @Binding var priceGroup: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(food.name).padding(.bottom, 5)
                HStack {
                    if (food.foodClass != FoodClass.nothing) {
                    	Text(NSLocalizedString(String(describing: food.foodClass), comment: "")).font(.system(size: 10)).italic()
                    }
                    if (!food.allergens.isEmpty) {
                        Text(allergensString(allergens: food.allergens)).font(.system(size: 10)).foregroundColor(Color.gray)
                    }
                }
            }
            Spacer()
            HStack(spacing: 0) {
                Text(food.priceInfo + " ")
                if (food.prices[self.priceGroup] != 0.0) {
                 	Text(food.prices[self.priceGroup].Euro)
                }
            }
        }
    }
}

struct ClosedRow: View {
    let info: String
    var body: some View {
        Text(info).font(.system(size: 12)).foregroundColor(Color.gray).frame(maxWidth: .infinity, alignment: .center)
    }
}

func allergensString(allergens: [String]) -> String {
    var str = ""
    
    for i in 0..<allergens.count {
        str.append(contentsOf: allergens[i])
        if (i != allergens.count - 1) {
            str.append(contentsOf: ", ")
        }
    }
    if (!str.isEmpty) {
        str.insert("[", at: str.startIndex)
        str.insert("]", at: str.endIndex)
    }
    return str
}
