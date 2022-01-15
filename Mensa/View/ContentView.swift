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
    @State var showFoodRecommendation = false
    @State var showSettings = false
    @State var showInfo = false
    @State var canteenSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_CANTEEN)
    @State var priceGroupSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
    @ObservedObject var canteenViewModel: CanteenViewModel = CanteenViewModel.viewModel
    @State var showAlert: Bool
    @State var loading = true
    @State var dayOffset: Int = 0
    @ObservedObject var foodClassViewModel = FoodClassViewModel(onlyVegan: UserDefaults.standard.bool(forKey: "onlyVegan"), onlyVegetarian: UserDefaults.standard.bool(forKey: "onlyVegetarian"), noPork: UserDefaults.standard.bool(forKey: "noPork"), noBeef: UserDefaults.standard.bool(forKey: "noBeef"), noFish: UserDefaults.standard.bool(forKey: "noFish"))
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all).opacity(0.1)
                VStack {
                    if (canteenViewModel.areCanteensNil()) {
                        TitleBarView(showingSettings: self.$showSettings, showingInfo: self.$showInfo, canteenSelection: .constant(0), canteens: [], priceGroup: .constant(0), foodClassViewModel: self.foodClassViewModel)
                            .padding(.bottom, 10)
                            .padding(.top, 10)
                    }

                    WeekDays(selection: self.$daySelection, accentColor: Constants.COLOR_ACCENT)
                    else {
                        TitleBarView(showingSettings: self.$showSettings, showingInfo: self.$showInfo, canteenSelection: self.$canteenSelection, canteens: self.canteenViewModel.canteens!, priceGroup: self.$priceGroupSelection, foodClassViewModel: self.foodClassViewModel)
                            .padding(.bottom, 10)
                            .padding(.top, 10)
                    }
                    
                    WeekDays(selection: self.$daySelection, date: self.$canteenViewModel.dateOfLastFetching, accentColor: Constants.COLOR_ACCENT)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
                .padding(.bottom, 10)
            }
            .frame(maxHeight: 140)
            
            Divider()
            
            ZStack {
                if (canteenViewModel.areCanteensNil()) {
                        SwipeView(daySelection: self.$daySelection, canteenSelection: self.$canteenSelection, canteens: CanteenViewModel(canteens: nil), priceGroup: self.$priceGroupSelection, dayOffset: .constant(0), foodClassViewModel: self.foodClassViewModel).blur(radius: self.loading ? 3 : 0)
                }
                else {
                    SwipeView(daySelection: self.$daySelection, canteenSelection: self.$canteenSelection, canteens: self.canteenViewModel, priceGroup: self.$priceGroupSelection, dayOffset: self.$dayOffset, foodClassViewModel: self.foodClassViewModel)
                }
                if (self.loading) {ProgressView().progressViewStyle(CircularProgressViewStyle())}
            }
            
        }
        //fetch food from API
        .onAppear(perform: {
            Repository().get { (fetchedCanteens) in
                //if get call didn't result in desired answer, e.g. no internet connection
                if  (fetchedCanteens.areCanteensNil()) {
                    self.showAlert = true
                }
                else {
                    //self.canteens = canteens
                    self.canteenViewModel.canteens = fetchedCanteens.canteens
                    self.canteenViewModel.dateOfLastFetching = fetchedCanteens.dateOfLastFetching
                    self.loading = false
                    self.showAlert = false
                }
            }
        })
        //show alert when no internet connection available
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text(Constants.NO_INTERNET), message: Text(Constants.CONNECT), dismissButton: Alert.Button.default(
                Text(Constants.TRY_AGAIN), action:  {
                    Repository().get { (fetchedCanteens) in
                        //if get call didn't result in desired answer, e.g. no internet connection
                        if  (fetchedCanteens.areCanteensNil()) {
                            self.showAlert = true
                        }
                        else {
                            //self.canteens = canteens
                            self.canteenViewModel.canteens = fetchedCanteens.canteens
                            self.canteenViewModel.dateOfLastFetching = fetchedCanteens.dateOfLastFetching
                            self.loading = false
                            self.showAlert = false
                        }
                    }
                }))
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            /*
            Repository().get { (fetchedCanteens) in
                //if get call didn't result in desired answer, e.g. no internet connection
                if  (fetchedCanteens.areCanteensNil()) {
                    self.showAlert = true
                }
                else {
                    //self.canteens = canteens
                    self.canteenViewModel.canteens = fetchedCanteens.canteens
                    self.canteenViewModel.dateOfLastFetching = fetchedCanteens.dateOfLastFetching
                    self.loading = false
                }
            }
            */
            
            Repository().get { (fetchedCanteens) in
                //if get call didn't result in desired answer, e.g. no internet connection
                if  (fetchedCanteens.areCanteensNil()) {
                    self.showAlert = true
                }
                else {
                    //self.canteens = canteens
                    self.canteenViewModel.canteens = fetchedCanteens.canteens
                    self.canteenViewModel.dateOfLastFetching = fetchedCanteens.dateOfLastFetching
                    self.loading = false
                    self.showAlert = false
                }
            }
            
            
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(canteenViewModel: CanteenViewModel(canteens: nil), showAlert: false)
    }
}
