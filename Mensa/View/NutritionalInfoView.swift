//
//  NutritionInfoView.swift
//  Mensa
//
//  Created by Philipp on 13.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import SwiftUI

struct NutritionalInfoView: View {
    @ObservedObject var viewModel = ViewModel.shared
    @State var food: Food
    let accentColor = Constants.COLOR_ACCENT
    
    var body: some View {
        VStack(spacing: 5) {
            if let nutritionalInfo = food.nutritionalInfo {
                Group {
                    NutritionRow(title: Constants.ENERGY, value: nutritionalInfo.energy)
                    NutritionRow(title: Constants.PROTEINS, value: nutritionalInfo.proteins)
                    NutritionRow(title: Constants.CARBOHYDRATES, value: nutritionalInfo.carbohydrates)
                    NutritionRow(title: Constants.SUGAR, value: nutritionalInfo.sugar)
                    NutritionRow(title: Constants.FAT, value: nutritionalInfo.fat)
                    NutritionRow(title: Constants.SATURATED_FAT, value: nutritionalInfo.saturatedFat)
                    NutritionRow(title: Constants.SALT, value: nutritionalInfo.salt)
                }
                
                Divider()
                
                Group {
                    EnvironmentRow(nutritionalInfo: nutritionalInfo)
                }
            }
            else {
                Text("No Info provided") //TODO: change
            }
        }
    }
}

struct NutritionRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.bold)
            
            Spacer()
            
            Text(value)
        }
    }
}

struct EnvironmentRow: View {
    let nutritionalInfo: NutritionalInfo
    
    var body: some View {
        
        let env_score = nutritionalInfo.environmentScore
        let co2_value = nutritionalInfo.co2Value
        let co2_score = nutritionalInfo.co2Score
        let water_value = nutritionalInfo.waterValue
        let water_score = nutritionalInfo.waterScore
        let animalWelfare = nutritionalInfo.animalWelfareScore
        let rainforest = nutritionalInfo.rainforestScore
        
        VStack {
            HStack {
                Text(Constants.ENV_SCORE)
                    .fontWeight(.bold)
                
                Spacer()
                
                ForEach(0..<3) { index in
                    Image(systemName: index < env_score ? "star.fill" : "star")
                        .foregroundColor(Constants.COLOR_ACCENT)
                }
            }
            if co2_score != 0 {
                HStack {
                    Text(Constants.CO2_VALUE)
                        .fontWeight(.bold)
                    
                    Spacer()
                    
                    Text("\(co2_value)")
                        .padding(.trailing, 5)
                    
                    ForEach(0..<3) { index in
                        Image(systemName: index < co2_score ? "star.fill" : "star")
                            .foregroundColor(Constants.COLOR_ACCENT)
                    }
                    
                }
            }
            
            HStack {
                Text(Constants.WATER_VALUE)
                    .fontWeight(.bold)
                
                Spacer()
                
                Text("\(water_value)")
                    .padding(.trailing, 5)
                
                ForEach(0..<3) { index in
                    Image(systemName: index < water_score ? "star.fill" : "star")
                        .foregroundColor(Constants.COLOR_ACCENT)
                }
            }
            
            HStack {
                Text(Constants.ANIMAL_WELFARE_SCORE)
                    .fontWeight(.bold)
                
                Spacer()
                
                ForEach(0..<3) { index in
                    Image(systemName: index < animalWelfare ? "star.fill" : "star")
                        .foregroundColor(Constants.COLOR_ACCENT)
                }
            }
            
            HStack {
                Text(Constants.RAINFOREST_SCORE)
                    .fontWeight(.bold)
                
                Spacer()
                
                ForEach(0..<3) { index in
                    Image(systemName: index < rainforest ? "star.fill" : "star")
                        .foregroundColor(Constants.COLOR_ACCENT)
                }
            }
        }
        
    }
}


struct NutritionInfoView_Previews: PreviewProvider {
    static var previews: some View {
        let nutritionalInfo: NutritionalInfo? = NutritionalInfo(energy: "300 kJ" , proteins: "25 g" , carbohydrates: "30 g" , sugar: "10 g" , fat: "20 g" , saturatedFat: "34 g" , salt: "2 g" , co2Value: "100" , co2Score: 0 , waterValue: "300 l" , waterScore: 3 , animalWelfareScore: 3, rainforestScore: 2, environmentScore: 2)
        let food = Food(name: "Foodname", bio: true, allergens: ["We, Fi"], prices: [3.0], foodClass: .beef, nutritionalInfo: nutritionalInfo)
        NutritionalInfoView(food: food)
        //NutritionalInfoView(food: Food(closingText: ""))
    }
}
