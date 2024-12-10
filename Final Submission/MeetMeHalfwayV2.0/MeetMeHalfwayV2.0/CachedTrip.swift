//
//  CachedTrip.swift
//  MeetMeHalfwayV2.0
//
//  Created by Alex Banning on 12/9/24.
//

import Foundation
import CoreLocation

struct CachedTrip: Identifiable, Codable, Hashable, Equatable {
    let id = UUID()
    let location1: String?
    let coordinate1: CLLocationCoordinate2D?
    let location2: String?
    let coordinate2: CLLocationCoordinate2D?
    let meetingPoint: String?
    let meetingPointCoordinate: CLLocationCoordinate2D?
    let favoriteResults: [String]?
    
    static func == (lhs: CachedTrip, rhs: CachedTrip) -> Bool {
        return lhs.id == rhs.id &&
        lhs.location1 == rhs.location1 &&
        lhs.coordinate1?.latitude == rhs.coordinate1?.latitude &&
        lhs.coordinate1?.longitude == rhs.coordinate1?.longitude &&
        lhs.location2 == rhs.location2 &&
        lhs.coordinate2?.latitude == rhs.coordinate2?.latitude &&
        lhs.coordinate2?.longitude == rhs.coordinate2?.longitude &&
        lhs.meetingPoint == rhs.meetingPoint &&
        lhs.meetingPointCoordinate?.latitude == rhs.meetingPointCoordinate?.latitude &&
        lhs.meetingPointCoordinate?.longitude == rhs.meetingPointCoordinate?.longitude &&
        lhs.favoriteResults == rhs.favoriteResults
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(location1)
        hasher.combine(coordinate1?.latitude)
        hasher.combine(coordinate1?.longitude)
        hasher.combine(location2)
        hasher.combine(coordinate2?.latitude)
        hasher.combine(coordinate2?.longitude)
        hasher.combine(meetingPoint)
        hasher.combine(meetingPointCoordinate?.latitude)
        hasher.combine(meetingPointCoordinate?.longitude)
        hasher.combine(favoriteResults)
    }
    
    // Conforming to Decodable and Encodable
    enum CodingKeys: String, CodingKey {
        case location1, coordinate1, location2, coordinate2, meetingPoint, meetingPointCoordinate, favoriteResults
    }
    
    // Custom Decodable initializer
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // Decode all properties
        self.location1 = try container.decodeIfPresent(String.self, forKey: .location1)
        self.coordinate1 = try container.decodeIfPresent([Double].self, forKey: .coordinate1)?.coordinate
        self.location2 = try container.decodeIfPresent(String.self, forKey: .location2)
        self.coordinate2 = try container.decodeIfPresent([Double].self, forKey: .coordinate2)?.coordinate
        self.meetingPoint = try container.decodeIfPresent(String.self, forKey: .meetingPoint)
        self.meetingPointCoordinate = try container.decodeIfPresent([Double].self, forKey: .meetingPointCoordinate)?.coordinate
        self.favoriteResults = try container.decodeIfPresent([String].self, forKey: .favoriteResults)
    }
    
    // Custom Encodable method
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // Encode all properties
        try container.encodeIfPresent(location1, forKey: .location1)
        try container.encodeIfPresent(coordinate1?.toArray(), forKey: .coordinate1)
        try container.encodeIfPresent(location2, forKey: .location2)
        try container.encodeIfPresent(coordinate2?.toArray(), forKey: .coordinate2)
        try container.encodeIfPresent(meetingPoint, forKey: .meetingPoint)
        try container.encodeIfPresent(meetingPointCoordinate?.toArray(), forKey: .meetingPointCoordinate)
        try container.encodeIfPresent(favoriteResults, forKey: .favoriteResults)
    }
}

// Extension to convert CLLocationCoordinate2D to an array of Doubles
extension CLLocationCoordinate2D {
    func toArray() -> [Double] {
        return [self.latitude, self.longitude]
    }
}

extension Array where Element == Double {
    // Converts an array of 2 elements [latitude, longitude] to CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D? {
        guard self.count == 2 else { return nil }
        return CLLocationCoordinate2D(latitude: self[0], longitude: self[1])
    }
}
