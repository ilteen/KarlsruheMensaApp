//
//  FoodRow.swift
//  Mensa
//
//  Created by Philipp on 13.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import SwiftUI

struct FoodRow: View {
    @ObservedObject var food: Food
    @Binding var priceGroup: Int
    
    var body: some View {
        
        VStack() {
            HStack {
                Text(food.name)
                    .padding(.bottom, 5)
                    .fixedSize(horizontal: false, vertical: true)
                
                Spacer()
                
                if (!food.prices.isEmpty && food.prices[self.priceGroup] != 0.0) {
                    Text(food.prices[self.priceGroup].Euro)
                }
            }
            
            if (food.foodClass != FoodClass.nothing || food.allergens.isEmpty) {            
                HStack {
                    if (food.foodClass != FoodClass.nothing) {
                        Text(NSLocalizedString(String(describing: food.foodClass), comment: Constants.EMPTY))
                            .font(.system(size: 10))
                            .italic()
                    }
                    
                    if (!food.allergens.isEmpty) {
                        Text(allergensString(allergens: food.allergens))
                            .font(.system(size: 10))
                            .foregroundColor(Color.gray)
                    }
                    
#if os(iOS)
                    if food.nutritionalInfo != nil {
                        Button(action: {
                            self.food.showNutritionalInfo.toggle()
                        }) {
                            if self.food.showNutritionalInfo {
                                Image(systemName: "chevron.up")
                                    .foregroundColor(Constants.COLOR_ACCENT)
                            }
                            else {
                                Image(systemName: "chevron.down")
                                    .foregroundColor(Constants.COLOR_ACCENT)
                            }
                        }
                    }
#endif
                    
                    Spacer()
                }
            }
            
#if os(iOS)
            if self.food.showNutritionalInfo {
                    NutritionalInfoView(food: food)
                        .padding(.top, 5)
            }
#endif
        }
        .transaction { transaction in
            transaction.animation = nil
        }
    }
}


struct ClosedRow: View {
    let info: String
    var body: some View {
        Text(info).font(.system(size: 12)).foregroundColor(Color.gray).frame(maxWidth: .infinity, alignment: .center)
    }
}
