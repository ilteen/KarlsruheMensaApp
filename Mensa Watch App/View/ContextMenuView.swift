//
//  ContextMenuView.swift
//  Watch Mensa Extension
//
//  Created by Philipp on 16.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct ContextMenuView: View {
    
    @Binding var daySelection: Double
    @Binding var showDatePicker: Bool
    
    var body: some View {
        VStack {
            if (Int(self.daySelection) - 1 >= 0) {
                Button(action: {
                    self.daySelection -= 1.0
                    self.showDatePicker = false
                }) {
                    HStack {
                        Text(getTitleBarString(daySelection: Int(self.daySelection - 1.0)))
                        Image(systemName: Constants.WATCH_ARROW_LEFT).font(.system(size: 25)).foregroundColor(Color.green)
                    }
                }
            }
            if (Int(self.daySelection) + 1 <= 6) {
                Button(action: {
                    self.daySelection += 1.0
                    self.showDatePicker = false
                }) {
                    HStack {
                        Text(getTitleBarString(daySelection: Int(self.daySelection + 1.0)))
                        Image(systemName: Constants.WATCH_ARROW_RIGHT).font(.system(size: 25)).foregroundColor(Color.green)
                    }
                }
            }
            if (Int(self.daySelection) >= 1) {
                Button(action: {
                    self.daySelection = 0.0
                    self.showDatePicker = false
                }) {
                    HStack {
                        Text(getTitleBarString(daySelection: 0))
                        Image(systemName: Constants.WATCH_CALENDAR_IMAGE).font(.system(size: 25)).foregroundColor(Color.green)
                    }
                }
            }
        }
    }
}

struct ContextMenuView_Previews: PreviewProvider {
    static var previews: some View {
        ContextMenuView(daySelection: .constant(0), showDatePicker: .constant(false))
    }
}

