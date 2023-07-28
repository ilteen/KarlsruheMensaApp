//
//  SettingsView.swift
//  Mensa
//
//  Created by Philipp on 08.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SettingsView: View {

    @ObservedObject var viewModel = ViewModel.shared
    @StateObject var watchConnectivity = WatchConnectivityHandler.shared
    let canteen: Canteen? = ViewModel.shared.canteen
    let accentColor = Constants.COLOR_ACCENT
    
    var body: some View {
        NavigationView {
            Form {
                if (canteen ==  nil) {
                    Picker(selection: self.$viewModel.canteenSelection, label: Text(Constants.CANTEEN)) {
                        Text(Constants.EMPTY)
                    }
                }
                else {
                    Picker(selection: self.$viewModel.canteenSelection.onChange(saveCanteenSelection), label: Text(Constants.CANTEEN)) {
                        ForEach(Canteens.allCases, id: \.self) {canteen in
                            Text(canteen.rawValue)
                        }
                    }
                }
                
                Picker(selection: self.$viewModel.priceGroupSelection.onChange(savePriceGroupSelection), label: Text(Constants.PRICE_GROUP)) {
                    Text(Constants.STUDENTS).tag(0)
                    Text(Constants.GUESTS).tag(1)
                    Text(Constants.ATTENDANTS).tag(2)
                    Text(Constants.PUPILS).tag(3)
                }
                
                Section(header: Text("EXCLUDE DISHES")) {
                    
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
            .navigationBarTitle(Text("Settings"), displayMode: .inline)
            .navigationBarItems(trailing: Button(action: {
                self.viewModel.showSettings = false
            }) {
                Text(Constants.DONE).bold().foregroundColor(self.accentColor)
            })
        }
    }
    
    func savePriceGroupSelection(_ tag: Int) {
        self.viewModel.priceGroupSelection = tag
        UserDefaults.standard.set(tag, forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
        self.watchConnectivity.sendUpdatedPriceGroupToWatch(priceGroup: tag)
    }
    
    func saveCanteenSelection(_ tag: Canteens) {
        self.viewModel.loading = true
        self.viewModel.canteenSelection = tag
        UserDefaults.standard.set(tag.rawValue, forKey: Constants.KEY_CHOSEN_CANTEEN)
        Repository.shared.get(refetch: true)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}

