//
//  FavoriteResults.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/27/24.
//

import Foundation

struct FavoriteResults: Hashable, Identifiable, Equatable, Encodable, Decodable {
    let id: UUID
    let location1Name: String
    let location2Name: String
    let meetingPointName: String
    let meetingPointCoordinate: EncodableCoordinate
    var favoritePlaces: [String] = []
    
    static func == (lhs: FavoriteResults, rhs: FavoriteResults) -> Bool {
        return lhs.id == rhs.id &&
        lhs.location1Name == rhs.location1Name &&
        lhs.location2Name == rhs.location2Name &&
        lhs.meetingPointName == rhs.meetingPointName &&
        lhs.meetingPointCoordinate.latitude == rhs.meetingPointCoordinate.latitude &&
        lhs.meetingPointCoordinate.longitude == rhs.meetingPointCoordinate.longitude &&
        lhs.favoritePlaces == rhs.favoritePlaces
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(location1Name)
        hasher.combine(location2Name)
        hasher.combine(meetingPointName)
        hasher.combine(meetingPointCoordinate.latitude)
        hasher.combine(meetingPointCoordinate.longitude)
        hasher.combine(favoritePlaces)
    }
}
