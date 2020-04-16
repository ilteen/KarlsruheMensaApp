//
//  FoodClassView.swift
//  Mensa
//
//  Created by Philipp on 16.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI
import Combine

struct FoodClassView: View {
    
    @ObservedObject var viewModel: FoodClassViewModel
    
    var body: some View {
        NavigationView {
            Form {
                Toggle(isOn: self.$viewModel.onlyVegan) {
                    Text("only vegan")
                }
                Toggle(isOn: self.$viewModel.onlyVegetarian) {
                    Text("only vegetarian")
                }.disabled(self.viewModel.onlyVegan)
                Toggle(isOn: self.$viewModel.noBeef) {
                    Text("no beef")
                }.disabled(self.viewModel.onlyVegan || self.viewModel.onlyVegetarian)
                Toggle(isOn: self.$viewModel.noPork) {
                    Text("no pork")
                }.disabled(self.viewModel.onlyVegan || self.viewModel.onlyVegetarian)
                Toggle(isOn: self.$viewModel.noFish) {
                    Text("no fish")
                }.disabled(self.viewModel.onlyVegan || self.viewModel.onlyVegetarian)
            }
        }
    .navigationBarTitle("Test")
    }
}

struct FoodClassView_Previews: PreviewProvider {
    static var previews: some View {
        FoodClassView(viewModel: FoodClassViewModel())
    }
}
