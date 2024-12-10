//
//  City.swift
//  MeetMeHalfwayV2.0
//
//  Created by Alex Banning on 12/4/24.
//

import Foundation
import CoreLocation

struct City: Identifiable, Hashable, Equatable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    
    // Automatically synthesized == operator and hash functions
        static func == (lhs: City, rhs: City) -> Bool {
            lhs.name == rhs.name &&
            lhs.coordinate.latitude == rhs.coordinate.latitude &&
            lhs.coordinate.longitude == rhs.coordinate.longitude
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(name)
            hasher.combine(coordinate.latitude)
            hasher.combine(coordinate.longitude)
        }
}
