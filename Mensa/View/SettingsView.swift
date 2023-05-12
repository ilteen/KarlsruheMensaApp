//
//  SettingsView.swift
//  Mensa
//
//  Created by Philipp on 08.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var settings = SettingsViewModel.shared
    let canteen: Canteen? = CanteenViewModel.shared.canteen
    @StateObject var connectivityRequestHandler = ConnectivityRequestHandler()
    
    let accentColor = Constants.COLOR_ACCENT
    
    var body: some View {
        
        NavigationView {
            Form {
                if (canteen ==  nil) {
                    Picker(selection: self.$settings.canteenSelection, label: Text(Constants.CANTEEN)) {
                        Text(Constants.EMPTY)
                    }
                }
                else {
                    Picker(selection: self.$settings.canteenSelection.onChange(saveCanteenSelection), label: Text(Constants.CANTEEN)) {
                        ForEach(Canteens.allCases, id: \.self) {canteen in
                            Text(canteen.rawValue)
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
                    
                    Toggle(isOn: self.$settings.onlyVegan) {
                        Text("only vegan")
                    }
                    Toggle(isOn: self.$settings.onlyVegetarian) {
                        Text("only vegetarian")
                    }.disabled(self.settings.onlyVegan)
                    Toggle(isOn: self.$settings.noBeef) {
                        Text("no beef")
                    }.disabled(self.settings.onlyVegan || self.settings.onlyVegetarian)
                    Toggle(isOn: self.$settings.noPork) {
                        Text("no pork")
                    }.disabled(self.settings.onlyVegan || self.settings.onlyVegetarian)
                    Toggle(isOn: self.$settings.noFish) {
                        Text("no fish")
                    }.disabled(self.settings.onlyVegan || self.settings.onlyVegetarian)
                    
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
    
    func saveCanteenSelection(_ tag: Canteens) {
        self.settings.canteenSelection = tag
        UserDefaults.standard.set(tag.rawValue, forKey: Constants.KEY_CHOSEN_CANTEEN)
        self.connectivityRequestHandler.sendUpdatedCanteenSelectionToWatch(canteenSelection: tag)
    }
 
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

