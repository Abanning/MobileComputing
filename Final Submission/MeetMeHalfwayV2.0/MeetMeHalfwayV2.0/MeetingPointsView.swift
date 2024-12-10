import SwiftUI
import MapKit
import CoreLocation

class MeetingPointsViewModel: ObservableObject {
    @Published var midpointCoordinate: CLLocationCoordinate2D?
    @Published var midpointLocality: String?
    @Published var midpointRegion: String?
    @Published var midpointFullName: String?
    @Published var routePolyline: MKPolyline?
    @Published var citiesAlongRoute: [City] = []
    
    @Published var hasNoRoute: Bool = false

    private let geocoder = CLGeocoder()

    func calculateMidpointAndRoute(from coordinate1: CLLocationCoordinate2D, to coordinate2: CLLocationCoordinate2D) {
        // Request Directions
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: coordinate1))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: coordinate2))
        request.transportType = .automobile

        let directions = MKDirections(request: request)

        // Timer for timeout
        var timeoutTask: DispatchWorkItem?

        // Start timeout countdown
        timeoutTask = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.hasNoRoute = true // Update hasNoRoute
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 10, execute: timeoutTask!)

        // Directions calculation
        directions.calculate { [weak self] response, error in
            // Cancel timeout task if directions are received
            timeoutTask?.cancel()

            guard let self = self else { return }
            if let route = response?.routes.first, error == nil {
                // Directions found, proceed as normal
                DispatchQueue.main.async {
                    // Set the route polyline
                    self.routePolyline = route.polyline

                    // Calculate the midpoint and reverse-geocode it
                    let midpointIndex = route.polyline.pointCount / 2
                    let midpointCoordinate = route.polyline.points()[midpointIndex].coordinate
                    self.midpointCoordinate = midpointCoordinate

                    self.reverseGeocodeCoordinate(coordinate: midpointCoordinate) { locality, country, region in
                        DispatchQueue.main.async {
                            self.midpointLocality = locality
                            self.midpointRegion = region
                            if region != nil {
                                self.midpointFullName = "\(locality!), \(region!)"
                            }
                        }

                        // Start sampling the polyline for other cities after midpoint geocoding
                        self.splitRouteAndFindCities(route: route)
                    }
                }
            } else {
                // No directions found, set hasNoRoute to true
                DispatchQueue.main.async {
                    self.hasNoRoute = true // Update hasNoRoute
                }
            }
        }
    }

    func splitRouteAndFindCities(route: MKRoute) {
        let middleStartIndex = route.polyline.pointCount / 6 // Start at 1/6th
        let middleEndIndex = middleStartIndex * 5 // End at 5/6
        let totalMiddlePoints = middleEndIndex - middleStartIndex // Middle 2/3rds of route

        let sampleCount = 14 // Number of points to sample
        let step = max(1, totalMiddlePoints / sampleCount) // Step size for sampling indices

        // Create an array of coordinates
        var coordinates: [CLLocationCoordinate2D] = []
        for i in stride(from: middleStartIndex, to: middleEndIndex, by: step) {
            let coordinate = route.polyline.points()[i].coordinate
            coordinates.append(coordinate)
        }

        // Sequentially reverse geocode coordinates
        processCoordinatesSequentially(coordinates: coordinates)
    }

    private func processCoordinatesSequentially(coordinates: [CLLocationCoordinate2D], index: Int = 0) {
        // Check if we've processed all coordinates
        guard index < coordinates.count else { return }

        let coordinate = coordinates[index]
        
        reverseGeocodeCoordinate(coordinate: coordinate) { locality, country, region in
            if let locality = locality {
                // Perform forward geocoding using the locality, country, and region
                self.forwardGeocodeLocality(locality: locality, country: country, region: region) { updatedCoordinate in
                    if let updatedCoordinate = updatedCoordinate {
                        // Create the city with the locality and updated coordinate
                        let fullName = locality + ", " + region!
                        let city = City(name: fullName, coordinate: updatedCoordinate)
                        
                        // Update the citiesAlongRoute array incrementally on the main queue
                        DispatchQueue.main.async {
                            if !self.citiesAlongRoute.contains(where: { $0.name == city.name }) {
                                self.citiesAlongRoute.append(city)
                            }
                        }
                    }
                }
            }

            // Process the next coordinate after this one completes
            self.processCoordinatesSequentially(coordinates: coordinates, index: index + 1)
        }
    }

    private func reverseGeocodeCoordinate(coordinate: CLLocationCoordinate2D, completion: @escaping (String?, String?, String?) -> Void) {
        let geocoder = CLGeocoder()
        
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let error = error {
                print("Reverse geocoding error: \(error.localizedDescription)")
                completion(nil, nil, nil)
            } else if let placemark = placemarks?.first {
                let locality = placemark.locality
                let country = placemark.country
                let region = placemark.administrativeArea // Region or state
                
                completion(locality, country, region)
            } else {
                print("No locality found for coordinate.")
                completion(nil, nil, nil)
            }
        }
    }
    
    private func forwardGeocodeLocality(locality: String, country: String? = nil, region: String? = nil, completion: @escaping (CLLocationCoordinate2D?) -> Void) {
        let geocoder = CLGeocoder()
        
        // Build the address string with locality and optional country/region
        var addressString = locality
        if let region = region {
            addressString += ", \(region)"
        }
        if let country = country {
            addressString += ", \(country)"
        }

        geocoder.geocodeAddressString(addressString) { placemarks, error in
            if let error = error {
                print("Forward geocoding error: \(error.localizedDescription)")
                completion(nil)
            } else if let placemark = placemarks?.first, let coordinate = placemark.location?.coordinate {
                completion(coordinate)
            } else {
                print("No location found for locality.")
                completion(nil)
            }
        }
    }

    func deduplicateCities(_ cities: [City]) -> [City] {
        var uniqueCities = [City]()
        var cityNames = Set<String>()

        for city in cities {
            if !cityNames.contains(city.name) {
                cityNames.insert(city.name)
                uniqueCities.append(city)
            }
        }
        return uniqueCities
    }
}

