//
//  LocationTracker.swift
//  TrackMeSwiftly
//
//  Created by Raphael Guntersweiler on 03.11.19.
//  Copyright © 2019 Raphael Guntersweiler. All rights reserved.
//

import Foundation
import CoreLocation
import os.log
import UIKit
import CoreData

class LocationTracker : NSObject, CLLocationManagerDelegate, ObservableObject {
    // MARK: - Constants
    let breadSize: Double = 13;
    
    // MARK: - Published Properties
    @Published var authStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation = nil
    @Published var lastSpeedReceived: Date = Date.init(timeIntervalSince1970: 0)

    // MARK: - Normal Properties
    // Returns the current authorization status as String
    var authStatusString: String {
        return getStringForAuthStatus(status: self.authStatus)
    }
    
    var isSpeedInfoAvailable: Bool {
        if (self.lastLocation == nil) { return false }
        if (self.lastLocation!.speed.isLess(than: 0)) { return false }
        return true
    }
    
    var currentSpeedKmh: Double {
        return (self.lastLocation?.speed ?? 0) * 3.6
    }
    var currentSpeedMph: Double {
        return (self.lastLocation?.speed ?? 0) * 2.236936
    }
    
    var currentLocationAccuracy: Double {
        return (self.lastLocation?.horizontalAccuracy ?? -1)
    }
    
    // MARK: - Speed Properties (in Fun Units)
    /** Speed in Mettbrötchen per Minute */
    var currentSpeedMettbPm: Double {
        return (self.lastLocation?.speed ?? 0) * 60 /* m/min */ * 100 /* cm/min */ / self.breadSize /* Mettb/min */
    }
    /** Speed in Mettbrötchen per Second */
    var currentSpeedMettbPs: Double {
        return (self.lastLocation?.speed ?? 0) * 100 /* cm/s */ / self.breadSize /* Mettb/s */
    }

    // MARK: - Private Properties
    private var locMgr: CLLocationManager
    
    // MARK: - Constructor
    override init() {
        os_log("LT Initializing …")

        let mgr = CLLocationManager()
        self.locMgr = mgr
        super.init()

        mgr.delegate = self
        mgr.desiredAccuracy = kCLLocationAccuracyBest
        
        os_log("LT Requesting authorization for location …")
        mgr.requestAlwaysAuthorization()
    }
    
    // MARK: - Location Manager events
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        os_log("LT Auth Status changed: %s", getStringForAuthStatus(status: status))
        self.authStatus = status
        
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            self.locMgr.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        os_log("LT Received location update")
        self.lastLocation = locations[locations.count - 1]
        
        if self.isSpeedInfoAvailable {
            self.lastSpeedReceived = self.lastLocation?.timestamp ?? Date.init(timeIntervalSince1970: 0)
        }
    }
}

// MARK: - Util Functions
func getStringForAuthStatus(status: CLAuthorizationStatus) -> String {
    switch status {
    case .denied:
        return "Denied"
    case .notDetermined:
        return "Not determined"
    case .restricted:
        return "Restricted"
    case .authorizedAlways:
        return "Authorized always"
    case .authorizedWhenInUse:
        return "Authorized when in use"
    default:
        return "Unknown"
    }
}
