//
//  TitleBarView.swift
//  Mensa
//
//  Created by Philipp on 07.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct TitleBarView: View {

    @Binding var showingSettings: Bool
    @Binding var canteenSelection: Int
    let canteens: [Canteen]
    @Binding var priceGroup: Int
    @ObservedObject var foodClassViewModel: FoodClassViewModel
    let accentColor = Constants.COLOR_ACCENT
 
    
    var body: some View {
        HStack {
            
            Button(action: {
            }) {
                Image(systemName: Constants.IMAGE_INFO).font(.system(size: 25)).foregroundColor(self.accentColor)
            }.padding(.leading, 15)
            
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
                SettingsView(showingSettings: self.$showingSettings, accentColor: self.accentColor, canteens: self.canteens, canteenSelection: self.$canteenSelection, priceGroudSelection: self.$priceGroup, foodClassViewModel: self.foodClassViewModel ).accentColor(self.accentColor)
            }
        }
    }
}

struct TitleBarView_Previews: PreviewProvider {
    static var previews: some View {
        TitleBarView(showingSettings: .constant(false), canteenSelection: .constant(0), accentColor: .green, canteens: [], priceGroup: .constant(0), foodClassViewModel: FoodClassViewModel())
    }
}
