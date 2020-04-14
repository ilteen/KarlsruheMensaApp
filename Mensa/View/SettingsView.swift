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
    
    var body: some View {
        
        NavigationView {
            Form {
                if (canteens ==  nil) {
                    Picker(selection: $canteenSelection, label: Text("canteen")) {
                        Text("")
                    }
                }
                else {
                    Picker(selection: $canteenSelection.onChange(saveCanteenSelection), label: Text("canteen")) {
                        ForEach (0..<canteens!.count) { i in
                            Text(self.canteens![i].name).tag(i)
                        }
                    }
                }

                Picker(selection: $priceGroudSelection.onChange(savePriceGroupSelection), label: Text("PriceGroup")) {
                    Text("students").tag(0)
                    Text("guests").tag(1)
                    Text("attendants").tag(2)
                    Text("pupils").tag(3)
                }
                .navigationBarTitle(Text("Settings"), displayMode: .inline)
                .navigationBarItems(trailing: Button(action: {
                    self.showingSettings = false
                }) {
                    Text("Done").bold().foregroundColor(self.accentColor)
                })                
            }
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
        SettingsView(showingSettings: .constant(true), accentColor: .green, canteens: [], canteenSelection: .constant(0), priceGroudSelection: .constant(0))
    }
}

