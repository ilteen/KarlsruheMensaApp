//
//  TitleBarView.swift
//  Mensa
//
//  Created by Philipp on 07.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct TitleBarView: View {

    @Binding var showingFoodRecommendation: Bool
    @Binding var showingSettings: Bool
    @Binding var canteenSelection: Int
    let canteens: [Canteen]
    @Binding var priceGroup: Int
    
    let accentColor = Constants.COLOR_ACCENT
 
    
    var body: some View {
        HStack {
            
            Button(action: {
                self.showingFoodRecommendation = true
            }) {
                Image(systemName: Constants.IMAGE_FOOD_RECOMMENDATION).font(.system(size: 25)).foregroundColor(self.accentColor)
            }.padding(.leading, 15)
                .sheet(isPresented: $showingFoodRecommendation, onDismiss: {
                self.showingFoodRecommendation = false
            }) {
                FoodRecommendationView(showingFoodRecommendation: self.$showingFoodRecommendation)
            }
            
            Spacer()
            
            if (canteens.isEmpty) {
            	Text("").font(.system(size: 20)).bold()
            }
            else {
            	Text(self.canteens[self.canteenSelection].name).font(.system(size: 20)).bold()
            }
            
            Spacer()
            
            Button(action: {
               self.showingSettings = true
            }) {
                Image(systemName: Constants.IMAGE_SETTINGS).font(.system(size: 25)).foregroundColor(self.accentColor)
            }.padding(.trailing, 15)
                .sheet(isPresented: $showingSettings, onDismiss: {
                self.showingSettings = false
            }) {
                SettingsView(showingSettings: self.$showingSettings, canteens: self.canteens, canteenSelection: self.$canteenSelection, priceGroudSelection: self.$priceGroup).accentColor(self.accentColor)
            }
        }
    }
}

struct TitleBarView_Previews: PreviewProvider {
    static var previews: some View {
        TitleBarView(showingFoodRecommendation: .constant(false), showingSettings: .constant(false), canteenSelection: .constant(0), canteens: [], priceGroup: .constant(0))
    }
}
