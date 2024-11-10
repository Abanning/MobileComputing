//
//  EncodableCoordinate.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/27/24.
//

import Foundation

// Custom struct for coordinates
struct EncodableCoordinate: Hashable, Identifiable, Equatable, Encodable, Decodable {
    let id: UUID
    var latitude: Double
    var longitude: Double
}
