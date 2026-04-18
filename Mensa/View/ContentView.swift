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
    @ObservedObject var viewModel = ViewModel.shared
    @EnvironmentObject private var watchConnectivity: WatchConnectivityHandler
    
    var body: some View {
        ZStack {
            Color(.systemBackground).ignoresSafeArea()
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
                    .padding(.bottom, 0)
                }
                .frame(height: 156)
                
                Divider()
                
                ZStack {
                    SwipeView(daySelection: self.$daySelection).blur(radius: self.viewModel.loading ? 3 : 0)
                    
                    if (self.viewModel.loading) {ProgressView().progressViewStyle(CircularProgressViewStyle())}
                }
            }
        }
        .onAppear {
            Repository.shared.get()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            Repository.shared.get()
        }
        .alert(Constants.NO_INTERNET, isPresented: self.$viewModel.showAlert) {
            Button(Constants.TRY_AGAIN) {
                Repository.shared.get(refetch: true)
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text(Constants.CONNECT)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
