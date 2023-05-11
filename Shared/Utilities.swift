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
    var workingDays = [Date]()
    var date = date
    
    while workingDays.count < 7 {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DATE_FORMAT_EEEE
        let dayname:String = String(dateFormatter.string(from: date))
        if (!dayname.elementsEqual(Constants.SATURDAY) && !dayname.elementsEqual(Constants.SUNDAY)) {
            workingDays.append(date)
        }
        date = date.dayAfter
    }
    
    return workingDays
}

func getWorkingDaysCount(weekNumber: Int, dayOffset: Int) -> Int {
    let calendar = Calendar.current
    
    guard let today = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) else {
        return 0
    }
    
    guard let targetWeekDate = calendar.date(from: DateComponents(weekOfYear: weekNumber, yearForWeekOfYear: calendar.component(.yearForWeekOfYear, from: today))) else {
        return 0
    }
    
    let targetDate = calendar.date(byAdding: .day, value: dayOffset, to: targetWeekDate)!
    
    var workingDaysCount = 0
    var currentDate = today
    
    while currentDate <= targetDate {
        if !calendar.isDateInWeekend(currentDate) {
            workingDaysCount += 1
        }
        currentDate = calendar.date(byAdding: .day, value: 1, to: currentDate)!
    }
    
    return workingDaysCount
}
