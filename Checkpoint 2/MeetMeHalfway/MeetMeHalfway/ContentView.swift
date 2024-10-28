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
    var body: some View {
        TabView {
            MainPageView()
                .tabItem {
                    Text("New Trip")
            }
            SavedTripsView()
                .tabItem {
                    Text("Saved Trips")
            }
        }
    }
}


#Preview {
    ContentView()
}
