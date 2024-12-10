//
//  SavedTripsView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/27/24.
//

//
//  SavedTripsView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/27/24.
//

import SwiftUI

struct SavedTripsView: View {
    @State private var savedTrips: [SavedTrip] = []
    @State private var selectedTrip: SavedTrip?
    @State private var showFavorites = false
    
    var body: some View {
        NavigationStack {
            List {
                Section(header: Text("Alphabetically sorted by location names").font(.footnote).foregroundColor(.gray)) {
                    ForEach(savedTrips, id: \.id) { trip in
                        NavigationLink(destination: FavoritePlacesView(savedTrip: trip)) {
                            VStack(alignment: .leading) {
                                Text("From: \(trip.location1!)")
                                    .font(.subheadline)
                                Text("To: \(trip.location2!)")
                                    .font(.subheadline)
                                Text("Meeting Point: \(trip.meetingPoint!)")
                                    .font(.subheadline)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Saved Trips")
            .onAppear(perform: loadSavedTrips)
        }
        .colorScheme(.dark)
    }
    
    private func loadSavedTrips() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        do {
            let fileURLs = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            var trips: [SavedTrip] = []
            
            for fileURL in fileURLs {
                if fileURL.pathExtension == "json" {
                    // Decode the file name and replace URL-encoded characters
                    var fileName = fileURL.lastPathComponent
                    fileName = fileName.replacingOccurrences(of: "%20", with: " ")

                    // Split the filename to get location and meeting point names
                    let components = fileName.components(separatedBy: "->")
                    if components.count == 2, let meetingPointPart = components.last?.split(separator: "@").last {
                        let location1 = components[0].trimmingCharacters(in: .whitespaces)
                        let location2 = components[1].trimmingCharacters(in: .whitespaces).split(separator: "@")[0].trimmingCharacters(in: .whitespaces)
                        let meetingPoint = meetingPointPart.trimmingCharacters(in: .whitespaces).replacingOccurrences(of: ".json", with: "")

                        let trip = SavedTrip(URL: fileURL.lastPathComponent, location1: location1, location2: location2, meetingPoint: meetingPoint)
                        print(trip)
                        print("")
                        trips.append(trip)
                    }
                }
            }
            savedTrips = trips.sorted {
                ($0.location1 ?? "", $0.location2 ?? "", $0.meetingPoint ?? "") <
                ($1.location1 ?? "", $1.location2 ?? "", $1.meetingPoint ?? "")
            }
            
        } catch {
            print("Error loading saved trips: \(error)")
        }
    }
    
    
}

#Preview {
    SavedTripsView()
}
