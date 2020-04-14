//
//  ContentView.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var daySelection = 0
    @State var showSettings = false
    @State var canteenSelection = UserDefaults.standard.integer(forKey: "chosenCanteen")
    @State var priceGroupSelection = UserDefaults.standard.integer(forKey: "chosenPriceGroup")
    @State var canteens: [Canteen]? = nil
    @State var showAlert: Bool
    
    var body: some View {

        VStack (spacing: 0) {
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all).opacity(0.1)
                VStack {
                    if (canteens == nil) {
                        TitleBarView(showingSettings: self.$showSettings, canteenSelection: .constant(0), accentColor: .green, canteens: [], priceGroup: .constant(0))
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    }
                    else {
                        TitleBarView(showingSettings: self.$showSettings, canteenSelection: self.$canteenSelection, accentColor: .green, canteens: self.canteens!, priceGroup: self.$priceGroupSelection)
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    }

                    WeekDays(selection: self.$daySelection, accentColor: .green)

                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }.padding(.bottom, 10)
            }.frame(maxHeight: 140)
            Divider()
            
            if (canteens == nil) {
                SwipeView(daySelection: self.$daySelection, canteenSelection: self.$canteenSelection, canteens: nil, priceGroup: self.$priceGroupSelection)
            }
            else {
                SwipeView(daySelection: self.$daySelection, canteenSelection: self.$canteenSelection, canteens: canteens, priceGroup: self.$priceGroupSelection)
            }
        }.onAppear(perform: {
            Repository().get { (canteens) in
                //if get call didn't result in desired answer, e.g. no internet connection
                if  (canteens == nil) {
                    self.showAlert = true
                }
                else {
                	self.canteens = canteens!
                }
            }
        })
            .alert(isPresented: self.$showAlert) {
                Alert(title: Text("noInternet"), message: Text("connect"), dismissButton: Alert.Button.default(
                    Text("Okay"), action:  {
                        self.showAlert = false
                        exit(-1)
                }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(showAlert: false)
    }
}
