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
                    Text(Constants.STAFF).tag(2)
                    Text(Constants.PUPILS).tag(3)
                }
                
                Section(header: Text(NSLocalizedString("EXCLUDE DISHES", comment: "Exclude dishes section title"))) {
                    
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
                
                Section(header: Text(NSLocalizedString("EXCLUDE ALLERGENS", comment: "Exclude allergens section title"))) {
                    NavigationLink {
                        AllergenFilterListView()
                    } label: {
                        HStack {
                            Text(NSLocalizedString("Filter Allergens", comment: "Open allergen filter list"))
                            Spacer()
                            if viewModel.excludedAllergenCodes.isEmpty {
                                Text(NSLocalizedString("None", comment: "Empty selection"))
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("\(viewModel.excludedAllergenCodes.count)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
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

struct AllergenFilterListView: View {
    @ObservedObject var viewModel = ViewModel.shared
    
    var body: some View {
        List {
            ForEach(Allergen.allCases, id: \.self) { allergen in
                Button {
                    toggle(allergen)
                } label: {
                    let selected = isExcluded(allergen)
                    HStack {
                        Text(allergen.code)
                            .font(.subheadline.monospaced().weight(.semibold))
                            .foregroundStyle(selected ? Constants.COLOR_ACCENT : .secondary)
                            .frame(minWidth: 34, alignment: .leading)
                        Text(allergen.localizedName)
                            .foregroundStyle(selected ? Constants.COLOR_ACCENT : .primary)
                        Spacer()
                        if selected {
                            Image(systemName: "checkmark")
                                .foregroundStyle(Constants.COLOR_ACCENT)
                        }
                    }
                }
            }
        }
        .navigationTitle(NSLocalizedString("Allergen Filters", comment: "Allergen filter screen title"))
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func isExcluded(_ allergen: Allergen) -> Bool {
        viewModel.excludedAllergenCodes.contains(allergen.rawValue)
    }
    
    private func toggle(_ allergen: Allergen) {
        var updated = Set(viewModel.excludedAllergenCodes)
        if updated.contains(allergen.rawValue) {
            updated.remove(allergen.rawValue)
        } else {
            updated.insert(allergen.rawValue)
        }
        viewModel.excludedAllergenCodes = Array(updated).sorted()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
