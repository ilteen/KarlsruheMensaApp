//
//  SettingsView.swift
//  Mensa
//
//  Created by Philipp on 08.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @Binding var showingSettings: Bool
    let accentColor: Color
    let canteens: [Canteen]?
    @Binding var canteenSelection: Int
    @Binding var priceGroudSelection: Int
    @ObservedObject var foodClassViewModel: FoodClassViewModel
    
    var body: some View {
        
        NavigationView {
            Form {
                if (canteens ==  nil) {
                    Picker(selection: $canteenSelection, label: Text("Canteen")) {
                        Text("")
                    }
                }
                else {
                    Picker(selection: $canteenSelection.onChange(saveCanteenSelection), label: Text("Canteen")) {
                        ForEach (0..<canteens!.count) { i in
                            Text(self.canteens![i].name).tag(i)
                        }
                    }
                }

                Picker(selection: $priceGroudSelection.onChange(savePriceGroupSelection), label: Text("PriceGroup")) {
                    Text("Students").tag(0)
                    Text("Guests").tag(1)
                    Text("Attendants").tag(2)
                    Text("Pupils").tag(3)
                }

                Section(header: Text("EXCLUDE DISHES")) {
                    
                        Toggle(isOn: self.$foodClassViewModel.onlyVegan) {
                            Text("only vegan")
                        }
                        Toggle(isOn: self.$foodClassViewModel.onlyVegetarian) {
                            Text("only vegetarian")
                        }.disabled(self.foodClassViewModel.onlyVegan)
                        Toggle(isOn: self.$foodClassViewModel.noBeef) {
                            Text("no beef")
                        }.disabled(self.foodClassViewModel.onlyVegan || self.foodClassViewModel.onlyVegetarian)
                        Toggle(isOn: self.$foodClassViewModel.noPork) {
                            Text("no pork")
                        }.disabled(self.foodClassViewModel.onlyVegan || self.foodClassViewModel.onlyVegetarian)
                        Toggle(isOn: self.$foodClassViewModel.noFish) {
                            Text("no fish")
                        }.disabled(self.foodClassViewModel.onlyVegan || self.foodClassViewModel.onlyVegetarian)
                    
                }
            }
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.showingSettings = false
            }) {
                Text("Done").bold().foregroundColor(self.accentColor)
            })
        }
    }
    
    func savePriceGroupSelection(_ tag: Int) {
        self.priceGroudSelection = tag
        UserDefaults.standard.set(tag, forKey: "chosenPriceGroup")
    }
    
    func saveCanteenSelection(_ tag: Int) {
        self.canteenSelection = tag
        UserDefaults.standard.set(tag, forKey: "chosenCanteen")
    }
 
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(showingSettings: .constant(true), accentColor: .green, canteens: [], canteenSelection: .constant(0), priceGroudSelection: .constant(0), foodClassViewModel: FoodClassViewModel())
    }
}

