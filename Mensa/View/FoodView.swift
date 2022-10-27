//
//  FoodView.swift
//  Mensa
//
//  Created by Philipp on 06.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI
 
struct FoodView: View {
    
    @ObservedObject var canteens: CanteenViewModel
    var day: Int
    @Binding var canteenSelection: Int
    @Binding var dayOffset: Int
    @Binding var priceGroup: Int
   	@ObservedObject var foodClassViewModel: FoodClassViewModel
    
    var body: some View {
        List {
            let foodLines = self.canteens.getFoodLines(selectedCanteen: self.canteenSelection, selectedDay: day + self.dayOffset)
            ForEach(foodLines) { foodLine in
                //foodlines that are closed are handled separately
                if ((foodLine.closingText != Constants.EMPTY) || foodLine.foods.isEmpty) {
                    if (foodLine.foods.isEmpty) {
                        Section(header: Text(foodLine.name + Constants.DASH + Constants.FOOD_LINE_CLOSED)) {
                            ClosedRow(info: Constants.DASH)
                        }
                    }
                    else {
                        Section(header: Text(foodLine.name)) {
                            ClosedRow(info: foodLine.closingText)
                        }
                    }
                }
                else {
                    
                    let foods = removeUnwantedFood(foods: foodLine.foods, foodClassViewModel: self.foodClassViewModel)
                    
                    if (!foods.isEmpty) {
                        Section(header: Text(foodLine.name)) {
                            ForEach(foods, id: \.name) { food in
                                FoodRow(canteens: canteens, food: food, priceGroup: self.$priceGroup)
                                
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
        FoodView(canteens: CanteenViewModel(canteens: nil), day: 0, canteenSelection: .constant(0), dayOffset: .constant(0), priceGroup: .constant(0), foodClassViewModel: FoodClassViewModel())
    }
}

struct FoodRow: View {
    var canteens: CanteenViewModel? = nil
    @ObservedObject var food: Food
    @Binding var priceGroup: Int
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text(food.name)
                    .padding(.bottom, 5)
                    .fixedSize(horizontal: false, vertical: true)
        
                HStack {
                    if (food.foodClass != FoodClass.nothing) {
                        Text(NSLocalizedString(String(describing: food.foodClass), comment: Constants.EMPTY)).font(.system(size: 10)).italic()
                    }
                    if (!food.allergens.isEmpty) {
                        Text(allergensString(allergens: food.allergens)).font(.system(size: 10)).foregroundColor(Color.gray)
                    }
                }
            }
            
            Spacer()
            HStack {
                Image(systemName: food.favorite ? Constants.IMAGE_HEART_FILL : Constants.IMAGE_HEART)
                    .renderingMode(.template)
                    .foregroundColor(food.favorite ? Constants.COLOR_ACCENT : .gray)
                HStack(spacing: 0) {
                    Text(food.priceInfo + Constants.SPACE)
                    if (food.prices[self.priceGroup] != 0.0) {
                        Text(food.prices[self.priceGroup].Euro)
                    }
                }
            }
        } .onTapGesture {
            food.toggleFavorite()
            if(canteens != nil) {
                var i = 0
                while (i < Constants.CANTEEN_AMOUNT) {
                    var j = 0
                    while (j < Constants.DAYS_PER_WEEK) {
                        let foodLines = canteens!.getFoodLines(selectedCanteen: i, selectedDay: j)
                        foodLines.forEach {
                            $0.foods.forEach{
                                $0.initFavorite()
                            }
                        }
                        j += 1
                    }
                    i += 1
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
    var str = Constants.EMPTY
    
    for i in 0..<allergens.count {
        str.append(contentsOf: allergens[i])
        if (i != allergens.count - 1) {
            str.append(contentsOf: Constants.COMMA + Constants.SPACE)
        }
    }
    if (!str.isEmpty) {
        str.insert("[", at: str.startIndex)
        str.insert("]", at: str.endIndex)
    }
    return str
}

func removeUnwantedFood(foods: [Food], foodClassViewModel: FoodClassViewModel) -> [Food] {

    var result = [Food]()
    
    for food in foods {
        switch food.foodClass {
            case .vegetarian:
                if (!foodClassViewModel.onlyVegan) {result.append(food)}
            
            case .pork, .porkLocal:
                if (!(foodClassViewModel.noPork || foodClassViewModel.onlyVegetarian || foodClassViewModel.onlyVegan)) {result.append(food)}
            
            case .beef, .beefLocal:
                if (!(foodClassViewModel.noBeef || foodClassViewModel.onlyVegetarian || foodClassViewModel.onlyVegan)) {result.append(food)}
            
            case .fish:
                if (!(foodClassViewModel.noFish || foodClassViewModel.onlyVegetarian || foodClassViewModel.onlyVegan)) {result.append(food)}
            default: result.append(food)
        }
    }
    return result
}
