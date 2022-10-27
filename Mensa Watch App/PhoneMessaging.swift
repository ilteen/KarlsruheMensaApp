//
//  PhoneMessaging.swift
//  Watch Mensa Extension
//
//  Created by Philipp on 27.10.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation
import WatchConnectivity
class PhoneMessaging: NSObject, ObservableObject {
    
    @Published var canteenSelection: Int = 0
    @Published var priceGroup: Int = 0
    
    var session: WCSession?

    override init() {
        self.session = WCSession.default
        super.init()
        self.session?.delegate = self
        self.session?.activate()
        
        self.canteenSelection = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_CANTEEN)
        self.priceGroup = UserDefaults.standard.integer(forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
    }
}

extension PhoneMessaging: WCSessionDelegate {
    func session(_: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("activationDidCompleteWith activationState:\(activationState.rawValue), error: \(String(describing: error))")
    }
    
    //when app is running on watch as well as on phone -> immediate ui change on watch, if canteen changes on phone
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        if let newCanteenSelection = message["canteenSelection"] as? Int {
            self.canteenSelection = newCanteenSelection
            UserDefaults.standard.set(newCanteenSelection, forKey: Constants.KEY_CHOSEN_CANTEEN)
            print("updated canteen selection!")
            print("new selection: \(newCanteenSelection)")
        }
        
        if let newPriceGroup = message["priceGroup"] as? Int {
            self.priceGroup = newPriceGroup
            UserDefaults.standard.set(newPriceGroup, forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
            print("updated price group!")
            print("new selection: \(newPriceGroup)")
        }
    }
    
    //when watch app is not running
    func session(_ session: WCSession, didReceiveUserInfo userInfo: [String : Any] = [:]) {
        if let newCanteenSelection = userInfo["canteenSelection"] as? Int {
            UserDefaults.standard.set(newCanteenSelection, forKey: Constants.KEY_CHOSEN_CANTEEN)
            self.canteenSelection = newCanteenSelection
        }
        
        if let newPriceGroup = userInfo["priceGroup"] as? Int {
            self.priceGroup = newPriceGroup
            UserDefaults.standard.set(newPriceGroup, forKey: Constants.KEY_CHOSEN_PRICE_GROUP)
            print("updated price group!")
            print("new selection: \(newPriceGroup)")
        }
    }
}
