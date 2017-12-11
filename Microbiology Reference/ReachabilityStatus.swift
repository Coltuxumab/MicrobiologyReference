//
//  ReachabilityStatus.swift
//  Pathology Reference
//
//  Created by Cole Denkensohn on 11/12/17.
//  Copyright © 2017 Denkensohn. All rights reserved.
//

import Foundation
import SystemConfiguration

protocol Utilities {
}

extension NSObject:Utilities{
    
    
    enum ReachabilityStatus {
        case notReachable
        case reachableViaWWAN
        case reachableViaWiFi
    }
    
    
    var currentReachabilityStatus: ReachabilityStatus {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return .notReachable
        }
        
        // Begin: Added by Cole Denkensohn
        // The surrounding code works well for detecting internet connection but leaves out one circumstance: wifi is available, user is connected, but user must accept terms to view any page other than the terms page. The following block of code tries to access Apple.com to download the contents and fails even in the above situation. It is likely the only bit of code needed here and can likely be improved by loading a less resource-intensive website than Apple.com
        do {
            _ = try String(contentsOf: URL(string: "https://www.apple.com")!)
        } catch {
            // Case where there IS wifi/internet but it doesn't work
            print ("File Read Error: From within InternetConnectivity.swift")
            return .notReachable
        }
        // End: Added by Cole Denkensohn
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return .notReachable
        }
        
        if flags.contains(.reachable) == false {
            // The target host is not reachable.
            return .notReachable
        }
        else if flags.contains(.isWWAN) == true {
            // WWAN connections are OK if the calling application is using the CFNetwork APIs.
            return .reachableViaWWAN
        }
        else if flags.contains(.connectionRequired) == false {
            // If the target host is reachable and no connection is required then we'll assume that you're on Wi-Fi...
            return .reachableViaWiFi
        }
        else if (flags.contains(.connectionOnDemand) == true || flags.contains(.connectionOnTraffic) == true) && flags.contains(.interventionRequired) == false {
            // The connection is on-demand (or on-traffic) if the calling application is using the CFSocketStream or higher APIs and no [user] intervention is needed
            return .reachableViaWiFi
        }
        else {
            return .notReachable
        }
    }
    
}
