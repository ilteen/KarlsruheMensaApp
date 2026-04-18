//
//  Food.swift
//  Mensa
//
//  Created by Philipp on 15.11.19.
//  Copyright © 2019 Philipp. All rights reserved.
//

import Foundation

class Food: Codable, Identifiable, ObservableObject {
    var id = UUID()
    var apiMealID: String?
    var name: String
    var bio: Bool
    var allergens: [Allergen]
    var prices: [Float]
    var foodClass: FoodClass
    var priceInfo: String
    var nutritionalInfo: NutritionalInfo?
    @Published var imageURL: URL?
    @Published var imageEntries: [FoodImageEntry]
    @Published var averageRating: Double?
    @Published var ratingsCount: Int
    @Published var personalRating: Int?
    @Published var showNutritionalInfo = false

    enum CodingKeys: String, CodingKey {
        case apiMealID
        case name
        case bio
        case allergens
        case prices
        case foodClass
        case priceInfo
        case nutritionalInfo
        case imageEntries
        case averageRating
        case ratingsCount
        case personalRating
    }

    init(
        apiMealID: String? = nil,
        name: String,
        bio: Bool,
        allergens: [String],
        prices: [Float],
        foodClass: FoodClass,
        nutritionalInfo: NutritionalInfo?,
        imageURL: URL? = nil,
        imageEntries: [FoodImageEntry] = [],
        averageRating: Double? = nil,
        ratingsCount: Int = 0,
        personalRating: Int? = nil
    ) {
        self.apiMealID = apiMealID
        self.name = name
        self.bio = bio
        self.allergens = allergens.flatMap { parseAllergens(from: $0) }
        self.prices = prices
        self.foodClass = foodClass
        self.priceInfo = Constants.EMPTY
        self.nutritionalInfo = nutritionalInfo
        self.imageURL = imageURL
        self.imageEntries = imageEntries
        self.averageRating = averageRating
        self.ratingsCount = ratingsCount
        self.personalRating = personalRating
    }
    
    init(closingText: String) {
        self.apiMealID = nil
        self.name = Constants.EMPTY
        self.bio = false
        self.allergens = []
        self.prices = []
        self.foodClass = FoodClass.vegan
        self.priceInfo = Constants.EMPTY
        self.nutritionalInfo = nil
        self.imageURL = nil
        self.imageEntries = []
        self.averageRating = nil
        self.ratingsCount = 0
        self.personalRating = nil
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.apiMealID = try container.decodeIfPresent(String.self, forKey: .apiMealID)
        self.name = try container.decode(String.self, forKey: .name)
        self.bio = try container.decode(Bool.self, forKey: .bio)
        if let decodedAllergens = try? container.decode([Allergen].self, forKey: .allergens) {
            self.allergens = decodedAllergens
        } else {
            let rawAllergens = try container.decode([String].self, forKey: .allergens)
            self.allergens = rawAllergens.compactMap { Allergen.from(rawCode: $0) }
        }
        self.prices = try container.decode([Float].self, forKey: .prices)
        self.foodClass = try container.decode(FoodClass.self, forKey: .foodClass)
        self.priceInfo = try container.decode(String.self, forKey: .priceInfo)
        self.nutritionalInfo = try container.decodeIfPresent(NutritionalInfo.self, forKey: .nutritionalInfo)
        self.imageEntries = try container.decodeIfPresent([FoodImageEntry].self, forKey: .imageEntries) ?? []
        self.averageRating = try container.decodeIfPresent(Double.self, forKey: .averageRating)
        self.ratingsCount = try container.decodeIfPresent(Int.self, forKey: .ratingsCount) ?? 0
        self.personalRating = try container.decodeIfPresent(Int.self, forKey: .personalRating)
        self.imageURL = self.imageEntries.first?.url
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(apiMealID, forKey: .apiMealID)
        try container.encode(name, forKey: .name)
        try container.encode(bio, forKey: .bio)
        try container.encode(allergens, forKey: .allergens)
        try container.encode(prices, forKey: .prices)
        try container.encode(foodClass, forKey: .foodClass)
        try container.encode(priceInfo, forKey: .priceInfo)
        try container.encodeIfPresent(nutritionalInfo, forKey: .nutritionalInfo)
        try container.encode(imageEntries, forKey: .imageEntries)
        try container.encodeIfPresent(averageRating, forKey: .averageRating)
        try container.encode(ratingsCount, forKey: .ratingsCount)
        try container.encodeIfPresent(personalRating, forKey: .personalRating)
    }
}

