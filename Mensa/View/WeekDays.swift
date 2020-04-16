//
//  WeekDays.swift
//  Mensa
//
//  Created by Philipp on 03.04.20.
//  Copyright © 2020 Philipp. All rights reserved.
//

import SwiftUI

struct WeekDays: View {
    
    @Binding var selection: Int
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 32) {
                //seven days are displayed
                ForEach(0..<7) { number in
                    VStack(spacing: 10) {
                        Text(nextSevenDays()[number].0).font(.system(size: 12)).padding(.bottom, 3)
                                            
                        //if a date is selected, this is indicated with a blue circle around it
                        if (number == self.selection) {
                            Text(String(nextSevenDays()[number].1)).font(.system(size: 18)).foregroundColor(.white).bold().onTapGesture {
                                self.selection = number
                            }.background(Image(systemName: "circle.fill").font(.system(size: 35)).foregroundColor(self.accentColor))
                        }
                        else {
                            //the current day is displayed in blue
                            if (number == 0) {
                                Text(String(nextSevenDays()[number].1)).font(.system(size: 18)).foregroundColor(self.accentColor).onTapGesture {
                                    self.selection = number
                                }
                            }
                            else {
                                Text(String(nextSevenDays()[number].1)).font(.system(size: 18)).onTapGesture {
                                    self.selection = number
                                }
                            }
                        }
                    }
                }
                }.frame(maxWidth: .infinity)
            //display the selected day in words
            Text(getSelectedDate(offset: self.selection, onlyDay: false)).font(.system(size: 17))
        }
    }
}

struct WeekDays_Previews: PreviewProvider {
    static var previews: some View {
        WeekDays(selection: .constant(0), accentColor: .green)
    }
}

func getSelectedDate(offset: Int, onlyDay: Bool) -> String {
    var date = Date()
    let userCalendar = Calendar.current
    let requestedComponents: Set<Calendar.Component> = [
        .year,
        .month,
        .day
    ]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE"
    var dayname = dateFormatter.string(from: date)
    
    if (dayname.elementsEqual(NSLocalizedString("Saturday", comment: ""))) {
        date = date.dayAfter.dayAfter
    }
    else if (dayname.elementsEqual(NSLocalizedString("Sunday", comment: ""))) {
        date = date.dayAfter
    }
    
    offset.times {
        date = date.dayAfter
        dayname = dateFormatter.string(from: date)
        
        if (dayname.elementsEqual(NSLocalizedString("Saturday", comment: ""))) {
            date = date.dayAfter.dayAfter
        }
        else if (dayname.elementsEqual(NSLocalizedString("Sunday", comment: ""))) {
            date = date.dayAfter
        }
    }
    dayname = dateFormatter.string(from: date)
    let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: date)
    let day:String = String(dateTimeComponents.day!)
    dateFormatter.dateFormat = "LLLL"
    let month:String = dateFormatter.string(from: date)
    let year:String = String(dateTimeComponents.year!)
    var dot = ""
    if (Locale.current.languageCode?.prefix(2) == "de") {
        dot = "."
    }
    if (onlyDay) {
    	return dayname + ", " + day + dot
    }
    return dayname + ", " + day + dot + " " + month + " " + year
}


func nextSevenDays() -> [(String, Int)] {
    var date = Date()
    let userCalendar = Calendar.current
    let requestedComponents: Set<Calendar.Component> = [
        .day
    ]
    let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: date)
    
    let day:Int = dateTimeComponents.day!
    
    var array = [(String, Int)]()
    var i = 0
    
    while array.count < 7 {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayname:String = String(dateFormatter.string(from: date))
        if (!dayname.elementsEqual(NSLocalizedString("Saturday", comment: "")) && !dayname.elementsEqual(NSLocalizedString("Sunday", comment: ""))) {
            array.append((String(dayname.prefix(2)), day + i))
        }
        date  = date.dayAfter
        i += 1
    }
    return array
}
