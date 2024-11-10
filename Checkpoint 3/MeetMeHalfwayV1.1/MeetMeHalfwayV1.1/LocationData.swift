//
//  LocationData.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/25/24.
//

import Foundation
import MapKit
import SwiftUI
import CoreLocation

struct LocationData: Hashable, Equatable {
    var textLocation1: String
    var textLocation2: String
    var coordinate1: CLLocationCoordinate2D
    var coordinate2: CLLocationCoordinate2D
    
    static func == (lhs: LocationData, rhs: LocationData) -> Bool {
        return lhs.textLocation1 == rhs.textLocation1 &&
               lhs.textLocation2 == rhs.textLocation2 &&
               lhs.coordinate1.latitude == rhs.coordinate1.latitude &&
               lhs.coordinate1.longitude == rhs.coordinate1.longitude &&
               lhs.coordinate2.latitude == rhs.coordinate2.latitude &&
               lhs.coordinate2.longitude == rhs.coordinate2.longitude
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(textLocation1)
        hasher.combine(textLocation2)
        hasher.combine(coordinate1.latitude)
        hasher.combine(coordinate1.longitude)
        hasher.combine(coordinate2.latitude)
        hasher.combine(coordinate2.longitude)
    }
}
