//
//  NewTripView.swift
//  MeetMeHalfwayV1.1
//
//  Created by Alex Banning on 11/7/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct NewTripView: View {
    var location1: String?
    var location2: String?
    
    @State private var textLocation1: String = ""
    @State private var textLocation2: String = ""
    @State private var coordinate1: CLLocationCoordinate2D?
    @State private var coordinate2: CLLocationCoordinate2D?
    @State private var isArmed: Bool? = false
    @State private var reloadMap: Bool? = false
    
    @State private var navigationPath = NavigationPath()
    @State private var tripInProgress: FavoriteResults?
    @State private var isShowingAlert: Bool = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Map {
                        if let coordinate1 {
                            Marker(coordinate: coordinate1) {
                                Text(textLocation1)
                            }
                            
                        }
                        
                        if let coordinate2 {
                            Marker(coordinate: coordinate2) {
                                Text(textLocation2)
                            }
                        }
                    }
                    .colorScheme(.dark)
                    .frame(height: 400)
                    // Map
                    
                    
                    // Location 1 Bar
                    HStack {
                        Text("Location 1:")
                            .frame(width: 100, height: 40, alignment: .leading)
                            .padding(.leading, 40)
                            .foregroundStyle(Color.white)
                        
                        NavigationLink(destination: LocationInputView(selectedLocation: $textLocation1, selectedLocationCoordinate: $coordinate1)) {
                            ZStack {
                                Color.gray.opacity(0.50)
                                    .cornerRadius(60)
                                    .frame(width: 240, height: 40, alignment: .trailing)
                                    .padding(.trailing)
                                
                                HStack {
                                    if textLocation1 != "" {
                                        Text(textLocation1)
                                            .foregroundStyle(Color.white)
                                            .font(.footnote)
                                    } else {
                                        Text("Enter a location")
                                            .foregroundStyle(Color.white)
                                    }
                                    Image(systemName: "location.fill")
                                        .foregroundStyle(Color.white)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    .padding(.top)
                    // Location 1 Bar
                    
                    
                    // Location 2 Bar
                    HStack {
                        Text("Location 2: ")
                            .frame(width: 100, height: 40, alignment: .leading)
                            .padding(.leading, 40)
                            .foregroundStyle(Color.white)
                        
                        NavigationLink(destination: LocationInputView(selectedLocation: $textLocation2, selectedLocationCoordinate: $coordinate2)) {
                            ZStack {
                                Color.gray.opacity(0.50)
                                    .cornerRadius(60)
                                    .frame(width: 240, height: 40, alignment: .trailing)
                                    .padding(.trailing)
                                
                                HStack {
                                    if textLocation2 != "" {
                                        Text(textLocation2)
                                            .foregroundStyle(Color.white)
                                            .font(.footnote)
                                    } else {
                                        Text("Enter a location")
                                            .foregroundStyle(Color.white)
                                    }
                                    Image(systemName: "location.fill")
                                        .foregroundStyle(Color.white)
                                }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                    // Location 2 Bar
                    
                    // Clear Button
                    HStack {
                        Spacer()
                        
                        ZStack {
                            Color.gray.opacity(0.50)
                                .cornerRadius(60)
                                .frame(width: 240, height: 40, alignment: .trailing)
                                .padding(.trailing, 15)
                            
                            Button("Clear All")
                            {
                                textLocation1 = ""
                                coordinate1 = nil
                                textLocation2 = ""
                                coordinate2 = nil
                            }
                            .foregroundStyle(Color.red)
                        }
                        .padding(.bottom)
                    }
                    
                    Spacer()
                    
                    
                    // Meet Me Halfway Button
                    if coordinate1 != nil && coordinate2 != nil {
                        NavigationLink(destination: MeetingPointsView(textLocation1: self.textLocation1, textLocation2: self.textLocation2, coordinate1: self.coordinate1!, coordinate2: self.coordinate2!)) {
                            ZStack {
                                Color.gray.opacity(0.50)
                                    .frame(width: 360, height: 100, alignment: .center)
                                    .cornerRadius(60)
                                    
        
                                Text("Meet Me Halfway!")
                                    .foregroundStyle(Color.white)
                                    .font(.title)
                                    .padding()
                            }
                            .padding(.bottom)
                        }
                        
                    } else {
                        ZStack {
                            Color.gray.opacity(0.5)
                                .frame(width: 360, height: 100, alignment: .center)
                                .cornerRadius(60)
                            Text("Meet Me Halfway!")
                                .foregroundStyle(Color.white)
                                .font(.title)
                                .padding()
                        }
                        .padding(.bottom)
                    }
                    // Meet Me Halfway Button
                    
                    Spacer()
                    Spacer()
                    
                } // End of content
                .colorScheme(.dark)
                /*.onAppear() {
                    let loadedNavigationPath = loadNavigationPath()
                    let navigationPathString = String(describing: loadedNavigationPath)
                    
                    if (navigationPathString != String(describing: self.navigationPath)) {
                        self.tripInProgress = loadTripInProgress()
                        self.isShowingAlert = true
                    }
                    
                }
                .alert(isPresented: $isShowingAlert) {
                    Alert(
                        title: Text("Got Interrupted?"),
                        message: Text("MeetMeHalfway has detected that you were interrupted in the middle of a search. Would you like to continue or begin a new search?"),
                        primaryButton: .default(Text("New Search"), action: {
                            NavigationLink("NewTripView", destination: NewTripView())
                        }),
                        secondaryButton: .cancel(Text("Continue Search"), action: {
                            NavigationLink("NearbyResultsView", destination: NearbyResultsView(textLocation1: tripInProgress?.location1Name, textLocation2: tripInProgress?.location2Name, meetingpointCoordinate: tripInProgress?.meetingPointCoordinate, locationName: tripInProgress?.meetingPointName))
                        })
                    )
                }*/
            }
            .navigationBarHidden(true)
        } // End of navigation stack
        .onAppear() {
            toggleReloadMap()
            if (self.location1 != nil) {
                self.textLocation1 = self.location1!
                
            }
            if (self.location2 != nil) {
                self.textLocation2 = self.location2!
            }
        }
    } // End of body
    
    private func loadTripInProgress() -> FavoriteResults? {
        let cachesURL = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask).first!
        
        // Create the file URL from the file name
        let fileURL = cachesURL.appendingPathComponent("CachedTrip.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let decoder = JSONDecoder()
            let fullTrip = try decoder.decode(FavoriteResults.self, from: data)
            return fullTrip
        } catch {
            print("Error loading full trip data: \(error)")
            return nil
        }
    }
    
    private func loadNavigationPath() -> String {
        if let navigationPath = UserDefaults.standard.string(forKey: "savedNavigationPath") {
            
            return navigationPath
        }
        
        return ""
    }
    
    private func toggleReloadMap() {
        self.reloadMap!.toggle()
    }
}

#Preview {
    NewTripView()
}
