//
//  FoodRecommendationView.swift
//  Mensa
//
//  Created by André Wilhelm on 16.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct FoodRecommendationView: View {
    @Binding var showingFoodRecommendation: Bool
    let accentColor: Color
    
    var body: some View {
        NavigationView {
            Text("Currywurst")
            .navigationBarTitle(Text("Food Recommendation"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                 self.showingFoodRecommendation = false
            }) {
                Text("Done").bold().foregroundColor(self.accentColor)
            })
        }
       
    }
}

struct FoodRecommendationView_Previews: PreviewProvider {
    static var previews: some View {
        FoodRecommendationView(showingFoodRecommendation: .constant(true), accentColor: .green)
    }
}
