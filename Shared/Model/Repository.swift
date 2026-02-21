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
    
    // Cache of meal name -> image URL to avoid refetching for same meals across days
    private var imageCache: [String: URL] = [:]
    
    private init() {}
    
    func get(refetch: Bool = false) {
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
        
        //if canteen is changed in settings
        if refetch {
            fetch()
            return
        }
        
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
        
        self.imageCache = [:]
        
        //this week: starts from today (or next working day)
        if (remainingWorkingDays > 0) {
            // Compute the start date: today if it's a working day, otherwise next Monday
            let thisWeekStartDate = today
            dispatchGroup.enter()
            parseCanteenDataFromWebsite(startDate: thisWeekStartDate, daysToFetch: remainingWorkingDays, startIndex: 0) { foods in
                canteen.foodOnDayX.merge(foods) { (_, new) in new }
                dispatchGroup.leave()
            }
        }
        
        // next week: starts from Monday
        let nextMonday = calendar.nextDate(after: today, matching: DateComponents(weekday: 2), matchingPolicy: .nextTime)!
        dispatchGroup.enter()
        parseCanteenDataFromWebsite(startDate: nextMonday, daysToFetch: 5, startIndex: remainingWorkingDays) { foods in
            canteen.foodOnDayX.merge(foods) { (_, new) in new }
            dispatchGroup.leave()
        }
        
        // the week after next week, if today isn't Monday
        let daysToFetch = daysInUpcomingWeeks - 5
        let startIndex = remainingWorkingDays + 5
        if (daysToFetch > 0) {
            let weekAfterNextMonday = calendar.date(byAdding: .weekOfYear, value: 1, to: nextMonday)!
            dispatchGroup.enter()
            parseCanteenDataFromWebsite(startDate: weekAfterNextMonday, daysToFetch: daysToFetch, startIndex: startIndex) { foods in
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
    
    private func parseCanteenDataFromWebsite(startDate: Date, daysToFetch: Int, startIndex: Int, completion: @escaping ([Int: [FoodLine]]) -> Void) {
        var foodOnDayX: [Int: [FoodLine]] = [:]
        let calendar = Calendar.current
        let weekNumber = calendar.component(.weekOfYear, from: startDate)
        let url = getURL(weekNumber: weekNumber)
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            var mealNamesPerDay: [Int: [String]] = [:]
            var foodLineMap: [String: Food] = [:]
            var seenMealNames = Set<String>()
            if let data = data, let html = String(data: data, encoding: .utf8) {
                do {
                    let doc: Document = try SwiftSoup.parse(html)
                    for day in stride(from: 1, through: daysToFetch, by: 1) {
                        let canteenDay1Div = try doc.select("#canteen_day_\(day)").first()
                        var foodLines: [FoodLine] = []
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
                                    if seenMealNames.contains(foodName) {
                                        continue
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
                                    let foodObj = Food(name: foodName, bio: true, allergens: [allergens], prices: floatPrices, foodClass: foodClass, nutritionalInfo: nutritionalInfo)
                                    foodLine.foods.append(foodObj)
                                    mealNamesPerDay[day, default: []].append(foodName)
                                    seenMealNames.insert(foodName)
                                    foodLineMap[foodName] = foodObj
                                }
                                if foods.isEmpty() {
                                    foodLine = FoodLine(name: foodlineName ?? "", closingText: "-")
                                    foodLines.append(foodLine)
                                } else {
                                    foodLines.append(foodLine)
                                }
                            }
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
            }
            // Fetch images from the API provided by https://github.com/kronos-et-al/MensaApp
            let imageGroup = DispatchGroup()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            // Apply cached images immediately
            var uncachedNamesPerDay: [Int: [String]] = [:]
            for (dayIndex, names) in mealNamesPerDay {
                var uncached: [String] = []
                for name in names {
                    if let cachedURL = self.imageCache[name] {
                        // Use cached image URL
                        foodLineMap[name]?.imageURL = cachedURL
                    } else {
                        uncached.append(name)
                    }
                }
                if !uncached.isEmpty {
                    uncachedNamesPerDay[dayIndex] = uncached
                }
            }
            
            // Fetch uncached images
            for (dayIndex, names) in uncachedNamesPerDay {
                guard !names.isEmpty else { continue }
                // Compute actual date: startDate + (dayIndex - 1) days
                guard let dateForDay = calendar.date(byAdding: .day, value: dayIndex - 1, to: startDate) else { continue }
                let dateString = dateFormatter.string(from: dateForDay)
                
                imageGroup.enter()
                self.fetchMealImagesForNames(mealNames: names, date: dateString) { imageMap in
                    for (name, url) in imageMap {
                        if let food = foodLineMap[name], let url = url {
                            food.imageURL = url
                            self.imageCache[name] = url
                        }
                    }
                    imageGroup.leave()
                }
            }
            imageGroup.notify(queue: .main) {
                completion(foodOnDayX)
            }
        }
        task.resume()
    }
    
    private func fetchMealImagesForNames(mealNames: [String], date: String, completion: @escaping ([String: URL?]) -> Void) {
        guard !mealNames.isEmpty else {
            completion([:])
            return
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let query = """
        query GetMealPlanForDay($date: NaiveDate!) {\n  getCanteens {\n    ...mealPlan\n    __typename\n  }\n  __typename\n}\n\nfragment mealPlan on Canteen {\n  lines {\n    id\n    name\n    canteen {\n      ...canteen\n      __typename\n    }\n    meals(date: $date) {\n      ...mealInfo\n      __typename\n    }\n    __typename\n  }\n  __typename\n}\n\nfragment canteen on Canteen {\n  id\n  name\n  __typename\n}\n\nfragment mealInfo on Meal {\n  id\n  name\n  images {\n    id\n    url\n    __typename\n  }\n  __typename\n}\n
"""
        let variables: [String: Any] = ["date": date]
        let body: [String: Any?] = [
            "operationName": nil,
            "variables": variables,
            "query": query
        ]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: body, options: []) else {
            completion([:])
            return
        }
        var request = URLRequest(url: apiURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiAuthorizationHeader(for: jsonData), forHTTPHeaderField: "Authorization")
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            var result: [String: URL?] = [:]
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let dataObj = json["data"] as? [String: Any],
                  let canteens = dataObj["getCanteens"] as? [[String: Any]]
            else {
                completion([:])
                return
            }
            for canteen in canteens {
                if let lines = canteen["lines"] as? [[String: Any]] {
                    for line in lines {
                        if let meals = line["meals"] as? [[String: Any]] {
                            for meal in meals {
                                guard let apiName = meal["name"] as? String,
                                      mealNames.contains(apiName) else { continue }
                                
                                if let images = meal["images"] as? [[String: Any]],
                                   let firstImage = images.first,
                                   let urlStr = firstImage["url"] as? String,
                                   let url = URL(string: urlStr) {
                                    result[apiName] = url
                                } else {
                                    result[apiName] = nil
                                }
                            }
                        }
                    }
                }
            }
            completion(result)
        }
        task.resume()
    }
}

