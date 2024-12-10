//
//  FavoritePlacesView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/27/24.
//

import SwiftUI
import Foundation

struct FavoritePlacesView: View {
    var savedTrip: SavedTrip
    
    @Environment(\.dismiss) var dismiss
    @State private var isShowingAlert: Bool = false
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
            Text("Start: \(savedTrip.location1!)")
                .font(.title)
            Text("End: \(savedTrip.location2!)")
                .font(.title)
            Text("Meeting Point: \(savedTrip.meetingPoint!)")
                .font(.title)
            List {
                Section("Favorite Nearby Places in \(savedTrip.meetingPoint!)") {
                    if let favoritePlaces = selectedTrip?.favoritePlaces {
                        ForEach(favoritePlaces, id: \.self) { place in
                            Text(place) // Display each favorite place
                        }
                    }
                }
            }
            HStack {
                Spacer()
                
                // Share button
                ZStack {
                    Color.blue
                        .cornerRadius(60)
                        .frame(width: 100, height: 40, alignment: .leading)
                    Text("Share")
                        .font(.subheadline)
                }
                .padding(.top)
                .padding(.horizontal, 20)
                .onTapGesture {
                    // Add share feature in future
                }
                
                // Delete button
                ZStack {
                    Color.red
                        .cornerRadius(60)
                        .frame(width: 100, height: 40, alignment: .trailing)
                    Text("Delete")
                        .font(.subheadline)
                }
                .padding(.top)
                .padding(.horizontal, 20)
                .onTapGesture {
                    self.isShowingAlert = true
                }
                
                Spacer()
            }
            .padding(.bottom)
        }
        .onAppear {
            if savedTrip.URL != "" {
                loadFullTripData(for: savedTrip.URL!)
            }
        }
        .alert(isPresented: $isShowingAlert) {
            Alert(title: Text("Are you sure?"),
                  message: Text("This cannot be undone."),
                  primaryButton: .default(Text("Cancel")) {
                isShowingAlert = false
            },
                  secondaryButton: .destructive(Text("Delete")) {
                deleteTrip(tripURL: savedTrip.URL!)
                dismiss()
            })
        }
        .padding()
        .navigationTitle("Trip Details")
    }
    
    private func deleteTrip(tripURL: String) {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = documentsURL.appendingPathComponent(tripURL)
        
        do {
            try fileManager.removeItem(at: fileURL)
            print("Trip deleted successfully.")
            selectedTrip = nil
        } catch {
            print("Error deleting trip: \(error)")
        }
    }
    
    private func loadFullTripData(for fileName: String) {
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        
        // Create the file URL from the file name
        let fileURL = documentURL.appendingPathComponent(fileName)
        
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
