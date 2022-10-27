//
//  Repository.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct Repository {
    
    func test(completion: @escaping ([Canteen]?) -> ()) {
        let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }
    
    func saveJSON(json: Data) {
        let pathDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        try? FileManager().createDirectory(at: pathDirectory, withIntermediateDirectories: true)
        let filePath = pathDirectory.appendingPathComponent("database.json")
        
        do {
             try json.write(to: filePath)
        } catch {
            print("Failed to write JSON data: \(error.localizedDescription)")
        }
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
