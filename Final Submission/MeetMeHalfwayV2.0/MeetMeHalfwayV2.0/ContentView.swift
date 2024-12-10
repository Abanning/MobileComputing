//
//  ContentView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/24/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @State private var isPresented: Bool = false
    
    var body: some View {
        TabView {
            NewTripView()
                .tabItem {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("New Trip")
                    }
                }
            SavedTripsView()
                .tabItem {
                    Image(systemName: "folder")
                    Text("Saved Trips")
                }
        }
        .colorScheme(.dark)
    }
}
    
#Preview {
    ContentView()
}
