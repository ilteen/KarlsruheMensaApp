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
    @ObservedObject var canteens: Canteens
    @State var showAlert: Bool
    @State var loading = true
    @State var dayOffset: Int = 0
    @State var dateOfLastFetching = Date()
    @ObservedObject var foodClassViewModel = FoodClassViewModel(onlyVegan: UserDefaults.standard.bool(forKey: "onlyVegan"), onlyVegetarian: UserDefaults.standard.bool(forKey: "onlyVegetarian"), noPork: UserDefaults.standard.bool(forKey: "noPork"), noBeef: UserDefaults.standard.bool(forKey: "noBeef"), noFish: UserDefaults.standard.bool(forKey: "noFish"))
    
    var body: some View {
        
        VStack (spacing: 0) {
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all).opacity(0.1)
                VStack {
                    if (canteens.fetchingFailed()) {
                        TitleBarView(showingSettings: self.$showSettings, canteenSelection: .constant(0), canteens: [], priceGroup: .constant(0), foodClassViewModel: self.foodClassViewModel)
                            .padding(.bottom, 10)
                            .padding(.top, 10)
                    }
                    else {
                        TitleBarView(showingSettings: self.$showSettings, canteenSelection: self.$canteenSelection, canteens: self.canteens.canteens!, priceGroup: self.$priceGroupSelection, foodClassViewModel: self.foodClassViewModel)
                            .padding(.bottom, 10)
                            .padding(.top, 10)
                    }
                    
                    WeekDays(selection: self.$daySelection, date: self.$dateOfLastFetching, accentColor: Constants.COLOR_ACCENT)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
                .padding(.bottom, 10)
            }
            .frame(maxHeight: 140)
            
            Divider()
 
            if (canteens.fetchingFailed()) {
                ZStack {
                    SwipeView(daySelection: self.$daySelection, canteenSelection: self.$canteenSelection, canteens: Canteens(canteens: nil), priceGroup: self.$priceGroupSelection, dayOffset: .constant(0), foodClassViewModel: self.foodClassViewModel).blur(radius: self.loading ? 3 : 0)
                }
            }
            else {
                SwipeView(daySelection: self.$daySelection, canteenSelection: self.$canteenSelection, canteens: self.canteens, priceGroup: self.$priceGroupSelection, dayOffset: self.$dayOffset, foodClassViewModel: self.foodClassViewModel)
            }
        }
        //fetch food from API
        .onAppear(perform: {
            Repository().get { (fetchedCanteens) in
                //if get call didn't result in desired answer, e.g. no internet connection
                if  (fetchedCanteens == nil) {
                    self.showAlert = true
                }
                else {
                    //self.canteens = canteens
                    self.canteens.canteens = fetchedCanteens
                    self.loading = false
                }
            }
        })
        //show alert when no internet connection available
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text(Constants.NO_INTERNET), message: Text(Constants.CONNECT), dismissButton: Alert.Button.default(
                    Text(Constants.OKAY), action:  {
                        self.showAlert = false
                        exit(-1)
                    }))
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            //check if date of last fetch is the same as today
            
            let calendar = Calendar.current
            
            if (!calendar.isDateInToday(self.dateOfLastFetching)) {
                
                // Replace the hour (time) of both dates with 00:00
                let today = calendar.startOfDay(for: Date())
                let lastFetch = calendar.startOfDay(for: self.dateOfLastFetching)
                let daysSinceLastFetching = calendar.dateComponents([.day], from: lastFetch, to: today).day ?? 0

                //refreshes WeekDays datepicker
                self.dateOfLastFetching = Date()
                self.daySelection = 0
                
                //refreshes food of current day
                self.dayOffset = daysSinceLastFetching
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(canteens: Canteens(canteens: nil), showAlert: false)
    }
}
