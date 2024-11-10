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
    @Environment(\.scenePhase) var scenePhase
    
    @State private var textLocation1: String = ""
    @State private var textLocation2: String = ""
    @State private var coordinate1: CLLocationCoordinate2D?
    @State private var coordinate2: CLLocationCoordinate2D?
    @State private var isArmed: Bool = false
    
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    // Map
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
                    .ignoresSafeArea()
                    .frame(height: 500)
                    // Map
                    
                    
                    // Location 1 Bar
                    HStack {
                        Text("Location 1:")
                            .padding(.leading)
                            .foregroundStyle(Color.white)
                        
                        NavigationLink(destination: LocationInputView(selectedLocation: $textLocation1, selectedLocationCoordinate: $coordinate1)) {
                            ZStack {
                                Color.gray.opacity(0.50)
                                    .cornerRadius(60)
                                    .frame(width: 240, height: 40)
                                    .padding(.horizontal)
                                
                                HStack {
                                    if textLocation1 != "" {
                                        Text(textLocation1)
                                            .foregroundStyle(Color.white)
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
                            .padding(.leading)
                            .foregroundStyle(Color.white)
                        
                        NavigationLink(destination: LocationInputView(selectedLocation: $textLocation2, selectedLocationCoordinate: $coordinate2)) {
                            ZStack {
                                Color.gray.opacity(0.50)
                                    .cornerRadius(60)
                                    .frame(width: 240, height: 40)
                                    .padding(.horizontal)
                                
                                HStack {
                                    if textLocation2 != "" {
                                        Text(textLocation2)
                                            .foregroundStyle(Color.white)
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
                    .padding(.bottom)
                    // Location 2 Bar
                    
                    
                    // Meet Me Halfway Button
                    if coordinate1 != nil && coordinate2 != nil {
                        NavigationLink(destination: MeetingPointsView(textLocation1: self.textLocation1, textLocation2: self.textLocation2, coordinate1: self.coordinate1!, coordinate2: self.coordinate2!)) {
                            ZStack {
                                Color.gray.opacity(0.50)
                                    .cornerRadius(60)
                                    .frame(width: 300, height: 75)
                                Text("Meet Me Halfway!")
                                    .foregroundStyle(Color.white)
                                    .font(.title)
                                    .padding()
                            }
                            .padding(.bottom)
                        }
                        .buttonStyle(PlainButtonStyle())
                    } else {
                        ZStack {
                            Color.gray.opacity(0.50)
                                .cornerRadius(60)
                                .frame(width: 300, height: 75)
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
            }
            .navigationBarHidden(true)
        } // End of navigation stack
        .onChange(of: scenePhase) { phase in
            if phase == .active {
                print("Scene is active")
            }
            else if phase == .inactive {
                print("Scene is inactive")
            }
            else if phase == .background {
                print("Scene is in background")
                //Insert Code here for saving important data in case the app gets killed by the OS
            }
        }
    } // End of body
}

#Preview {
    NewTripView()
}
