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
    @State private var showImagePreview = false
    
    var body: some View {
            VStack() {
                HStack(alignment: .top) {
#if !os(watchOS)
                    if let url = food.imageURL {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: 70, height: 70)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width:70, height: 70)
                                    .clipped()
                                    .cornerRadius(8)
                            case .failure(_):
                                Image(systemName: "photo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width:70, height:70)
                                    .foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                        .padding(.bottom, 4)
                        .onTapGesture {
                            showImagePreview = true
                        }
                        .sheet(isPresented: $showImagePreview) {
                            ImageView(name: self.food.name, imageURL: url)
                        }
                    }
#endif
                    
                    VStack {
                        HStack{
                            Text(food.name)
                                .padding(.bottom, 5)
                                .fixedSize(horizontal: false, vertical: true)
                            Spacer()
                        }
                        
                        HStack {
                            Text(NSLocalizedString(String(describing: food.foodClass), comment: Constants.EMPTY))
                                .font(.system(size: 10))
                                .italic()
                            
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
                            
                            if (!food.prices.isEmpty && food.prices[self.priceGroup] != 0.0) {
                                Text(food.prices[self.priceGroup].Euro)
                            }
                        }
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

#Preview {
    FoodRow(
        food: Food(name: "Schnitzel mit extrem langen Zutaten, Salat, Soße, Zitronenscheiben, lecker mit ganz viel Zutaten und viel Soße hmm fein", bio: true, allergens: ["Sa", "So", "We"], prices: [3.40, 3.40, 3.40], foodClass: FoodClass.vegan, nutritionalInfo: NutritionalInfo(energy: "1", proteins: "1", carbohydrates: "1", sugar: "1", fat: "1", saturatedFat: "1", salt: "1", co2Value: "1", co2Score: 1, waterValue: "1", waterScore: 1, animalWelfareScore: 1, rainforestScore: 1, environmentScore: 1), imageURL: URL("url.com")!),
        priceGroup: .constant(0)
    )
}

