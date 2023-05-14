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
        let dayname: String = String(dateFormatter.string(from: date))
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

func convertPricesToFloatArray(from stringArray: [String]) -> [Float] {
    let formatter = NumberFormatter()
        formatter.locale = Locale(identifier: "en_DE") // Use "en_US_POSIX" locale for consistent behavior
        formatter.numberStyle = .currency
        formatter.currencySymbol = "€"
        
        return stringArray.compactMap { stringValue in
            let trimmedString = String(stringValue.dropLast(2)).replacingOccurrences(of: ",", with: ".")
            
            if let number = Float(trimmedString) {
                return number
            }
            return nil
        }
}

func getFoodClassFromImage(iconTitle: String?) -> FoodClass {
    if let title = iconTitle {
        if title.contains("vegan") {
            return .vegan
        } else if title.contains("vegetarisch") {
            return .vegetarian
        } else if title.contains("Rindfleisch") {
            return .beef
        } else if title.contains("regionales Rindfleisch") {
            return .beefLocal
        } else if title.contains("Schweinefleisch") {
            return .pork
        } else if title.contains("regionales Schweinefleisch") {
            return .porkLocal
        } else if title.contains("Fisch") {
            return .fish
        } else {
            return .nothing
        }
    }
    return .nothing
}

func getURL(weekNumber: Int) -> URL {
    let canteen = ViewModel.shared.canteenSelection
    var canteenStr = Constants.API_ABBREVIATIONS_CANTEEN_ADENAUERRING
    
    switch(canteen) {
    case .MENSERIA_ERZBERGER:
        canteenStr = Constants.API_ABBREVIATIONS_CANTEEN_ERZBERGER
    case .MENSA_GOTTESAUE:
        canteenStr =  Constants.API_ABBREVIATIONS_CANTEEN_GOTTESAUE
    case .MENSERIA_HOLZGARTEN:
        canteenStr =  Constants.API_ABBREVIATIONS_CANTEEN_HOLZGARTEN
    case .MENSA_MOLTKE:
        canteenStr =  Constants.API_ABBREVIATIONS_CANTEEN_MOLTKE
    case .MENSERIA_MOLTKE:
        canteenStr =  Constants.API_ABBREVIATIONS_CANTEEN_MENSERIA_MOLTKE
    case .CAFETERIA_TIEFENBRONNER:
        canteenStr =  Constants.API_ABBREVIATIONS_CANTEEN_TIEFENBRONNER
    default:
        canteenStr = Constants.API_ABBREVIATIONS_CANTEEN_ADENAUERRING
    }
    
    return URL(string: Constants.API_URL  + "\(canteenStr)/?kw=\(weekNumber)")!
}

func allergensString(allergens: [String]) -> String {
    var str = Constants.EMPTY
    
    for i in 0..<allergens.count {
        str.append(contentsOf: allergens[i])
        if (i != allergens.count - 1) {
            str.append(contentsOf: Constants.COMMA + Constants.SPACE)
        }
    }
    if (!str.isEmpty) {
        str.insert("[", at: str.startIndex)
        str.insert("]", at: str.endIndex)
    }
    return str
}

func removeUnwantedFood(foods: [Food]) -> [Food] {

    var result = [Food]()
    let settings = ViewModel.shared
    
    for food in foods {
        switch food.foodClass {
            case .vegetarian:
                if (!settings.onlyVegan) {result.append(food)}
            
            case .pork, .porkLocal:
                if (!(settings.noPork || settings.onlyVegetarian || settings.onlyVegan)) {result.append(food)}
            
            case .beef, .beefLocal:
                if (!(settings.noBeef || settings.onlyVegetarian || settings.onlyVegan)) {result.append(food)}
            
            case .fish:
                if (!(settings.noFish || settings.onlyVegetarian || settings.onlyVegan)) {result.append(food)}
            default: result.append(food)
        }
    }
    return result
}
