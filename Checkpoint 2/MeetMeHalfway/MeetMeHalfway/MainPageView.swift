//
//  MainPageView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/25/24.
//

//
//  MainPageView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/24/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct MainPageView: View {
    private var textLocation1: String = "Seattle, WA"
    private let coordinate1: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321)
    @State private var textLocation2: String = ""
    @State private var showingAlert: Bool = false
    @State private var coordinate2: CLLocationCoordinate2D?
    @State private var isNotArmed: Bool = false
    @State private var navigationData: LocationData = LocationData(
        textLocation1: "",
        textLocation2: "",
        coordinate1: CLLocationCoordinate2D(),
        coordinate2: CLLocationCoordinate2D()
    )
    
    let geocoder = CLGeocoder()
    
    func geocodeLocation(locationName: String, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        geocoder.geocodeAddressString(locationName) { placemarks, error in
            guard error == nil, let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("Error geocoding location: \(error?.localizedDescription ?? "Unknown error")")
                completion(nil)
                return
            }
            completion(location.coordinate)
        }
    }

    func updateCoordinate2() {
        // Geocode Location 2
        geocodeLocation(locationName: textLocation2) { coordinate in
            if let coord = coordinate {
                self.coordinate2 = coord
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Blank background
                Color.black
                    .ignoresSafeArea()
                
                // Main Content
                VStack {
                    // Map Section
                    Map {
                        Marker(coordinate: coordinate1) {
                            Text(textLocation1)
                        }
                        
                        if let coordinate2 {
                            Marker(coordinate: coordinate2) {
                                Text(textLocation2)
                            }
                        }
                    }
                    .frame(height: 500)
                    .padding(.bottom, 20)
                    
                    // Meet Me Halfway Navigation Link
                    NavigationLink(destination: MeetingPointsView(
                        textLocation1: textLocation1,
                        textLocation2: textLocation2,
                        coordinate1: coordinate1,
                        coordinate2: coordinate2 ?? CLLocationCoordinate2D()
                    )) {
                        ZStack {
                            Color.gray
                                .cornerRadius(150)
                                .frame(height: 80)
                                .padding(.horizontal, 40)
                            Text("MeetMeHalfway")
                                .font(.largeTitle)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity, maxHeight: 80) // Set frame for consistency
                                .background(Color.gray)
                                .cornerRadius(150)
                                .padding(.horizontal, 40)
                        }
                    }
                    .disabled(coordinate2 == nil) // Disable if coordinate2 is nil
                    .simultaneousGesture(TapGesture().onEnded {
                        if coordinate2 == nil {
                            isNotArmed = true
                        }
                    })
                    .alert("Please select a second location first.", isPresented: $isNotArmed) {
                        Button("OK") {
                            isNotArmed = false
                        }
                    }
                    
                    // Location 1 Bar
                    HStack {
                        Spacer()
                        Text("Location 1: ")
                            .padding(.leading)
                            .foregroundColor(.white)
                            .font(.title)
                        ZStack {
                            Color.gray
                                .cornerRadius(50)
                                .frame(width: 200, height: 40)
                                .padding(.trailing)
                            HStack {
                                Text("Seattle, WA")
                                    .foregroundColor(.white)
                                    .padding(.leading, 40)
                                Image(systemName: "location.fill")
                                Spacer()
                            }
                        }
                    }
                    
                    // Location 2 Bar
                    HStack {
                        Spacer()
                        Text("Location 2: ")
                            .padding(.leading)
                            .foregroundColor(.white)
                            .font(.title)
                        ZStack {
                            Rectangle()
                                .cornerRadius(50)
                                .contentShape(Rectangle())
                                .frame(width: 200, height: 40)
                                .padding(.trailing)
                                .foregroundColor(.gray)
                                .onTapGesture {
                                    showingAlert = true
                                }
                            HStack {
                                if textLocation2.isEmpty {
                                    Text("Select a location")
                                        .foregroundColor(.white)
                                        .padding(.leading, 40)
                                } else {
                                    Text(textLocation2)
                                        .foregroundColor(.white)
                                        .padding(.leading, 40)
                                }
                                Image(systemName: "location.fill")
                                Spacer()
                            }
                        }
                    }
                    .alert("Select a location", isPresented: $showingAlert) {
                        Button("Boston, MA") {
                            textLocation2 = "Boston, MA"
                            updateCoordinate2()
                        }
                        Button("Woodinville, WA") {
                            textLocation2 = "Woodinville, WA"
                            updateCoordinate2()
                        }
                        Button("Los Angeles, CA") {
                            textLocation2 = "Los Angeles, CA"
                            updateCoordinate2()
                        }
                        Button("Cancel", role: .cancel) {
                            textLocation2 = ""
                            coordinate2 = nil
                        }
                    }
                    
                    // Space for home slider
                    Spacer()
                }
            } // ZStack end
            .navigationBarHidden(true)
        } // Navigation Stack end
    } // var body end
} // ContentView end

#Preview {
    MainPageView()
}
