//
//  Utilities.swift
//  Mensa
//
//  Created by Philipp on 10.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import Foundation

func getSelectedDateString(date: Date, offset: Int, onlyDay: Bool) -> String {
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

func getNextSevenWorkingDays(date: Date) -> [Date] {
    var workingDays: [Date] = []
    let calendar = Calendar.current
    var date = Date()

    while workingDays.count < 7 {
        date = calendar.date(byAdding: .day, value: 1, to: date)!
        let isWeekend = calendar.isDateInWeekend(date)
        if !isWeekend {
            workingDays.append(date)
        }
    }

    return workingDays
}
