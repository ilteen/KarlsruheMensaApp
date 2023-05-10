//
//  ContentView.swift
//  Watch Mensa Extension
//
//  Created by Philipp on 13.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

//
//  ContentView.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    
    @State var daySelection: Double = 0.0
    @State var showDatePicker: Bool = false
    @State var showSettings = false
    @StateObject var phoneMessaging = PhoneMessaging()
    @ObservedObject var canteenViewModel: CanteenViewModel = CanteenViewModel.viewModel
    @State var showAlert: Bool
    @State var loading = true
    
    var body: some View {
        
        ZStack {
            if (!canteenViewModel.areCanteensNil()) {
                if (self.showDatePicker) {
                    ContextMenuView(daySelection: self.$daySelection, showDatePicker: self.$showDatePicker)
                }
                else {
                    Form {
                        WatchFoodView(foodOnDayX: canteenViewModel.canteens![phoneMessaging.canteenSelection].foodOnDayX, priceGroup: self.$phoneMessaging.priceGroup, daySelection: self.$daySelection)
                    }
                }
                
            }
            else {
                Text(Constants.WATCH_LOADING)
            }
        }
        .navigationTitle(Text(getTitleBarString(daySelection: Int(self.daySelection))))
        .accentColor(Color.green)
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
                }
            }
        })
        .onLongPressGesture {
            showDatePicker = !showDatePicker;
        }
        .alert(isPresented: self.$showAlert) {
            Alert(title: Text(Constants.NO_INTERNET), message: Text(Constants.CONNECT), dismissButton: Alert.Button.default(
                Text(Constants.TRY_AGAIN), action:  {
                    self.showAlert = false
                    exit(-1)
                }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(canteenViewModel: CanteenViewModel(canteens: nil), showAlert: false)
    }
}

func getTitleBarString(daySelection: Int) -> String {
    
    let date = Date()
    let calendar = Calendar.autoupdatingCurrent
    
    if (!calendar.isDateInWeekend(date)) {
        if (Int(daySelection) == 0) {
            return Constants.WATCH_TODAY
        }
        else if (Int(daySelection) == 1) {
            return Constants.WATCH_TOMORROW
        }
        else if (Locale.current.languageCode?.prefix(2) == "de" && Int(daySelection) == 2) {
            return Constants.WATCH_DATOMORROW
        }
    }
    return getSelectedDateString(date: Date(), offset: Int(daySelection), onlyDay: true)
}

