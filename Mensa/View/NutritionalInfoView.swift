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
        VStack(spacing: 10) {
            if let nutritionalInfo = food.nutritionalInfo {
                VStack(spacing: 0) {
                    NutritionRow(title: Constants.ENERGY, value: nutritionalInfo.energy)
                    NutritionRow(title: Constants.PROTEINS, value: nutritionalInfo.proteins)
                    NutritionRow(title: Constants.CARBOHYDRATES, value: nutritionalInfo.carbohydrates)
                    NutritionRow(title: Constants.SUGAR, value: nutritionalInfo.sugar)
                    NutritionRow(title: Constants.FAT, value: nutritionalInfo.fat)
                    NutritionRow(title: Constants.SATURATED_FAT, value: nutritionalInfo.saturatedFat)
                    NutritionRow(title: Constants.SALT, value: nutritionalInfo.salt, showDivider: false)
                }
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(.secondarySystemBackground))
                )
                
                EnvironmentRow(nutritionalInfo: nutritionalInfo)
            }
            else {
                Text(NSLocalizedString("No Info provided", comment: "No nutritional info fallback"))
            }
        }
    }
}

struct NutritionRow: View {
    let title: String
    let value: String
    var showDivider: Bool = true
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .firstTextBaseline) {
                Text(title)
                    .fontWeight(.semibold)
                    .foregroundStyle(.primary)
                
                Spacer()
                
                Text(value)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            
            if showDivider {
                Divider()
            }
        }
    }
}

struct EnvironmentRow: View {
    let nutritionalInfo: NutritionalInfo
    
    var body: some View {
        let envScore = nutritionalInfo.environmentScore
        let co2Value = nutritionalInfo.co2Value
        let co2Score = nutritionalInfo.co2Score
        let waterValue = nutritionalInfo.waterValue
        let waterScore = nutritionalInfo.waterScore
        let animalWelfare = nutritionalInfo.animalWelfareScore
        let rainforest = nutritionalInfo.rainforestScore
        
        VStack(spacing: 0) {
            StarRow(title: Constants.ENV_SCORE, value: nil, score: envScore)
            if co2Score != 0 {
                Divider()
                StarRow(title: Constants.CO2_VALUE, value: co2Value, score: co2Score)
            }
            Divider()
            StarRow(title: Constants.WATER_VALUE, value: waterValue, score: waterScore)
            Divider()
            StarRow(title: Constants.ANIMAL_WELFARE_SCORE, value: nil, score: animalWelfare)
            Divider()
            StarRow(title: Constants.RAINFOREST_SCORE, value: nil, score: rainforest)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct StarRow: View {
    let title: String
    let value: String?
    let score: Int
    
    var body: some View {
        HStack {
            Text(title)
                .fontWeight(.semibold)
            
            Spacer()
            
            if let value {
                Text(value)
                    .foregroundStyle(.secondary)
                    .padding(.trailing, 5)
            }
            
            ForEach(0..<3, id: \.self) { index in
                Image(systemName: index < score ? "star.fill" : "star")
                    .foregroundColor(Constants.COLOR_ACCENT)
            }
        }
        .padding(.vertical, 6)
    }
}


#Preview {
    let nutritionalInfo: NutritionalInfo? = NutritionalInfo(energy: "300 kJ" , proteins: "25 g" , carbohydrates: "30 g" , sugar: "10 g" , fat: "20 g" , saturatedFat: "34 g" , salt: "2 g" , co2Value: "100" , co2Score: 0 , waterValue: "300 l" , waterScore: 3 , animalWelfareScore: 3, rainforestScore: 2, environmentScore: 2)
    let food = Food(name: "Foodname", bio: true, allergens: ["We, Fi"], prices: [3.0], foodClass: .beef, nutritionalInfo: nutritionalInfo)
    NutritionalInfoView(food: food)
}