struct FoodImageEntry: Codable, Identifiable {
    let id: String
    let url: URL
    var rank: Double?
    var personalDownvote: Bool?
    var personalUpvote: Bool?
    var downvotes: Int?
    var upvotes: Int?
}

enum Allergen: String, Codable, CaseIterable, Hashable, Identifiable {
    case ca
    case di
    case ei
    case er
    case fi
    case ge
    case hf
    case ha
    case ka
    case kr
    case lu
    case ma
    case ml
    case pa
    case pe
    case pi
    case qu
    case ro
    case sa
    case se
    case sf
    case sn
    case so
    case wa
    case we
    case wt
    case la
    case gl
    
    var id: String { rawValue }
    
    var code: String { rawValue.uppercased() }
    
    var localizedName: String {
        let isGerman = Locale.current.languageCode?.prefix(2) == "de"
        switch self {
        case .ca: return isGerman ? "Cashewnuesse" : "Cashew nuts"
        case .di: return isGerman ? "Dinkel / Gluten aus Dinkel" : "Spelt / gluten from spelt"
        case .ei: return isGerman ? "Eier" : "Eggs"
        case .er: return isGerman ? "Erdnuesse" : "Peanuts"
        case .fi: return isGerman ? "Fisch" : "Fish"
        case .ge: return isGerman ? "Gerste / Gluten aus Gerste" : "Barley / gluten from barley"
        case .hf: return isGerman ? "Hafer / Gluten aus Hafer" : "Oats / gluten from oats"
        case .ha: return isGerman ? "Haselnuesse" : "Hazelnuts"
        case .ka: return isGerman ? "Kamut / Gluten aus Kamut" : "Kamut / gluten from kamut"
        case .kr: return isGerman ? "Krebstiere" : "Crustaceans"
        case .lu: return isGerman ? "Lupine" : "Lupin"
        case .ma: return isGerman ? "Mandeln" : "Almonds"
        case .ml: return isGerman ? "Milch / Laktose" : "Milk / lactose"
        case .pa: return isGerman ? "Paranuesse" : "Brazil nuts"
        case .pe: return isGerman ? "Pekannuesse" : "Pecans"
        case .pi: return isGerman ? "Pistazien" : "Pistachios"
        case .qu: return isGerman ? "Queenslandnuesse / Macadamianuesse" : "Macadamia nuts"
        case .ro: return isGerman ? "Roggen / Gluten aus Roggen" : "Rye / gluten from rye"
        case .sa: return isGerman ? "Sesam" : "Sesame"
        case .se: return isGerman ? "Sellerie" : "Celery"
        case .sf: return isGerman ? "Schwefeldioxid / Sulfit" : "Sulfur dioxide / sulfites"
        case .sn: return isGerman ? "Senf" : "Mustard"
        case .so: return isGerman ? "Soja" : "Soy"
        case .wa: return isGerman ? "Walnuesse" : "Walnuts"
        case .we: return isGerman ? "Weizen / Gluten aus Weizen" : "Wheat / gluten from wheat"
        case .wt: return isGerman ? "Weichtiere" : "Molluscs"
        case .la: return isGerman ? "Tierisches Lab" : "Animal rennet"
        case .gl: return isGerman ? "Gelatine" : "Gelatin"
        }
    }
    
    var localizedShortLabel: String {
        code
    }
    
    static func from(rawCode: String) -> Allergen? {
        let code = rawCode.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return Allergen(rawValue: code)
    }
}


enum FoodClass: Codable {
    case vegetarian
    case vegan
    case beef
    case beefLocal
    case pork
    case porkLocal
    case fish
    case nothing
}
