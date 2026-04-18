//
//  SwipeView.swift
//  Mensa
//
//  Created by Philipp on 07.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct SwipeView: View {

    @Binding var daySelection: Int
    private let dayRange = 0..<Constants.DAYS_PER_WEEK
        
    var body: some View {
        TabView(selection: self.$daySelection) {
            ForEach(self.dayRange, id: \.self) { day in
                ZStack {
                    FoodView(day: day)
                        .tag(day)
                }
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.92), value: self.daySelection)
        .refreshable {
            ViewModel.shared.loading = true
            Repository.shared.get()
        }
        .onChange(of: self.daySelection) { newSelection in
            self.daySelection = max(self.dayRange.lowerBound, min(newSelection, self.dayRange.upperBound - 1))
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

struct SwipeView_Previews: PreviewProvider {
    static var previews: some View {
        SwipeView(daySelection: .constant(0))
    }
}
