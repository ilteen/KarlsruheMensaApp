//
//  TitleBarView.swift
//  Mensa
//
//  Created by Philipp on 07.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct TitleBarView: View {
    @ObservedObject var settings = ViewModel.shared
    
    var body: some View {
        ZStack {
            HStack {
                Spacer()
                
                Button(action: {
                    self.settings.showSettings = true
                }) {
                    Image(systemName: Constants.IMAGE_SETTINGS)
                        .font(.system(size: 25))
                        .foregroundColor(Constants.COLOR_ACCENT)
                }
                .padding(.trailing, 15)
                .sheet(isPresented: $settings.showSettings, onDismiss: {
                    self.settings.showSettings = false
                }) {
                    SettingsView().accentColor(Constants.COLOR_ACCENT)
                }
            }
            
            Text(settings.canteenSelection.rawValue)
                .font(.system(size: 20))
                .bold()
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
}

struct TitleBarView_Previews: PreviewProvider {
    static var previews: some View {
        TitleBarView()
    }
}
