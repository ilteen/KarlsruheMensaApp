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
    @State var canteenSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_CANTEEN)
    @State var priceGroupSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
    @State var canteens: [Canteen]? = nil
    @State var showAlert: Bool
    @State var loading = true
    
    var body: some View {

        VStack (spacing: 0) {
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all).opacity(0.1)
                VStack {
                    if (canteens == nil) {
                        TitleBarView(showingSettings: self.$showSettings, canteenSelection: .constant(0), canteens: [], priceGroup: .constant(0))
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    }
                    else {
                        TitleBarView(showingSettings: self.$showSettings, canteenSelection: self.$canteenSelection, canteens: self.canteens!, priceGroup: self.$priceGroupSelection)
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    }

                    WeekDays(selection: self.$daySelection, accentColor: Constants.COLOR_ACCENT)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
                .padding(.bottom, 10)
            }
            .frame(maxHeight: 140)
            Divider()
            
            if (canteens == nil) {
                ZStack {
                    SwipeView(daySelection: self.$daySelection, canteenSelection: self.$canteenSelection, canteens: nil, priceGroup: self.$priceGroupSelection).blur(radius: self.loading ? 3 : 0)
                    ActivityIndicatorView(shouldAnimate: self.$loading)
                }
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
                    self.loading = false
                }
            }
        })
            .alert(isPresented: self.$showAlert) {
                Alert(title: Text(Constants.NO_INTERNET), message: Text(Constants.CONNECT), dismissButton: Alert.Button.default(
                    Text(Constants.OKAY), action:  {
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

