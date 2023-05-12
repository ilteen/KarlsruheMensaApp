//
//  TitleBarView.swift
//  Mensa
//
//  Created by Philipp on 07.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct TitleBarView: View {

    @ObservedObject var settings = Settings.shared
    @ObservedObject var canteenViewModel = CanteenViewModel.shared
    
    var body: some View {
        HStack {
            
            Spacer()
            
            if let canteen = self.canteenViewModel.canteen {
                Text(canteen.name).font(.system(size: 20)).bold()
            }
            else {
                Text("").font(.system(size: 20)).bold()
            }
            
            Spacer()
            
            Button(action: {
                self.settings.showSettings = true
            }) {
                Image(systemName: Constants.IMAGE_SETTINGS).font(.system(size: 25)).foregroundColor(Constants.COLOR_ACCENT)
            }.padding(.trailing, 15)
                .sheet(isPresented: $settings.showSettings, onDismiss: {
                    self.settings.showSettings = false
            }) {
                SettingsView().accentColor(Constants.COLOR_ACCENT)
            }
        }
    }
}

struct TitleBarView_Previews: PreviewProvider {
    static var previews: some View {
        TitleBarView()
    }
}
