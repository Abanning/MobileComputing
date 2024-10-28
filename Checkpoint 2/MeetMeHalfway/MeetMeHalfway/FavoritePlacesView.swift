//
//  FavoritePlacesView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/27/24.
//

import SwiftUI

struct FavoritePlacesView: View {
    var savedTrip: SavedTrip
    @State private var selectedTrip: FavoriteResults?
    
    // Custom struct for coordinates
    struct EncodableCoordinate: Hashable, Identifiable, Equatable, Encodable, Decodable {
        let id: UUID
        var latitude: Double
        var longitude: Double
    }
        
        
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

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Location 1: \(savedTrip.location1)")
                .font(.title)
            Text("Location 2: \(savedTrip.location2)")
                .font(.title)
            Text("Meeting Point: \(savedTrip.meetingPoint)")
                .font(.title)
            Text("File URL: \(savedTrip.URL)")
                .font(.subheadline)
            List {
                if let favoritePlaces = selectedTrip?.favoritePlaces {
                    ForEach(favoritePlaces, id: \.self) { place in
                        Text(place) // Display each favorite place
                    }
                }
            }
        }
        .onAppear {
            if savedTrip.URL != "" {
                loadFullTripData(for: savedTrip.URL)
            }
        }
        .padding()
        .navigationTitle("Trip Details")
    }
    
    private func loadFullTripData(for fileName: String) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Create the file URL from the file name
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let fullTrip = try decoder.decode(FavoriteResults.self, from: data)
            selectedTrip = fullTrip
        } catch {
            print("Error loading full trip data: \(error)")
        }
    }
}

#Preview {
    
}
