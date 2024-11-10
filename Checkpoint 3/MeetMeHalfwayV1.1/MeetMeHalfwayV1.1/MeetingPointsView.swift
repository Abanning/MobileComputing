//
//  MeetingPointsView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/24/24.
//

import SwiftUI
import MapKit
import CoreLocation

struct City: Identifiable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let population: Int
}

struct MeetingPointsView: View {
    var textLocation1: String
    var textLocation2: String
    var coordinate1: CLLocationCoordinate2D
    var coordinate2: CLLocationCoordinate2D
    @State private var midpointCoordinate: CLLocationCoordinate2D?
    @State private var midpointLocality: String?
    @State private var routePolyline: MKPolyline?
    @State private var citiesAlongRoute: [City] = []
    
    @State private var navigationPath = NavigationPath()
    
    let geocoder = CLGeocoder()
    
    // Major city data
    let majorCities: [City] = [
        // Between LA and Seattle
        City(name: "Los Angeles", coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), population: 3990456),
        City(name: "San Diego", coordinate: CLLocationCoordinate2D(latitude: 32.7157, longitude: -117.1611), population: 1425976),
        City(name: "San Jose", coordinate: CLLocationCoordinate2D(latitude: 37.3382, longitude: -121.8863), population: 1035317),
        City(name: "San Francisco", coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), population: 884363),
        City(name: "Oakland", coordinate: CLLocationCoordinate2D(latitude: 37.8044, longitude: -122.2711), population: 429082),
        City(name: "Sacramento", coordinate: CLLocationCoordinate2D(latitude: 38.5816, longitude: -121.4944), population: 508529),
        City(name: "Portland", coordinate: CLLocationCoordinate2D(latitude: 45.5051, longitude: -122.6750), population: 647805),
        City(name: "Seattle", coordinate: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321), population: 744955),
        
        // Between Seattle and Boston
        City(name: "Boston", coordinate: CLLocationCoordinate2D(latitude: 42.3601, longitude: -71.0589), population: 692600),
        City(name: "Providence", coordinate: CLLocationCoordinate2D(latitude: 41.8240, longitude: -71.4128), population: 179335),
        City(name: "Hartford", coordinate: CLLocationCoordinate2D(latitude: 41.7658, longitude: -72.6734), population: 121054),
        City(name: "Albany", coordinate: CLLocationCoordinate2D(latitude: 42.6526, longitude: -73.7562), population: 97478),
        City(name: "Syracuse", coordinate: CLLocationCoordinate2D(latitude: 43.0481, longitude: -76.1474), population: 148620),
        City(name: "Rochester", coordinate: CLLocationCoordinate2D(latitude: 43.1566, longitude: -77.6088), population: 211328),
        City(name: "Buffalo", coordinate: CLLocationCoordinate2D(latitude: 42.8864, longitude: -78.8784), population: 255284),
        City(name: "Cleveland", coordinate: CLLocationCoordinate2D(latitude: 41.4995, longitude: -81.6954), population: 372624),
        City(name: "Detroit", coordinate: CLLocationCoordinate2D(latitude: 42.3314, longitude: -83.0458), population: 670031),
        City(name: "Chicago", coordinate: CLLocationCoordinate2D(latitude: 41.8781, longitude: -87.6298), population: 2716000),
        City(name: "Milwaukee", coordinate: CLLocationCoordinate2D(latitude: 43.0389, longitude: -87.9065), population: 592025),
        City(name: "Minneapolis", coordinate: CLLocationCoordinate2D(latitude: 44.9778, longitude: -93.2650), population: 429606),
        City(name: "Madison", coordinate: CLLocationCoordinate2D(latitude: 43.0731, longitude: -89.4012), population: 258054),
        City(name: "Fargo", coordinate: CLLocationCoordinate2D(latitude: 46.8772, longitude: -96.7898), population: 124662),
        City(name: "Billings", coordinate: CLLocationCoordinate2D(latitude: 45.7833, longitude: -108.5007), population: 109550),
        City(name: "Missoula", coordinate: CLLocationCoordinate2D(latitude: 46.8721, longitude: -113.9940), population: 75106),
        City(name: "Spokane", coordinate: CLLocationCoordinate2D(latitude: 47.6588, longitude: -117.4260), population: 219190),
    ]
    
    var combinedCities: [City] {
        var allCities = citiesAlongRoute
        if let midpointCoordinate = midpointCoordinate, let midpointLocality = midpointLocality {
            let midpointCity = City(name: midpointLocality, coordinate: midpointCoordinate, population: 0)
            allCities.insert(midpointCity, at: 0)
        }
        return allCities
    }
    
    func calculateMidpointAndRoute() {
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: coordinate1))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate2))
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        directions.calculate { response, error in
            guard let route = response?.routes.first, error == nil else { return }
            self.routePolyline = route.polyline
            self.midpointCoordinate = route.polyline.points()[route.polyline.pointCount / 2].coordinate
            findCitiesAlongRoute()
        }
    }
    
    func reverseGeocodeMidpoint(_ coordinate: CLLocationCoordinate2D) {
        geocoder.reverseGeocodeLocation(CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)) { placemarks, error in
            if let locality = placemarks?.first?.locality {
                self.midpointLocality = locality
            } else {
                self.midpointLocality = "Unknown"
            }
        }
    }
    
    func findCitiesAlongRoute() {
        guard let polyline = routePolyline else { return }
        let maxDistance: CLLocationDistance = 100000
        var nearbyCities: [City] = []
        
        for city in majorCities {
            for i in 0..<polyline.pointCount {
                let point = polyline.points()[i]
                let cityMapPoint = MKMapPoint(city.coordinate)
                
                if cityMapPoint.distance(to: point) <= maxDistance {
                    nearbyCities.append(city)
                    break
                }
            }
        }
        
        if let midpointCoordinate = self.midpointCoordinate {
            reverseGeocodeMidpoint(midpointCoordinate)
        }
        
        self.citiesAlongRoute = nearbyCities.sorted { $0.population > $1.population }
    }

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                Map {
                    Marker(coordinate: coordinate1) {
                        Text(textLocation1)
                    }
                    Marker(coordinate: coordinate2) {
                        Text(textLocation2)
                    }
                    if let midpointCoordinate = midpointCoordinate {
                        Marker(coordinate: midpointCoordinate) {
                            Text(midpointLocality ?? "Midpoint")
                        }
                    }
                }
                .frame(height: 400)
                
                List(combinedCities) { city in
                    NavigationLink(destination: NearbyResultsView(textLocation1: textLocation1, textLocation2: textLocation2, meetingpointCoordinate: city.coordinate, locationName: city.name)) {
                        Text("\(city.name)")
                    }
                }
                .padding()
            }
            .onAppear {
                print("Loading meeting points using Location1=\(textLocation1) and Location2=\(textLocation2)")
                calculateMidpointAndRoute()
            }
            .navigationTitle("Meeting Points")
            .navigationDestination(for: HashableCoordinate.self) { hashableCoordinate in
                NearbyResultsView(textLocation1: textLocation1, textLocation2: textLocation2, meetingpointCoordinate: hashableCoordinate.coordinate, locationName: midpointLocality ?? "Meeting Point")
            }
        }
    }
}

#Preview {
    MeetingPointsView(
        textLocation1: "Seattle, WA",
        textLocation2: "Los Angeles, CA",
        coordinate1: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
        coordinate2: CLLocationCoordinate2D(latitude: 34.053345, longitude: -118.242349)
    )
}
