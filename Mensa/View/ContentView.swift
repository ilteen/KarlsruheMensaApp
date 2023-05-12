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
    @ObservedObject var viewModel = ViewModel.shared
    
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
                SwipeView(daySelection: self.$daySelection).blur(radius: self.viewModel.loading ? 3 : 0)
                
                if (self.viewModel.loading) {ProgressView().progressViewStyle(CircularProgressViewStyle())}
            }
            
        }
        //fetch food from API
        .onAppear(perform: {
            Repository().fetch { (fetchedCanteens) in
                //if get call didn't result in desired answer, e.g. no internet connection
                if  (fetchedCanteens.areCanteensNil()) {
                    self.viewModel.showAlert = true
                }
                else {
                    //self.canteens = canteens
                    self.viewModel.canteen = fetchedCanteens.canteen
                    self.viewModel.dateOfLastFetching = fetchedCanteens.dateOfLastFetching
                    self.viewModel.loading = false
                    self.viewModel.showAlert = false
                }
            }
        })
        //show alert when no internet connection available
        .alert(isPresented: self.$viewModel.showAlert) {
            Alert(title: Text(Constants.NO_INTERNET), message: Text(Constants.CONNECT), dismissButton: Alert.Button.default(
                Text(Constants.TRY_AGAIN), action:  {
                    Repository().fetch { (fetchedCanteens) in
                        //if get call didn't result in desired answer, e.g. no internet connection
                        if  (fetchedCanteens.areCanteensNil()) {
                            self.viewModel.showAlert = true
                        }
                        else {
                            //self.canteens = canteens
                            self.viewModel.canteen = fetchedCanteens.canteen
                            self.viewModel.dateOfLastFetching = fetchedCanteens.dateOfLastFetching
                            self.viewModel.loading = false
                            self.viewModel.showAlert = false
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
