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
    @Binding var date: Date
    let accentColor: Color
    
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 32) {
                //seven days are displayed
                ForEach(0..<7) { number in
                    VStack(spacing: 10) {
                        Text(nextSevenDays(date: self.date)[number].0).font(.system(size: 12)).padding(.bottom, 3)
                                            
                        //if a date is selected, this is indicated with a blue circle around it
                        if (number == self.selection) {
                            Text(String(nextSevenDays(date: self.date)[number].1)).font(.system(size: 18)).foregroundColor(.white).bold().onTapGesture {
                                self.selection = number
                            }.background(Image(systemName: Constants.IMAGE_CIRCLE_FILL).font(.system(size: 35)).foregroundColor(self.accentColor))
                        }
                        else {
                            //the current day is displayed in blue
                            if (number == 0) {
                                Text(String(nextSevenDays(date: self.date)[number].1)).font(.system(size: 18)).foregroundColor(self.accentColor).onTapGesture {
                                    self.selection = number
                                }
                            }
                            else {
                                Text(String(nextSevenDays(date: self.date)[number].1)).font(.system(size: 18)).onTapGesture {
                                    self.selection = number
                                }
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            //display the selected day in words
            Text(getSelectedDate(date: self.date, offset: self.selection, onlyDay: false)).font(.system(size: 17))
        }
    }
}

struct WeekDays_Previews: PreviewProvider {
    static var previews: some View {
        WeekDays(selection: .constant(0), date: .constant(Date()), accentColor: .green)
    }
}

func getSelectedDate(date: Date, offset: Int, onlyDay: Bool) -> String {
    var date = date
    let userCalendar = Calendar.current
    let requestedComponents: Set<Calendar.Component> = [
        .year,
        .month,
        .day
    ]
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = Constants.DATE_FORMAT_EEEE
    var dayname = dateFormatter.string(from: date)
    
    if (dayname.elementsEqual(Constants.SATURDAY)) {
        date = date.dayAfter.dayAfter
    }
    else if (dayname.elementsEqual(Constants.SUNDAY)) {
        date = date.dayAfter
    }
    
    offset.times {
        date = date.dayAfter
        dayname = dateFormatter.string(from: date)
        
        if (dayname.elementsEqual(Constants.SATURDAY)) {
            date = date.dayAfter.dayAfter
        }
        else if (dayname.elementsEqual(Constants.SUNDAY)) {
            date = date.dayAfter
        }
    }
    dayname = dateFormatter.string(from: date)
    let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: date)
    let day:String = String(dateTimeComponents.day!)
    dateFormatter.dateFormat = Constants.DATE_FORMAT_LLLL
    let month:String = dateFormatter.string(from: date)
    let year:String = String(dateTimeComponents.year!)
    var dot = Constants.EMPTY
    if (Locale.current.languageCode!.prefix(2).elementsEqual(Constants.LANGUAGE_PREFIX_DE)) {
        dot = Constants.DOT
    }
    if (onlyDay) {
        return dayname + Constants.COMMA + Constants.SPACE + day + dot
    }
    return dayname + Constants.COMMA + Constants.SPACE + day + dot + Constants.SPACE + month + Constants.SPACE + year
}


func nextSevenDays(date: Date) -> [(String, Int)] {
    //TODO: this function is called too often, maybe put the result in a var
    var array = [(String, Int)]()
    var i = 0
    
    while array.count < 7 {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DATE_FORMAT_EEEE
        let dayname:String = String(dateFormatter.string(from: date))
        if (!dayname.elementsEqual(Constants.SATURDAY) && !dayname.elementsEqual(Constants.SUNDAY)) {
            array.append((String(dayname.prefix(2)), Calendar.current.dateComponents([.day], from: Calendar.current.date(byAdding: .day, value: i+1, to: .yesterday)!).day!))
        }
        i += 1
    }
    
    return array
}

