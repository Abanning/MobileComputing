//
//  SavedTrip.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/27/24.
//

import Foundation

struct SavedTrip: Identifiable, Hashable {
    let id = UUID()
    var URL: String
    var location1: String
    var location2: String
    var meetingPoint: String
}
