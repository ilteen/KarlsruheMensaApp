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
        let nextSevenWorkingDaysStrings = Date.abbreviations(of: nextSevenWorkingDays)
        let nextSevenWorkingDaysDigits = Date.digits(of: nextSevenWorkingDays)
        
        VStack(spacing: 10) {
            HStack(spacing: 32) {
                ForEach(0..<7) { number in
                    VStack(spacing: 10) {
                        Text(nextSevenWorkingDaysStrings[number]).font(.system(size: 12)).padding(.bottom, 3)
                                            
                        //if a date is selected, this is indicated with a green circle around it
                        if (number == self.selection) {
                            Text(String(nextSevenWorkingDaysDigits[number])).font(.system(size: 18)).foregroundColor(.white).bold().onTapGesture {
                                self.selection = number
                            }.background(Image(systemName: Constants.IMAGE_CIRCLE_FILL).font(.system(size: 35)).foregroundColor(Constants.COLOR_ACCENT))
                        }
                        else {
                            //the current day is displayed in green
                            Text(String(nextSevenWorkingDaysDigits[number])).font(.system(size: 18)).onTapGesture {
                                self.selection = number
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Text(getSelectedDateString(date: Date(), offset: self.selection, onlyDay: false)).font(.system(size: 17))
        }
    }
}

struct WeekDays_Previews: PreviewProvider {
    static var previews: some View {
        WeekDaysView(selection: .constant(0))
    }
}
