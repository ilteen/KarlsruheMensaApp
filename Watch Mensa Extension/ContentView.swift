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
            
            
            if (Int(self.daySelection) - 1 > 0) {
                Button(action: {
                    self.daySelection -= 1.0
                }) {
                    VStack {
                        Image(systemName: "minus").font(.system(size: 25)).foregroundColor(Color.green)
                        if (Int(self.daySelection) == 2) {
                            Text("Tomorrow")
                        }
                        else if (Locale.current.languageCode?.prefix(2) == "de" && Int(self.daySelection) == 3) {
                            Text("Übermorgen")
                        }
                        else {
                            Text(getSelectedDate(offset: Int(self.daySelection) - 1, onlyDay: true))
                        }
                    }
                    
                }
            }
            if (Int(self.daySelection) + 1 <= 6) {
                Button(action: {
                    self.daySelection += 1.0
                }) {
                    VStack {
                        Image(systemName: "plus").font(.system(size: 25)).foregroundColor(Color.green)
                        
                        if (Int(self.daySelection) == 0) {
                            Text("Tomorrow")
                        }
                        else if (Locale.current.languageCode?.prefix(2) == "de" && Int(self.daySelection) == 1) {
                            Text("Übermorgen")
                        }
                        else {
                            Text(getSelectedDate(offset: Int(self.daySelection) + 1, onlyDay: true))
                        }
                        
                    }
                    
                }
                
            }
            
            if (Int(self.daySelection) != 0) {
                Button(action: {
                    self.daySelection = 0.0
                }) {
                    VStack {
                        Image(systemName: "calendar").font(.system(size: 25)).foregroundColor(Color.green)
                        Text("Today")
                    }
                    
                }
            }
            
        })
            .navigationBarTitle(Text("Canteen").foregroundColor(Color.green))
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
