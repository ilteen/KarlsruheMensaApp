//
//  SettingsView.swift
//  Mensa
//
//  Created by Philipp on 08.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var settings = Settings.shared
    let canteens: [Canteen]? = CanteenViewModel.shared.canteens
    @ObservedObject var foodClassViewModel = FoodClassViewModel.shared
    @StateObject var connectivityRequestHandler = ConnectivityRequestHandler()
    
    let accentColor = Constants.COLOR_ACCENT
    
    var body: some View {
        
        NavigationView {
            Form {
                if (canteens ==  nil) {
                    Picker(selection: self.$settings.canteenSelection, label: Text(Constants.CANTEEN)) {
                        Text(Constants.EMPTY)
                    }
                }
                else {
                    Picker(selection: self.$settings.canteenSelection.onChange(saveCanteenSelection), label: Text(Constants.CANTEEN)) {
                        ForEach (0..<canteens!.count) { i in
                            Text(self.canteens![i].name).tag(i)
                        }
                    }
                }
                
                Picker(selection: self.$settings.priceGroupSelection.onChange(savePriceGroupSelection), label: Text(Constants.PRICE_GROUP)) {
                    Text(Constants.STUDENTS).tag(0)
                    Text(Constants.GUESTS).tag(1)
                    Text(Constants.ATTENDANTS).tag(2)
                    Text(Constants.PUPILS).tag(3)
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
                self.settings.showSettings = false
            }) {
                Text(Constants.DONE).bold().foregroundColor(self.accentColor)
            })
        }
    }
    
    func savePriceGroupSelection(_ tag: Int) {
        self.settings.priceGroupSelection = tag
        UserDefaults.standard.set(tag, forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
        self.connectivityRequestHandler.sendUpdatedPriceGroupToWatch(priceGroup: tag)
    }
    
    func saveCanteenSelection(_ tag: Int) {
        self.settings.canteenSelection = tag
        UserDefaults.standard.set(tag, forKey: Constants.KEY_CHOSEN_CANTEEN)
        self.connectivityRequestHandler.sendUpdatedCanteenSelectionToWatch(canteenSelection: tag)
    }
 
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView(foodClassViewModel: FoodClassViewModel.shared)
    }
}

