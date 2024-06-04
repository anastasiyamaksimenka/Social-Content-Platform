//
//  IAPManager.swift
//  Blog
//
//  Created by Anastasiya Maksimenka on 27/12/2023.
//

import Foundation
import Purchases
import StoreKit

final class IAPManager{
    static let shared = IAPManager()
    
    static let formatter = ISO8601DateFormatter()
    
    private  init(){}
    
    
    private var postEligibleViewDate: Date? {
        get {
            guard let string = UserDefaults.standard.string(forKey: "postEligibleViewDate") else {
                return nil
            }
            return IAPManager.formatter.date(from: string)
        }
        set {
            guard let date = newValue else {
                return
            }
            let string = IAPManager.formatter.string(from: date)
            UserDefaults.standard.set(string, forKey: "postEligibleViewDate")
        }
    }
    
    func isPremium() -> Bool {
        return false
    }
    
    func subscribe(){
        
    }
    
    func restorePurchases(){
        
    }
}
extension IAPManager {
    var canViewPost: Bool {
        if isPremium() {
            return true
        }
        
        guard let date = postEligibleViewDate else {
            return true
        }
        UserDefaults.standard.set(0, forKey: "post_views")
        return Date() >= date
    }
    
    
    public func logPostViewed() {
        let total = UserDefaults.standard.integer(forKey: "post_views")
        UserDefaults.standard.set(total+1, forKey: "post_views")
        
        if total == 2 {
            let hour: TimeInterval = 60 * 60
            postEligibleViewDate = Date().addingTimeInterval(hour * 24)
        }
    }
    
}

