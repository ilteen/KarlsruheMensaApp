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
    @State var showSettings = false
    @State var canteenSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_CANTEEN)
    @State var priceGroupSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
    @State var canteens: [Canteen]? = nil
    @State var showAlert: Bool
    @State var loading = true
    
    var body: some View {
        
        ZStack {
            if (canteens != nil) {
                Form {
                WatchFoodView(foodOnDayX: canteens![0].foodOnDayX, priceGroup: self.$priceGroupSelection, daySelection: self.$daySelection)
                }
            }
            else {
                Text(Constants.WATCH_LOADING)
            }
        }
        .contextMenu(menuItems: {
            ContextMenuView(daySelection: self.$daySelection)
        })
            .navigationBarTitle(Text(getTitleBarString(daySelection: Int(self.daySelection))))
            .accentColor(Color.green)
            .onAppear(perform: {
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
    return getSelectedDate(offset: Int(daySelection), onlyDay: true)
}

