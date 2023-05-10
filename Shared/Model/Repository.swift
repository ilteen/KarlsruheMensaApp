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
        fetchCanteenData(weekNumber: currentWeekNumber, daysToFetch: remainingWorkingDays) {
            dispatchGroup.leave()
        }
        
        // next week
        dispatchGroup.enter()
        fetchCanteenData(weekNumber: currentWeekNumber + 1, daysToFetch: 5) {
            dispatchGroup.leave()
        }
        
        // the week after next week, if today isn't Monday
        if (daysInUpcomingWeeks % 5 > 0) {
            dispatchGroup.enter()
            fetchCanteenData(weekNumber: currentWeekNumber + 2, daysToFetch: daysInUpcomingWeeks % 5) {
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
    
    func fetchCanteenData(weekNumber: Int, daysToFetch: Int, completion: @escaping () -> Void) {
        let url = URL(string: "https://www.sw-ka.de/en/hochschulgastronomie/speiseplan/mensa_adenauerring/?kw=\(weekNumber)")!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let html = String(data: data, encoding: .utf8) {
                do {
                    let doc: Document = try SwiftSoup.parse(html)
                    
                    var days: [Int:[FoodLine]] = [:]
                    
                    for day in stride(from: 0, through: daysToFetch, by: 1) {
                        let canteenDay1Div = try doc.select("#canteen_day_\(day)").first()
                        
                        
                        var foodLines: [FoodLine] = []
                        
                        // Canteen rows (Line 1, Linie 2, ...)
                        let rows = try canteenDay1Div?.select("tr.mensatype_rows")
                        
                        if let rows = rows {
                            for row in rows {
                                
                                
                                let foodlineName = try row.select("td.mensatype div").first()?.ownText()
                                print(foodlineName ?? "")
                                
                                var foodLine = FoodLine(name: foodlineName ?? "", foods: [])
                                
                                let foods = try row.select("td.menu-title")
                                for food in foods {
                                    let name = try food.select("span b").text()
                                    let allergens = try food.select("sup").text().replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
                                    
                                    var prices = [String]()
                                    let priceSpans = try food.nextElementSibling()?.select("span.bgp")
                                    for priceSpan in priceSpans! {
                                        prices.append(try priceSpan.text())
                                    }
                                    
                                    
                                    let formatter = NumberFormatter()
                                    formatter.decimalSeparator = ","
                                    formatter.numberStyle = .decimal
                                    
                                    let floatArray = prices.compactMap { string -> Float? in
                                        let cleanedString = string.replacingOccurrences(of: ",", with: "")
                                        if let number = formatter.number(from: cleanedString) {
                                            return number.floatValue
                                        } else {
                                            return nil
                                        }
                                    }
                                    
                                    let food = Food(name: name, bio: true, allergens: [allergens], prices: floatArray, foodClass: FoodClass.beef)
                                    foodLine.foods.append(food)
                                    
                                    print("Food: \(name)")
                                    print("Allergens: \(allergens)")
                                    print("Prices: \(prices)")
                                    
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
                                    var foodLine = FoodLine(name: foodlineName ?? "", closingText: "-")
                                }
                                else {
                                    foodLines.append(foodLine)                                    
                                }
                                
                            }
                        }
                        else {
                            //This day doesn't exist!
                        }
                        
                        days[day] = foodLines
                    }
                    self.canteens[0].foodOnDayX = days
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
    
    
    
    
    
    
    
    
    
    
    
    
    func fetchCanteenData(completion: @escaping (CanteenViewModel) -> ()) {
        let url = URL(string: Constants.API_URL)!
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if let data = data, let html = String(data: data, encoding: .utf8) {
                print(html)
            } else {
                print("Unable to convert data to HTML string")
                //TODO:
            }
        }
        
        task.resume()
    }
    
    func get(completion: @escaping (CanteenViewModel) -> ()) {
        if (CanteenViewModel.viewModel.areCanteensNil()) {
            let url = URL(string: Constants.API_URL)!
            let username = Constants.API_USERNAME
            let password = Constants.API_PASSWORD
            
            let loginCredentials = String(format: Constants.API_LOGIN_FORMAT, username, password).data(using: String.Encoding.utf8)!.base64EncodedString()
            
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = Constants.API_HTTP_METHOD
            urlRequest.setValue("Basic \(loginCredentials)", forHTTPHeaderField: Constants.API_AUTHORIZATION)
            
            var canteens: [Canteen]?
            
            let _: Void = URLSession.shared.dataTask(with: urlRequest) { data, response, error  in
                
                if let data = data {
                    do {
                        let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                        canteens = parse(from: json)
                        //saveJSON(json: data)
                        //TODO: save async
                    }
                    catch {
                        canteens =  nil
                    }
                    DispatchQueue.main.async {
                        CanteenViewModel.viewModel.setCanteens(canteens: canteens, date: Date())
                        completion(CanteenViewModel.viewModel)
                    }
                }
                else {
                    DispatchQueue.main.async {
                        //TODO: what to do here?
                        completion(CanteenViewModel.viewModel)
                    }
                }
            }.resume()
        }
        else {
            //TODO: e.g. return canteens on next day if past 3pm
            
            /*
             
             //check if date of last fetch is the same as today
             
             let calendar = Calendar.current
             
             print("lastFetfch", self.canteens.dateOfLastFetching)
             print("today", Date())
             
             
             //if it's past 3 o'clock, display food for next day (Mensa already closed for current day)
             if ((calendar.component(.hour, from: self.canteens.dateOfLastFetching) >= Constants.CANTEEN_CLOSING) && !Calendar.current.isDateInWeekend(self.canteens.dateOfLastFetching)) {
             //refreshes WeekDays datepicker
             
             var dayComponent = DateComponents()
             dayComponent.day = 1
             self.canteens.dateOfLastFetching = calendar.date(byAdding: dayComponent, to: self.canteens.dateOfLastFetching) ?? self.canteens.dateOfLastFetching
             //self.canteens.dateOfLastFetching = calendar.date(bySettingHour: 3, minute: 0, second: 0, of: self.canteens.dateOfLastFetching)!
             self.daySelection = 0
             
             //refreshes food of current day
             //if !calendar.isDateInWeekend(self.canteens.dateOfLastFetching) {
             self.dayOffset += 1
             //}
             }
             
             //if (!calendar.isDateInToday(self.canteens.dateOfLastFetching)) {
             else if (!((calendar.isDate(Date(), inSameDayAs: self.canteens.dateOfLastFetching)) || (Date() < self.canteens.dateOfLastFetching))) {
             
             // Replace the hour (time) of both dates with 00:00
             let today = calendar.startOfDay(for: Date())
             let lastFetch = calendar.startOfDay(for: self.canteens.dateOfLastFetching)
             let daysSinceLastFetching = calendar.dateComponents([.day], from: lastFetch, to: today).day ?? 0
             
             //refreshes food of current day
             if (!calendar.isDateInWeekend(self.canteens.dateOfLastFetching) || (calendar.isDateInWeekend(self.canteens.dateOfLastFetching) && (calendar.component(Calendar.Component.weekday, from: Date()) != 1) && (calendar.component(Calendar.Component.weekday, from: Date()) != 2))) {
             
             if calendar.isDateInWeekend(self.canteens.dateOfLastFetching) {
             self.dayOffset += 1
             }
             else {
             self.dayOffset += daysSinceLastFetching
             }
             
             
             //refreshes WeekDays datepicker
             self.canteens.dateOfLastFetching = today
             //self.canteens.dateOfLastFetching = calendar.date(bySettingHour: 3, minute: 0, second: 0, of: self.canteens.dateOfLastFetching)!
             self.daySelection = 0
             }
             }
             
             */
            
            
            DispatchQueue.main.async {
                completion(CanteenViewModel.viewModel)
            }
        }
    }
}

func parse(from json: [String: Any]) -> [Canteen] {
    
    var canteens = [Canteen]()
    
    for (canteen, any) in json {
        
        if (canteen == Constants.API_DATE || canteen == Constants.API_IMPORT_DATE) {
            continue
        }
        
        let canteenContent = any as! [String:Any]
        var foodOnDayX = [Int:[FoodLine]]()
        
        for i in 0...29 {
            let dayOptional = canteenContent[String(nextThirtyDaysUnix()[i])]
            var day:[String:Any] = [:]
            if (dayOptional is [String:Any]) {
                day = dayOptional as! [String:Any]
            }
            var foodLines = [FoodLine]()
            
            for (foodLineStr, any) in day {
                
                var foods = [Food]()
                let foodContent = any as! [[String:Any]]
                let closingText = foodContent[0][Constants.API_CLOSING_TEXT] as? String
                let noFoodBool = foodContent[0][Constants.API_NODATA] as? Bool
                
                if (closingText != nil) {
                    foodLines.append(FoodLine(shortName: foodLineStr, closingText: closingText!))
                }
                else if (noFoodBool != nil) {
                    foodLines.append(FoodLine(shortName: foodLineStr, foods: []))
                }
                else {
                    let jsonData = try! JSONSerialization.data(withJSONObject: foodContent, options: .prettyPrinted)
                    
                    do {
                        let foodModel = try JSONDecoder().decode([FoodModel].self, from: jsonData)
                        
                        for food in foodModel {
                            foods.append(Food(foodModel: food))
                        }
                    } catch {
                        foods = []
                    }
                    foodLines.append(FoodLine(shortName: foodLineStr, foods: foods))
                }
            }
            foodLines.sort()
            foodOnDayX[i] = foodLines
        }
        canteens.append(Canteen(shortName: canteen, foodOnDayX: foodOnDayX))
    }
    canteens.sort()
    
    var date = Date()
    
    //if it's past 5 o'clock, display food for next day (Mensa already closed for current day)
    
    if (Calendar.current.component(.hour, from: date) >= Constants.CANTEEN_CLOSING) && !Calendar.current.isDateInWeekend(date) {
        for c in canteens {
            c.foodOnDayX = c.foodOnDayX.mapKeys({$0 - 1}).filter({$0.key >= 0})
        }
        var dayComponent = DateComponents()
        dayComponent.day = 1
        date = Calendar.current.date(byAdding: dayComponent, to: Date()) ?? Date()
        //date = Calendar.current.date(bySettingHour: 3, minute: 0, second: 0, of: date)!
    }
    return canteens
}

//Returns array of unix times of next thirty days at midnight
func nextThirtyDaysUnix() -> [Int] {
    
    var nextThirtyDays = [Int]()
    let date2 = Date()
    let cal = Calendar(identifier: .gregorian)
    var date3 = cal.startOfDay(for: date2)
    for _ in 0...29 {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.DATE_FORMAT_EEEE
        let dayname:String = String(dateFormatter.string(from: date3))
        
        if (dayname.elementsEqual(Constants.SATURDAY)) {
            date3 = date3.dayAfter.dayAfter
            date3 = cal.startOfDay(for: date3)
        }
        else if (dayname.elementsEqual(Constants.SUNDAY)) {
            date3 = date3.dayAfter
            date3 = cal.startOfDay(for: date3)
        }
        
        let unixTime = date3.timeIntervalSince1970
        date3 = date3.dayAfter
        date3 = cal.startOfDay(for: date3)
        nextThirtyDays.append(Int(unixTime))
    }
    return nextThirtyDays
}
