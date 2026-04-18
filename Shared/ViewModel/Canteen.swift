//
//  Canteen.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

class Canteen: ObservableObject, Codable {
    @Published var name: String
    @Published var foodOnDayX: [Int: [FoodLine]]
    @Published var dateOfLastFetching: Date
    @Published var nextOpenDays: [Date]
    
    enum CodingKeys: String, CodingKey {
        case name
        case foodOnDayX
        case dateOfLastFetching
        case nextOpenDays
    }
    
    init(name: String, foodOnDayX: [Int: [FoodLine]], dateOfLastFetching: Date) {
        self.name = name
        self.foodOnDayX = foodOnDayX
        self.dateOfLastFetching = dateOfLastFetching
        self.nextOpenDays = getNextWorkingDays(date: dateOfLastFetching, count: Constants.DAYS_TO_FETCH)
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.foodOnDayX = try container.decode([Int: [FoodLine]].self, forKey: .foodOnDayX)
        self.dateOfLastFetching = try container.decode(Date.self, forKey: .dateOfLastFetching)
        self.nextOpenDays = try container.decode([Date].self, forKey: .nextOpenDays)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(foodOnDayX, forKey: .foodOnDayX)
        try container.encode(dateOfLastFetching, forKey: .dateOfLastFetching)
        try container.encode(nextOpenDays, forKey: .nextOpenDays)
    }
}

