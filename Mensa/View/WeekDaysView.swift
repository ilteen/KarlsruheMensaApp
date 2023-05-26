//
//  WeekDays.swift
//  Mensa
//
//  Created by Philipp on 03.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct WeekDaysView: View {
    
    @Binding var selection: Int
    @State private var currentDate = Date()
    @State private var nextSevenWorkingDays = [Date]()
    @State private var nextSevenWorkingDaysAbbreviations = [String]()
    @State private var nextSevenWorkingDaysDigits = [String]()
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 32) {
                if (!self.nextSevenWorkingDays.isEmpty && !self.nextSevenWorkingDaysAbbreviations.isEmpty && !self.nextSevenWorkingDaysDigits.isEmpty) {
                    ForEach(0..<7) { number in
                        VStack(spacing: 10) {
                            Text(self.nextSevenWorkingDaysAbbreviations[number])
                                .font(.system(size: 12))
                                .padding(.bottom, 3)
                            
                            //if a date is selected, this is indicated with a green circle around it
                            if (number == self.selection) {
                                Text(self.nextSevenWorkingDaysDigits[number])
                                    .font(.system(size: 18))
                                    .foregroundColor(.white).bold()
                                    .onTapGesture {
                                        self.selection = number
                                    }
                                    .background(Image(systemName: Constants.IMAGE_CIRCLE_FILL)
                                        .font(.system(size: 35))
                                        .foregroundColor(Constants.COLOR_ACCENT))
                            }
                            else {
                                //the current day is displayed in green
                                if (number == 0) {
                                    Text(self.nextSevenWorkingDaysDigits[number])
                                        .font(.system(size: 18))
                                        .foregroundColor(Constants.COLOR_ACCENT)
                                        .onTapGesture {
                                            self.selection = number
                                        }
                                }
                                else {
                                    Text(self.nextSevenWorkingDaysDigits[number])
                                        .font(.system(size: 18))
                                        .onTapGesture {
                                            self.selection = number
                                        }
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Text(getSelectedDateString(date: Date(), offset: self.selection, onlyDay: false))
                .font(.system(size: 17))
        }
        .onAppear {
            updateWorkingDays()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            updateWorkingDays()
        }
    }
    
    private func updateWorkingDays() {
        self.currentDate = Date()
        self.nextSevenWorkingDays = getNextSevenWorkingDays(date: self.currentDate)
        self.nextSevenWorkingDaysAbbreviations = Date.abbreviations(of: nextSevenWorkingDays)
        self.nextSevenWorkingDaysDigits = Date.digits(of: nextSevenWorkingDays).map { String($0) }
    }
}

struct WeekDays_Previews: PreviewProvider {
    static var previews: some View {
        WeekDaysView(selection: .constant(0))
    }
}
