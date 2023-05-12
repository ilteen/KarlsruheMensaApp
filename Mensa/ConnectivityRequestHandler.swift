//
//  ConnectivityRequestHandler.swift
//  Mensa
//
//  Created by Philipp on 27.10.22.
//  Copyright © 2022 Philipp. All rights reserved.
//

import Foundation
import WatchConnectivity

class ConnectivityRequestHandler: NSObject, ObservableObject {
    
    var session = WCSession.default
    
    override init() {
        super.init()
        self.session.delegate = self
        if session.activationState != .activated {
            self.session.activate()
        }
    }
    
    func sendUpdatedCanteenSelectionToWatch(canteenSelection: Canteens) {
        if self.session.isReachable {
            self.session.sendMessage(["canteenSelection" : canteenSelection], replyHandler: nil)
        }
        else {
            print("Watch App not reachable! Trying to update application context")
            self.session.transferUserInfo(["canteenSelection" : canteenSelection])
        }
    }
    
    func sendUpdatedPriceGroupToWatch(priceGroup: Int) {
        if self.session.isReachable {
            self.session.sendMessage(["priceGroup" : priceGroup], replyHandler: nil)
        }
        else {
            print("Watch App not reachable! Trying to update application context")
            self.session.transferUserInfo(["priceGroup" : priceGroup])
        }
    }
}

extension ConnectivityRequestHandler: WCSessionDelegate {
    
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
