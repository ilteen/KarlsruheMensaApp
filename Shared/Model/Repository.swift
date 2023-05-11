//
//  Repository.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation
import SwiftSoup

class Repository {
    
    var canteens: [Canteen] = [Canteen(shortName: Constants.API_ABBREVIATIONS_CANTEEN_ADENAUERRING, foodOnDayX: [:])]
    
    func fetch(completion: @escaping (CanteenViewModel) -> ()) {
        let calendar = Calendar.current
        let today = Date()
        let currentWeekNumber = calendar.component(.weekOfYear, from: today)
        
        let remainingDaysInCurrentWeek = 7 - (calendar.component(.weekday, from: today) - 1)
        
        let remainingWorkingDays = (0..<remainingDaysInCurrentWeek).reduce(0) { (result, day) -> Int in
            let currentDate = calendar.date(byAdding: .day, value: day, to: today)!
            let isWeekend = calendar.isDateInWeekend(currentDate)
            return result + (isWeekend ? 0 : 1)
        }
        
        let totalDaysToFetch = 10
        let daysInUpcomingWeeks = totalDaysToFetch - remainingWorkingDays
        
        let dispatchGroup = DispatchGroup()
        
        dispatchGroup.enter()
        fetchCanteenData(weekNumber: currentWeekNumber, daysToFetch: remainingWorkingDays, startIndex: 0) {
            dispatchGroup.leave()
        }
        
        // next week
        dispatchGroup.enter()
        fetchCanteenData(weekNumber: currentWeekNumber + 1, daysToFetch: 5, startIndex: remainingWorkingDays) {
            dispatchGroup.leave()
        }
        
        // the week after next week, if today isn't Monday
        if (daysInUpcomingWeeks % 5 > 0) {
            dispatchGroup.enter()
            fetchCanteenData(weekNumber: currentWeekNumber + 2, daysToFetch: daysInUpcomingWeeks % 5, startIndex: remainingWorkingDays + daysInUpcomingWeeks % 5) {
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            //CanteenViewModel.viewModel.setCanteens(canteens: canteens, date: Date())
            DispatchQueue.main.async {
                CanteenViewModel.viewModel.setCanteens(canteens: self.canteens, date: Date())
                completion(CanteenViewModel.viewModel)
            }
        }
        
    }
    
    func fetchCanteenData(weekNumber: Int, daysToFetch: Int, startIndex: Int, completion: @escaping () -> Void) {
        let url = URL(string: "https://www.sw-ka.de/en/hochschulgastronomie/speiseplan/mensa_adenauerring/?kw=\(weekNumber)")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let html = String(data: data, encoding: .utf8) {
                do {
                    let doc: Document = try SwiftSoup.parse(html)
                    
                    for day in stride(from: 1, through: daysToFetch, by: 1) {
                        let canteenDay1Div = try doc.select("#canteen_day_\(day)").first()
                        
                        var foodLines: [FoodLine] = []
                        
                        // Canteen rows (Line 1, Linie 2, ...)
                        if let rows = try canteenDay1Div?.select("tr.mensatype_rows") {
                            for row in rows {
                                
                                let foodlineName = try row.select("td.mensatype div").first()?.ownText()
                                var foodLine = FoodLine(name: foodlineName ?? "", foods: [])
                                
                                let foods = try row.select("td.menu-title")
                                for food in foods {
                                    let foodName = try food.select("span b").text()
                                    let allergens = try food.select("sup").text().replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                                    
                                    let iconElement = try food.previousElementSibling()
                                    let iconTitle = try iconElement?.select("img").attr("title")
                                    let foodClass = getFoodClassFromImage(iconTitle: iconTitle)
                                    
                                    var prices = [String]()
                                    let priceSpans = try food.nextElementSibling()?.select("span.bgp")
                                    for priceSpan in priceSpans! {
                                        prices.append(try priceSpan.text())
                                    }
                                    let floatPrices = convertPricesToFloatArray(from: prices)
                                    
                                    let food = Food(name: foodName, bio: true, allergens: [allergens], prices: floatPrices, foodClass: foodClass)
                                    foodLine.foods.append(food)
                                    
                                    //                            let nutritionFactsDiv = try row.select("td.nutrition_facts_row div.nutrition_facts").first()
                                    //                            if let nutritionFactsDiv = nutritionFactsDiv {
                                    //                                print("Nutrition Facts:")
                                    //                                for nutritionItem in try nutritionFactsDiv.select("div:not(.meal-image) div") {
                                    //                                    let nutritionName = try nutritionItem.select("div").first()?.text() ?? ""
                                    //                                    //let nutritionValue = try nutritionItem.select("div").last()?.text() ?? ""
                                    //                                    print("\(nutritionName)\n")
                                    //                                }
                                    //                            }
                                    //
                                    //                            let environmentalInfoDiv = try row.select("td.nutrition_facts_row div.co2_footprint").first()
                                    //                            if let environmentalInfoDiv = environmentalInfoDiv {
                                    //                                print("Environmental Information:")
                                    //                                for environmentalItem in try environmentalInfoDiv.select("div:not(.co2-more-info) div") {
                                    //                                    let environmentalName = try environmentalItem.select("div").first()?.text() ?? ""
                                    //                                    let environmentalValue = try environmentalItem.select("div").last()?.text() ?? ""
                                    //                                    //print("\(environmentalName): \(environmentalValue)")
                                    //                                }
                                    //                            }
                                }
                                if foods.isEmpty() {
                                    foodLine = FoodLine(name: foodlineName ?? "", closingText: "-")
                                    foodLines.append(foodLine)
                                }
                                else {
                                    foodLines.append(foodLine)
                                }
                                
                            }
                        }
                        else {
                            //This day doesn't exist!
                        }
                        self.canteens[0].foodOnDayX[day - 1 + startIndex] = foodLines
                    }
                } catch Exception.Error(_, let message) {
                    print(message)
                } catch {
                    print("error")
                }
                
            } else {
                print("Unable to convert data to HTML string")
                //TODO: handle
            }
            completion()
        }
        task.resume()
    }
}
