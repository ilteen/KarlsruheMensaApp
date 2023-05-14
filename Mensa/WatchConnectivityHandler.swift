//
//  ConnectivityRequestHandler.swift
//  Mensa
//
//  Created by Philipp on 27.10.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation
import WatchConnectivity

class WatchConnectivityHandler: NSObject, ObservableObject {
    
    public static let shared = WatchConnectivityHandler()
    
    var session = WCSession.default
    
    private override init() {
        super.init()
        self.session.delegate = self
        if session.activationState != .activated {
            self.session.activate()
        }
    }
    
    func sendCanteenDataToWatch(canteen: Canteen, priceGroup: Int) {
        if self.session.isReachable {
            if let encodedData = try? JSONEncoder().encode(canteen) {
                self.session.sendMessage(["canteen" : encodedData, "priceGroup" : priceGroup], replyHandler: nil)
            }
        }
        else {
            print("Watch App not reachable! Transfering user info...")
            if let encodedData = try? JSONEncoder().encode(canteen) {
                self.session.transferUserInfo(["canteen" : encodedData, "priceGroup" : priceGroup])
            }
        }
    }
    
    func sendUpdatedPriceGroupToWatch(priceGroup: Int) {
        if self.session.isReachable {
            self.session.sendMessage(["priceGroup" : priceGroup], replyHandler: nil)
        }
        else {
            print("Watch App not reachable! Transfering user info...")
            self.session.transferUserInfo(["priceGroup" : priceGroup])
        }
    }
}

extension WatchConnectivityHandler: WCSessionDelegate {
    
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        debugPrint("WCSession activationDidCompleteWith activationState:\(activationState) error:\(String(describing: error))")
        debugPrint("WCSession.isPaired: \(session.isPaired), WCSession.isWatchAppInstalled: \(session.isWatchAppInstalled)")
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        debugPrint("sessionDidBecomeInactive: \(session)")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        debugPrint("sessionDidDeactivate: \(session)")
    }
    
    func sessionWatchStateDidChange(_ session: WCSession) {
        debugPrint("sessionWatchStateDidChange: \(session)")
    }
}
