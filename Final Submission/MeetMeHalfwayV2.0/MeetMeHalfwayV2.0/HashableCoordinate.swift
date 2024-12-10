//
//  HashableCoordinate.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/27/24.
//

import Foundation
import CoreLocation

// Wrapper for CLLocationCoordinate2D to make it conform to Hashable
struct HashableCoordinate: Hashable {
    let coordinate: CLLocationCoordinate2D
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(coordinate.latitude)
        hasher.combine(coordinate.longitude)
    }
    
    static func == (lhs: HashableCoordinate, rhs: HashableCoordinate) -> Bool {
        lhs.coordinate.latitude == rhs.coordinate.latitude && lhs.coordinate.longitude == rhs.coordinate.longitude
    }
}
