//
//  SwipeView.swift
//  Mensa
//
//  Created by Philipp on 07.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SwipeView: View {

    @State private var offset: CGFloat = 0

    @Binding var daySelection: Int
    @Binding var canteenSelection: Int
    
    let canteens: [Canteen]?
    @Binding var priceGroup: Int
 
    
    let days = 0..<7
    let spacing: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: self.spacing) {
                ForEach(self.days) { day in
                    FoodView(foodLines: self.canteens?[self.canteenSelection].foodOnDayX[day] ?? [], priceGroup: self.$priceGroup)
                    .frame(width: geometry.size.width)
                }
            }
            .offset(x: self.offset - CGFloat(self.daySelection) * (geometry.size.width + self.spacing))
            .frame(width: geometry.size.width, alignment: .leading)
            .animation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.2))
            .gesture(
                DragGesture()
                    .onChanged({ value in
                        self.offset = value.translation.width
                    })
                    .onEnded({ value in
                        if -value.translation.width > geometry.size.width / 10, self.daySelection < self.days.count - 1 {
                            self.daySelection += 1
                        }
                        if value.translation.width > geometry.size.width / 10, self.daySelection > 0 {
                            self.daySelection -= 1
                        }
                        self.offset = .zero
                    })
            )
        }
    }
}

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView(daySelection: .constant(0), canteenSelection: .constant(0), canteens: nil, priceGroup: .constant(0))
    }
}