struct MapView: View {
    var midpoint: CLLocationCoordinate2D?
    var midpointLabel: String?
    var routePolyline: MKPolyline?
    var citiesAlongRoute: [City]
    var coordinate1: CLLocationCoordinate2D
    var textLocation1: String
    var coordinate2: CLLocationCoordinate2D
    var textLocation2: String
    
    var body: some View {
        Map {
            Marker(coordinate: coordinate1) {
                Text(textLocation1)
            }
            Marker(coordinate: coordinate2) {
                Text(textLocation2)
            }
            
            if let midpoint = midpoint {
                Marker(coordinate: midpoint) {
                    Text(String(midpointLabel ?? "Unkown"))
                }
            }
            
            ForEach(citiesAlongRoute) { city in
                Marker(coordinate: city.coordinate) {
                    Text(city.name)
                }
            }
            if let polyline = routePolyline {
                MapPolyline(polyline)
            }
        }
        .frame(height: 400)
    }
}

struct MeetingPointsView: View {
    var textLocation1: String
    var textLocation2: String
    var coordinate1: CLLocationCoordinate2D
    var coordinate2: CLLocationCoordinate2D
    
    @State private var returnToHome: Bool = false
    
    @StateObject private var viewModel = MeetingPointsViewModel()
    
    var body: some View {
        NavigationStack {
            ZStack {
                NavigationStack {
                    EmptyView()
                        .navigationDestination(isPresented: $returnToHome) {
                            NewTripView()
                        }
                }
                Color.black
                    .ignoresSafeArea()
                NavigationStack {
                    VStack {
                        MapView(
                            midpoint: viewModel.midpointCoordinate,
                            midpointLabel: viewModel.midpointLocality,
                            routePolyline: viewModel.routePolyline,
                            citiesAlongRoute: viewModel.citiesAlongRoute,
                            coordinate1: coordinate1,
                            textLocation1: textLocation1,
                            coordinate2: coordinate2,
                            textLocation2: textLocation2
                        )
                        .frame(height: 400)
                        
                        List {
                            // Display the midpoint locality
                            Section("True Midpoint") {
                                if let midpointFullName = viewModel.midpointFullName {
                                    NavigationLink(destination: NearbyResultsView(textLocation1: textLocation1, textLocation2: textLocation2, meetingpointCoordinate: viewModel.midpointCoordinate!, locationName: viewModel.midpointFullName!)) {
                                        Text("\(midpointFullName)")
                                    }
                                } else {
                                    Text("Loading...")
                                }
                            }
                            
                            Section("Results Along the Way") {
                                // Display other sampled cities along the route
                                if (viewModel.citiesAlongRoute != []) {
                                    ForEach(viewModel.citiesAlongRoute) { city in
                                        NavigationLink(destination: NearbyResultsView(textLocation1: textLocation1, textLocation2: textLocation2, meetingpointCoordinate: city.coordinate, locationName: city.name)) {
                                            Text("\(city.name)")
                                        }
                                    }
                                } else {
                                    Text("Loading...")
                                }
                            }
                            
                        }
                        .listStyle(.plain)
                    }
                    .onAppear {
                        viewModel.calculateMidpointAndRoute(from: coordinate1, to: coordinate2)
                    }
                    .navigationTitle("Meeting Points")
                }
            }
            .colorScheme(.dark)
            .alert(isPresented: $viewModel.hasNoRoute) { // Bind to @Published hasNoRoute
                Alert(
                    title: Text("No Route Available"),
                    message: Text("It appears the route between \(textLocation1) and \(textLocation2) is not available. It may require air travel or Apple Maps may be unable to find a viable route. MeetMeHalfway is only equipped to handle drivable routes at this time. We apologize for any inconvenience."),
                    dismissButton: .default(Text("OK")) {
                        self.returnToHome = true
                    }
                )
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
