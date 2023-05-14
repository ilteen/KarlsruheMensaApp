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
    
    var body: some View {
        
        let nextSevenWorkingDays = getNextSevenWorkingDays(date: Date())
        let nextSevenWorkingDaysAbbreviations = Date.abbreviations(of: nextSevenWorkingDays)
        let nextSevenWorkingDaysDigits = Date.digits(of: nextSevenWorkingDays).map { String($0) }
        
        VStack(spacing: 10) {
            HStack(spacing: 32) {
                ForEach(0..<7) { number in
                    VStack(spacing: 10) {
                        Text(nextSevenWorkingDaysAbbreviations[number])
                            .font(.system(size: 12))
                            .padding(.bottom, 3)
                        
                        //if a date is selected, this is indicated with a green circle around it
                        if (number == self.selection) {
                            Text(nextSevenWorkingDaysDigits[number])
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
                                Text(nextSevenWorkingDaysDigits[number])
                                    .font(.system(size: 18))
                                    .foregroundColor(Constants.COLOR_ACCENT)
                                    .onTapGesture {
                                        self.selection = number
                                    }
                            }
                            else {
                                Text(nextSevenWorkingDaysDigits[number])
                                    .font(.system(size: 18))
                                    .onTapGesture {
                                        self.selection = number
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
    }
}

struct WeekDays_Previews: PreviewProvider {
    static var previews: some View {
        WeekDaysView(selection: .constant(0))
    }
}
