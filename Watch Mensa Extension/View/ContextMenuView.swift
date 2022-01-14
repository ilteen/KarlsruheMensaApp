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
        Group {
            if (Int(self.daySelection) - 1 >= 0) {
                Button(action: {
                    self.daySelection -= 1.0
                    self.showDatePicker = false
                }) {
                    VStack {
                        Image(systemName: "arrow.left").font(.system(size: 25)).foregroundColor(Color.green)
                        Text(getDateString(daySelection: Int(self.daySelection - 1.0)))
                    }
                }
            }
            if (Int(self.daySelection) + 1 <= 6) {
                Button(action: {
                    self.daySelection += 1.0
                    self.showDatePicker = false
                }) {
                    VStack {
                        Image(systemName: "arrow.right").font(.system(size: 25)).foregroundColor(Color.green)
                        Text(getDateString(daySelection: Int(self.daySelection + 1.0)))
                    }
                }
            }
            if (Int(self.daySelection) >= 1) {
                Button(action: {
                    self.daySelection = 0.0
                    self.showDatePicker = false
                }) {
                    VStack {
                        Image(systemName: "calendar").font(.system(size: 25)).foregroundColor(Color.green)
                        Text("Today")
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
