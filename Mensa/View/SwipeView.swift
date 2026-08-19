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
    @State private var selectedFood: Food?

    @ViewBuilder
    private var pagerContent: some View {
        TabView(selection: self.$daySelection) {
            ForEach(self.dayRange, id: \.self) { day in
                ZStack {
                    FoodView(
                        day: day,
                        onFoodSelected: { food in
                            self.selectedFood = food
                        }
                    )
                    .tag(day)
                }
            }
        }
    }
        
    var body: some View {
        ZStack {
            pagerContent
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.92), value: self.daySelection)
                .onChange(of: self.daySelection) { newSelection in
                    self.daySelection = max(self.dayRange.lowerBound, min(newSelection, self.dayRange.upperBound - 1))
                }
                .ignoresSafeArea(edges: .bottom)
                .refreshable {
                    ViewModel.shared.loading = true
                    Repository.shared.get()
                }

            Color.clear
                .frame(width: 0, height: 0)
                .sheet(item: $selectedFood) { food in
                    DetailedFoodView(food: food)
#if os(iOS)
                        .presentationContentInteraction(.resizes)
#endif
                }
        }
    }
}

private struct SwipeViewPreview: View {
    @State private var daySelection = 0

    var body: some View {
        SwipeView(daySelection: $daySelection)
    }
}

#Preview {
    SwipeViewPreview()
}
