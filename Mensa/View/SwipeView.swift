//
//  SwipeView.swift
//  Mensa
//
//  Created by Philipp on 07.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SwipeView: View {

    @GestureState var offset: CGFloat = 0
    @Binding var daySelection: Int
    @Binding var canteenSelection: Int
    @ObservedObject var canteens: CanteenViewModel
    @Binding var priceGroup: Int
    @Binding var dayOffset: Int
 	@ObservedObject var foodClassViewModel: FoodClassViewModel
    
    let days = 0..<7
    let spacing: CGFloat = 10
        
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: self.spacing) {
                ForEach(self.days) { day in
                    FoodView(canteens: self.canteens, day: day, canteenSelection: self.$canteenSelection, dayOffset: self.$dayOffset, priceGroup: self.$priceGroup, foodClassViewModel: self.foodClassViewModel)
                    .frame(width: geometry.size.width)
                }
            }
            .offset(x: self.offset - CGFloat(self.daySelection) * (geometry.size.width + self.spacing))
            .frame(width: geometry.size.width, alignment: .leading)
            .animation(Animation.interactiveSpring(response: 0.5, dampingFraction: 1, blendDuration: 0.2))
            .gesture(
                DragGesture()
                    .updating($offset) {value, state, transaction in
                        state = value.translation.width
                    }
                    .onEnded({ value in
                        if -value.translation.width > geometry.size.width / 10, self.daySelection < self.days.count - 1 {
                            self.daySelection += 1
                        }
                        if value.translation.width > geometry.size.width / 10, self.daySelection > 0 {
                            self.daySelection -= 1
                        }
                    })
            )
        }
    }
}

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView(daySelection: .constant(0), canteenSelection: .constant(0), canteens: CanteenViewModel(canteens: nil), priceGroup: .constant(0), dayOffset: .constant(0), foodClassViewModel: FoodClassViewModel())
    }
}
