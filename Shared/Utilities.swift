//
//  Utilities.swift
//  Mensa
//
//  Created by Philipp on 10.05.23.
//  Copyright © 2023 Philipp. All rights reserved.
//

import Foundation
import CryptoKit

func getSelectedDateString(date: Date, offset: Int, onlyDay: Bool) -> String {
    var date = date
    let userCalendar = Calendar.current
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
    let day = String(userCalendar.component(.day, from: date))
    dateFormatter.dateFormat = Constants.DATE_FORMAT_LLLL
    let month = dateFormatter.string(from: date)
    let year = String(userCalendar.component(.year, from: date))
    var dot = Constants.EMPTY
    if Locale.current.languageCode?.hasPrefix(Constants.LANGUAGE_PREFIX_DE) == true {
        dot = Constants.DOT
    }
    if (onlyDay) {
        return dayname + Constants.COMMA + Constants.SPACE + day + dot
    }
    return dayname + Constants.COMMA + Constants.SPACE + day + dot + Constants.SPACE + month + Constants.SPACE + year
}

func getNextWorkingDays(date: Date, count: Int) -> [Date] {
    var workingDays = [Date]()
    var date = date
    
    while workingDays.count < count {
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

func parseAllergens(from rawValue: String) -> [Allergen] {
    let rawTokens = rawValue
        .replacingOccurrences(of: "[", with: "")
        .replacingOccurrences(of: "]", with: "")
        .components(separatedBy: CharacterSet(charactersIn: ",;/ "))
        .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        .filter { !$0.isEmpty }
    
    var seen = Set<Allergen>()
    var result: [Allergen] = []
    for token in rawTokens {
        guard let allergen = Allergen.from(rawCode: token), !seen.contains(allergen) else { continue }
        seen.insert(allergen)
        result.append(allergen)
    }
    return result
}

func allergensString(allergens: [Allergen]) -> String {
    let labels = allergens.map { $0.localizedShortLabel }
    guard !labels.isEmpty else { return Constants.EMPTY }
    return "[\(labels.joined(separator: Constants.COMMA + Constants.SPACE))]"
}

func allergensLongString(allergens: [Allergen]) -> String {
    allergens.map { "\($0.code) \($0.localizedName)" }.joined(separator: "\n")
}

func removeExcludedFood(food: [Food]) -> [Food] {

    var result = [Food]()
    let settings = ViewModel.shared
    
    for food in food {
        if !settings.excludedAllergens.isDisjoint(with: Set(food.allergens)) {
            continue
        }
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

private let imageCacheDirectoryName = "MealImageCache"

private func imageCacheRootDirectory() -> URL {
    let base = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
    let directory = base.appendingPathComponent(imageCacheDirectoryName, isDirectory: true)
    if !FileManager.default.fileExists(atPath: directory.path) {
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }
    return directory
}

func cachedImageFileURL(for remoteURL: URL) -> URL {
    let hash = SHA256.hash(data: Data(remoteURL.absoluteString.utf8)).map { String(format: "%02x", $0) }.joined()
    let ext = remoteURL.pathExtension.isEmpty ? "jpg" : remoteURL.pathExtension
    return imageCacheRootDirectory().appendingPathComponent("\(hash).\(ext)")
}

func cachedImageData(for remoteURL: URL) -> Data? {
    let fileURL = cachedImageFileURL(for: remoteURL)
    return try? Data(contentsOf: fileURL)
}

func storeCachedImageData(_ data: Data, for remoteURL: URL) {
    let fileURL = cachedImageFileURL(for: remoteURL)
    try? data.write(to: fileURL, options: .atomic)
}

func prefetchImageDataIfNeeded(from remoteURL: URL) {
    if cachedImageData(for: remoteURL) != nil {
        return
    }
    var request = URLRequest(url: remoteURL)
    request.cachePolicy = .returnCacheDataElseLoad
    request.timeoutInterval = 15
    
    URLSession.shared.dataTask(with: request) { data, _, _ in
        guard let data = data, !data.isEmpty else { return }
        storeCachedImageData(data, for: remoteURL)
    }.resume()
}
