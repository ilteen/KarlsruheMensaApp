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
    @State var canteenSelection = UserDefaults.standard.integer(forKey: "chosenCanteen")
    @State var priceGroupSelection = UserDefaults.standard.integer(forKey: "chosenPriceGroup")
    @State var canteens: [Canteen]? = nil
    @State var showAlert: Bool
    
    var body: some View {
        
        Form {
            if (canteens != nil) {
                WatchFoodView(foodOnDayX: canteens![0].foodOnDayX, priceGroup: self.$priceGroupSelection, daySelection: self.$daySelection)
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

func getDateString(daySelection: Int) -> String {
    if (Int(daySelection) == 0) {
        return NSLocalizedString(String(describing: "Today"), comment: "")
    }
    if (Int(daySelection) == 1) {
        return NSLocalizedString(String(describing: "Tomorrow"), comment: "")
    }
    else if (Locale.current.languageCode?.prefix(2) == "de" && Int(daySelection) == 2) {
        return("Übermorgen")
    }
    else {
        return getSelectedDate(offset: Int(daySelection), onlyDay: true)
    }
}

func getTitleBarString(daySelection: Int) -> String {
        if (Int(daySelection) == 0) {
            return NSLocalizedString(String(describing: "Today"), comment: "")
        }
        else if (Int(daySelection) == 1) {
            return NSLocalizedString(String(describing: "Tomorrow"), comment: "")
        }
            else if (Locale.current.languageCode?.prefix(2) == "de" && Int(daySelection) == 2) {
                return "Übermorgen"
            }
        else {
            return getSelectedDate(offset: Int(daySelection), onlyDay: true)
        }

}

