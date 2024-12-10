//
//  BusinessDetails.swift
//  MeetMeHalfwayV2.0
//
//  Created by Alex Banning on 12/5/24.
//

import Foundation
import SwiftUI

struct SingleBusinessResponse: Codable {
    let businesses: [Business]
}

struct Business: Codable {
    let id: String
}

// Struct to represent a review
struct Review: Decodable {
    var user: User
    var rating: Int
    var text: String
}

// Struct to represent a user in the review
struct User: Decodable {
    var name: String
    var imageUrl: String
}

// BusinessDetails with Decodable conformance
struct BusinessDetails: Decodable {
    var alias: String
    var categories: [Category]?
    var coordinates: Coordinates
    var display_phone: String?
    var id: String
    var imageURL: String?
    var isClaimed: Bool?
    var isClosed: Bool?
    var location: Location
    var name: String?
    var phone: String?
    var photos: [String]?
    var price: String?
    var rating: Double?
    var reviewCount: Int?
    var hours: Hours?
    var specialHours: [SpecialHour]?
    var transactions: [String]?
    var url: String?
    var attributes: Attributes?
    var messaging: Messaging?
    var yelpMenuURL: String?
    var rapc: Rapc?
    
    // Custom initializer if necessary
    init(alias: String, categories: [Category]?, coordinates: Coordinates, display_phone: String?, id: String, imageURL: String?, isClaimed: Bool?, isClosed: Bool?, location: Location, name: String?, phone: String?, photos: [String]?, price: String?, rating: Double?, reviewCount: Int?, hours: Hours, specialHours: [SpecialHour]?, transactions: [String], url: String, attributes: Attributes?, messaging: Messaging?, yelpMenuURL: String, rapc: Rapc?) {
        self.alias = alias
        self.categories = categories
        self.coordinates = coordinates
        self.display_phone = display_phone
        self.id = id
        self.imageURL = imageURL
        self.isClaimed = isClaimed
        self.isClosed = isClosed
        self.location = location
        self.name = name
        self.phone = phone
        self.photos = photos
        self.price = price
        self.rating = rating
        self.reviewCount = reviewCount
        self.hours = hours
        self.specialHours = specialHours
        self.transactions = transactions
        self.url = url
        self.attributes = attributes
        self.messaging = messaging
        self.yelpMenuURL = yelpMenuURL
        self.rapc = rapc
    }
}

// Struct for Category
struct Category: Decodable {
    var alias: String
    var title: String
}

// Struct for Coordinates (latitude and longitude)
struct Coordinates: Decodable {
    var latitude: Double
    var longitude: Double
}

// Struct for Location (address and city)
struct Location: Decodable {
    var address1: String
    var address2: String?
    var address3: String?
    var city: String
    var country: String
    var display_address: [String]
    var state: String
    var zip_code: String
}

// Struct for Hours of operation
struct Hours: Decodable {
    var open: [OpeningTime]?
    var hours_type: String?
    var is_open_now: Bool?
    
    struct OpeningTime: Decodable {
        var is_overnight: Bool
        var start: Int
        var end: Int
        var day: Int
    }
}

// Struct for Special Hours
struct SpecialHour: Decodable {
    var date: String
    var start: String
    var end: String
    var isClosed: Bool?
    var isOvernight: Bool
}

// Struct for Attributes (optional fields related to the business)
struct Attributes: Decodable {
    var businessTempClosed: Int?
    var outdoorSeating: Bool?
    var likedByVegans: Bool?
    var likedByVegetarians: Bool?
    var hotAndNew: String?
}

// Struct for Messaging (contact through Yelp)
struct Messaging: Decodable {
    var url: String
    var useCaseText: String
    var responseRate: Int
    var responseTime: Int
    var isEnabled: Bool
}

// Struct for Rapc (business eligibility status)
struct Rapc: Decodable {
    var isEnabled: Bool
    var isEligible: Bool
}
