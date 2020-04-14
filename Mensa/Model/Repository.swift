//
//  Repository.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

struct Repository {
    
    func get(completion: @escaping ([Canteen]?) -> ()) {
        let url = URL(string: "https://www.sw-ka.de/json_interface/canteen/")!
        let username = "jsonapi"
        let password = "AhVai6OoCh3Quoo6ji"
        
        let loginString = String(format: "%@:%@", username, password)
        let loginData = loginString.data(using: String.Encoding.utf8)!
        let base64String = loginData.base64EncodedString()
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = "GET"
        urlRequest.setValue("Basic \(base64String)", forHTTPHeaderField: "Authorization")
        
        var canteens: [Canteen]? = nil
        
        let _: Void = URLSession.shared.dataTask(with: urlRequest) { data, response, error  in
            
            if let data = data {
                
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: []) as! [String:Any]
                    canteens = parse(from: json)
                } catch {
                    canteens = nil
                }
                DispatchQueue.main.async {
                    completion(canteens)
                }
            }
            else {
                DispatchQueue.main.async {
                    completion(nil)
                }
            }
        }
        .resume()
    }
}

func parse(from json: [String: Any]) -> [Canteen] {
    
    var canteens = [Canteen]()
    let nextSevenDays = nextSevenDaysUnix()
    
    for (canteen, any) in json {
        
        if (canteen == "date" || canteen == "import_date") {
            continue
        }
        
        let canteenContent = any as! [String:Any]
        
        var foodOnDayX = [Int:[FoodLine]]()
        
        for i in 0...6 {
            let dayOptional = canteenContent[String(nextSevenDays[i])]
            var day:[String:Any] = [:]
            if (dayOptional is [String:Any]) {
                day = dayOptional as! [String:Any]
            }
            var foodLines = [FoodLine]()
            
            for (foodLineStr, any) in day {
                    
                var foods = [Food]()
                let foodContent = any as! [[String:Any]]
                let closingText = foodContent[0]["closing_text"] as? String
                let noFoodBool = foodContent[0]["nodata"] as? Bool

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
    return canteens
}

//Returns array of unix times of next seven days at midnight
func nextSevenDaysUnix() -> [Int]{
    
    var nextSevenDays = [Int]()
    let date2 = Date()
    let cal = Calendar(identifier: .gregorian)
    var date3 = cal.startOfDay(for: date2)
    for _ in 0...6 {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        let dayname:String = String(dateFormatter.string(from: date3))
        
        if (dayname.elementsEqual(NSLocalizedString("Saturday", comment: ""))) {
            date3 = date3.dayAfter.dayAfter
            date3 = cal.startOfDay(for: date3)
        }
        else if (dayname.elementsEqual(NSLocalizedString("Sunday", comment: ""))) {
            date3 = date3.dayAfter
            date3 = cal.startOfDay(for: date3)
        }
        
        let unixTime = date3.timeIntervalSince1970
        date3 = date3.dayAfter
        date3 = cal.startOfDay(for: date3)
        nextSevenDays.append(Int(unixTime))
    }
    return nextSevenDays
}
