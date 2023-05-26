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
    
    static let shared = Repository()
    
    //TODO: what is around a new year? when the weeks start from 1 again?
    
    private let totalDaysToFetch = 10
    
    private init() {}
    
    func get() {
        func fetch() {
            viewModel.loading = true
            self.fetchCanteenData {
                viewModel.loading = false
#if os(iOS)
                if let canteenData = viewModel.canteen {
                    let priceGroup = viewModel.priceGroupSelection
                    WatchConnectivityHandler.shared.sendCanteenDataToWatch(canteen: canteenData, priceGroup: priceGroup)
                }
#endif
            }
        }
        
        let viewModel = ViewModel.shared
        if let canteenData = viewModel.canteen {
            //if canteen is already fetched, check if days have passed since last fetching and today, if so, delete past days
            let index = nextDayIndex(currentDate: Date(), dates: canteenData.nextSevenWorkingDays) ?? 0
            let daysStillFetched = canteenData.foodOnDayX.count
            let correctedIndex = index - (totalDaysToFetch - daysStillFetched)
            canteenData.foodOnDayX.dropAndReduceIndexSmallerThan(correctedIndex)
            
            if canteenData.foodOnDayX.count < 7 {
                fetch()
            }
            else {
#if os(iOS)
                let priceGroup = viewModel.priceGroupSelection
                WatchConnectivityHandler.shared.sendCanteenDataToWatch(canteen: canteenData, priceGroup: priceGroup)
#endif
                viewModel.loading = false
            }
        }
        else {
            fetch()
        }
    }
    
    private func fetchCanteenData(completion: @escaping () -> ()) {
        let calendar = Calendar.current
        let today = Date()
        let currentWeekNumber = calendar.component(.weekOfYear, from: today)
        
        var remainingWorkingDays = 0
        
        switch calendar.component(.weekday, from: today) {
        case 1:
            remainingWorkingDays = 0
        case 2:
            remainingWorkingDays = 5
        case 3:
            remainingWorkingDays = 4
        case 4:
            remainingWorkingDays = 3
        case 5:
            remainingWorkingDays = 2
        case 6:
            remainingWorkingDays = 1
        case 7:
            remainingWorkingDays = 0
        default:
            remainingWorkingDays = 0
        }
        
        let daysInUpcomingWeeks = totalDaysToFetch - remainingWorkingDays
        
        let canteen = Canteen(name: ViewModel.shared.canteenSelection.rawValue, foodOnDayX: [:], dateOfLastFetching: Date())
        let dispatchGroup = DispatchGroup()
        
        //this week
        if (remainingWorkingDays > 0) {
            dispatchGroup.enter()
            parseCanteenDataFromWebsite(weekNumber: currentWeekNumber, daysToFetch: remainingWorkingDays, startIndex: 0) { foods in
                canteen.foodOnDayX.merge(foods) { (_, new) in new }
                dispatchGroup.leave()
            }
        }
        
        // next week
        dispatchGroup.enter()
        parseCanteenDataFromWebsite(weekNumber: currentWeekNumber + 1, daysToFetch: 5, startIndex: remainingWorkingDays) { foods in
            canteen.foodOnDayX.merge(foods) { (_, new) in new }
            dispatchGroup.leave()
        }
        
        // the week after next week, if today isn't Monday
        let daysToFetch = daysInUpcomingWeeks - 5
        let startIndex = remainingWorkingDays + 5
        if (daysToFetch > 0) {
            dispatchGroup.enter()
            parseCanteenDataFromWebsite(weekNumber: currentWeekNumber + 2, daysToFetch: daysToFetch, startIndex: startIndex) { foods in
                canteen.foodOnDayX.merge(foods) { (_, new) in new }
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            DispatchQueue.main.async {
                ViewModel.shared.canteen = canteen
                completion()
            }
        }
    }
    
    private func parseCanteenDataFromWebsite(weekNumber: Int, daysToFetch: Int, startIndex: Int, completion: @escaping ([Int: [FoodLine]]) -> Void) {
        var foodOnDayX: [Int: [FoodLine]] = [:]
        let url = getURL(weekNumber: weekNumber)
        
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
                                    
                                    let foodNameElement = try food.select("span b").first()
                                    var foodName = try foodNameElement?.text() ?? ""
                                    
                                    if let additionalSpanElement = try food.select("span span").first() {
                                        let additionalText = try additionalSpanElement.text()
                                        foodName += " \(additionalText)"
                                    }
                                    
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
                                    
                                    var nutritionalInfo: NutritionalInfo? = nil
                                    
                                    if let umweltScoreDiv = try food.nextElementSibling()?.select("div.enviroment_score").first() {
                                        let rating = try umweltScoreDiv.attr("data-rating")
                                        let environmentScore = Int(rating) ?? 0
                                        
                                        let nutritionRow = try food.parent()?.nextElementSibling()
                                        let energy = try nutritionRow?.select(".energie > div:nth-child(2)").text() ?? ""
                                        let proteins = try nutritionRow?.select(".proteine > div:nth-child(2)").text() ?? ""
                                        let carbohydrates = try nutritionRow?.select(".kohlenhydrate > div:nth-child(2)").text() ?? ""
                                        let sugar = try nutritionRow?.select(".zucker > div:nth-child(2)").text() ?? ""
                                        let fat = try nutritionRow?.select(".fett > div:nth-child(2)").text() ?? ""
                                        let saturatedFat = try nutritionRow?.select(".gesaettigt > div:nth-child(2)").text() ?? ""
                                        let salt = try nutritionRow?.select(".salz > div:nth-child(2)").text() ?? ""
                                        let co2Value = try nutritionRow?.select(".co2_bewertung_wolke > .value").text() ?? ""
                                        let co2Score = try Int(nutritionRow?.select(".co2_bewertung_wolke > .enviroment_score").attr("data-rating") ?? "") ?? 0
                                        let waterValue = try nutritionRow?.select(".wasser_bewertung > .value").text() ?? ""
                                        let waterScore = try Int(nutritionRow?.select(".wasser_bewertung > .enviroment_score").attr("data-rating") ?? "") ?? 0
                                        let animalWelfareScore = try Int(nutritionRow?.select(".tierwohl > .enviroment_score").attr("data-rating") ?? "") ?? 0
                                        let rainforestScore = try Int(nutritionRow?.select(".regenwald > .enviroment_score").attr("data-rating") ?? "") ?? 0
                                        
                                        nutritionalInfo = NutritionalInfo(energy: energy , proteins: proteins , carbohydrates: carbohydrates , sugar: sugar , fat: fat , saturatedFat: saturatedFat , salt: salt , co2Value: co2Value , co2Score: co2Score , waterValue: waterValue , waterScore: waterScore , animalWelfareScore: animalWelfareScore, rainforestScore: rainforestScore, environmentScore: environmentScore)
                                    }
                                    
                                    foodLine.foods.append(Food(name: foodName, bio: true, allergens: [allergens], prices: floatPrices, foodClass: foodClass, nutritionalInfo: nutritionalInfo))
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
                        foodOnDayX[day - 1 + startIndex] = foodLines
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
            completion(foodOnDayX)
        }
        task.resume()
    }
    
    
}
