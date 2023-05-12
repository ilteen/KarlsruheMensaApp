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
    @State var dayOffset: Int = 0
    @ObservedObject var canteenViewModel = CanteenViewModel.shared
    @ObservedObject var settings = SettingsViewModel.shared
    
    var body: some View {
        VStack (spacing: 0) {
            ZStack {
                Color.gray.edgesIgnoringSafeArea(.all).opacity(0.1)
                VStack {
                    TitleBarView()
                        .padding(.bottom, 10)
                        .padding(.top, 10)
                    
                    WeekDaysView(selection: self.$daySelection)
                        .padding(.leading, 10)
                        .padding(.trailing, 10)
                }
                .padding(.bottom, 10)
            }
            .frame(maxHeight: 140)
            
            Divider()
            
            ZStack {
                SwipeView(daySelection: self.$daySelection, dayOffset: .constant(0)).blur(radius: self.settings.loading ? 3 : 0)
                
                if (self.settings.loading) {ProgressView().progressViewStyle(CircularProgressViewStyle())}
            }
            
        }
        //fetch food from API
        .onAppear(perform: {
            Repository().fetch { (fetchedCanteens) in
                //if get call didn't result in desired answer, e.g. no internet connection
                if  (fetchedCanteens.areCanteensNil()) {
                    self.settings.showAlert = true
                }
                else {
                    //self.canteens = canteens
                    self.canteenViewModel.canteen = fetchedCanteens.canteen
                    self.canteenViewModel.dateOfLastFetching = fetchedCanteens.dateOfLastFetching
                    self.settings.loading = false
                    self.settings.showAlert = false
                }
            }
        })
        //show alert when no internet connection available
        .alert(isPresented: self.$settings.showAlert) {
            Alert(title: Text(Constants.NO_INTERNET), message: Text(Constants.CONNECT), dismissButton: Alert.Button.default(
                Text(Constants.TRY_AGAIN), action:  {
                    Repository().fetch { (fetchedCanteens) in
                        //if get call didn't result in desired answer, e.g. no internet connection
                        if  (fetchedCanteens.areCanteensNil()) {
                            self.settings.showAlert = true
                        }
                        else {
                            //self.canteens = canteens
                            self.canteenViewModel.canteen = fetchedCanteens.canteen
                            self.canteenViewModel.dateOfLastFetching = fetchedCanteens.dateOfLastFetching
                            self.settings.loading = false
                            self.settings.showAlert = false
                        }
                    }
                }))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
