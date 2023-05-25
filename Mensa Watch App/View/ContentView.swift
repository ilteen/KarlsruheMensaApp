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
    @EnvironmentObject private var phoneMessaging: PhoneMessaging
    @ObservedObject var viewModel = ViewModel.shared
    
    var body: some View {
        ZStack {
            if (!viewModel.areCanteensNil()) {
                if (self.showDatePicker) {
                    ContextMenuView(daySelection: self.$daySelection, showDatePicker: self.$showDatePicker)
                }
                else {
                    WatchFoodView(foodOnDayX: viewModel.canteen!.foodOnDayX, priceGroup: self.$phoneMessaging.priceGroup, daySelection: self.$daySelection)
                }
            }
            else {
                Text(Constants.WATCH_LOADING)
            }
        }
        .navigationTitle(Text(getTitleBarString(daySelection: Int(self.daySelection))))
        .accentColor(Color.green)
        .onAppear {
            Repository.shared.get()
        }
        .onLongPressGesture {
            showDatePicker = !showDatePicker;
        }
        //TODO: not working ATM
//        .alert(isPresented: self.$viewModel.showAlert) {
//            Alert(title: Text(Constants.NO_INTERNET), message: Text(Constants.CONNECT), dismissButton: Alert.Button.default(
//                Text(Constants.TRY_AGAIN), action:  {
//                    self.viewModel.showAlert = false
//                    exit(-1)
//                }))
//        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
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

