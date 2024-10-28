//
//  LoadFavoritesView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/27/24.
//

import SwiftUI
import CoreLocation

struct LoadFavoritesView: View {
    @State private var favoriteResults: FavoriteResults?
    
    
        
        
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
        NavigationStack {
            VStack {
                if let favoriteResults = favoriteResults {
                    List {
                        Section(header: Text("Trip Details")) {
                            Text("From: \(favoriteResults.location1Name)")
                            Text("To: \(favoriteResults.location2Name)")
                            Text("Meeting Point: \(favoriteResults.meetingPointName)")
                            Text("Meeting Point Coordinate: \(favoriteResults.meetingPointCoordinate.latitude), \(favoriteResults.meetingPointCoordinate.longitude)")
                        }

                        Section(header: Text("Favorite Places")) {
                            ForEach(favoriteResults.favoritePlaces, id: \.self) { place in
                                Text(place)
                            }
                        }
                    }
                } else {
                    Text("No favorite results found.")
                }
            }
            .navigationTitle("Saved Trips")
            .onAppear {
                loadFavoriteResults()
            }
        }
    }

    private func loadFavoriteResults() {
        // Construct the file path
        let fileName = "Seattle, WA->Los Angeles, CA@Seattle, WA.json"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let fileURL = documentsDirectory?.appendingPathComponent(fileName)

        // Read the data from the file
        guard let url = fileURL else { return }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            // Decode the JSON into FavoriteResults
            favoriteResults = try decoder.decode(FavoriteResults.self, from: data)
        } catch {
            print("Failed to load favorite results: \(error)")
        }
    }
}

#Preview {
    LoadFavoritesView()
}
