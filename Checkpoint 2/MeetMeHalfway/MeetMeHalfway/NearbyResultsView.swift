//
//  NearbyResultsView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/26/24.
//

import SwiftUI
import MapKit
import CoreLocation

class NearbyResultsViewModel: ObservableObject {
    @Published var hotels: [MKMapItem] = []
    @Published var foodAndDrink: [MKMapItem] = []
    @Published var activitiesAndTourism: [MKMapItem] = []
    
    var meetingpointCoordinate: CLLocationCoordinate2D
    
    init(meetingpointCoordinate: CLLocationCoordinate2D) {
        self.meetingpointCoordinate = meetingpointCoordinate
        fetchNearbyResults()
    }
    
    private func performSearch(query: String, completion: @escaping ([MKMapItem]) -> Void) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = MKCoordinateRegion(
            center: meetingpointCoordinate,
            latitudinalMeters: 5000,
            longitudinalMeters: 5000
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    completion(response.mapItems)
                }
            } else {
                print("Error fetching \(query) results: \(String(describing: error))")
                completion([])
            }
        }
    }
    
    func fetchNearbyResults() {
        performSearch(query: "hotel") { items in
            self.hotels = items
        }
        performSearch(query: "restaurant") { items in
            self.foodAndDrink = items
        }
        performSearch(query: "activities") { items in
            self.activitiesAndTourism = items
        }
    }
}

struct NearbyResultsView: View {
    var textLocation1: String
    var textLocation2: String
    var locationName: String
    var meetingpointCoordinate: CLLocationCoordinate2D
    @StateObject private var viewModel: NearbyResultsViewModel
    
    @State private var visibleHotelCount = 10
    @State private var visibleFoodAndDrinkCount = 10
    @State private var visibleActivitiesCount = 10
    
    @State private var selectedItem: MKMapItem?
    @State private var favoriteResults: FavoriteResults?
    
    // Custom struct for coordinates
    struct EncodableCoordinate: Hashable, Identifiable, Equatable, Encodable {
        let id = UUID()
        var latitude: Double
        var longitude: Double
    }
        
        
    struct FavoriteResults: Hashable, Identifiable, Equatable, Encodable {
        let id = UUID()
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

    
    init(textLocation1: String, textLocation2: String, meetingpointCoordinate: CLLocationCoordinate2D, locationName: String) {
        self.textLocation1 = textLocation1
        self.textLocation2 = textLocation2
        self.meetingpointCoordinate = meetingpointCoordinate
        self.locationName = locationName
        _viewModel = StateObject(wrappedValue: NearbyResultsViewModel(meetingpointCoordinate: meetingpointCoordinate))
        
        // Initialize FavoriteResults with static details
        _favoriteResults = State(initialValue: FavoriteResults(
            location1Name: textLocation1,
            location2Name: textLocation2,
            meetingPointName: locationName,
            meetingPointCoordinate: EncodableCoordinate(
                latitude: meetingpointCoordinate.latitude,
                longitude: meetingpointCoordinate.longitude
            )
        ))
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                VStack {
                    Map {
                        Marker(coordinate: meetingpointCoordinate) {
                            Text(locationName)
                        }
                        
                        if let selectedItem = selectedItem {
                            Marker(coordinate: selectedItem.placemark.coordinate) {
                                Text(selectedItem.name ?? "Unknown Place")
                            }
                            .tint(.blue)
                        }
                    }
                    .frame(height: 400)
                    
                    List {
                        Section(header: Text("Hotels")) {
                            ForEach(viewModel.hotels.prefix(visibleHotelCount), id: \.self) { item in
                                NearbyResultRow(item: item, isSelected: selectedItem == item, isFavorited: isFavorited(item)) {
                                    handleItemTap(item: item)
                                } favoriteAction: {
                                    toggleFavorite(for: item)
                                }
                            }
                            if viewModel.hotels.count > visibleHotelCount {
                                Button("Show More") {
                                    visibleHotelCount += 10
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        
                        Section(header: Text("Food and Drink")) {
                            ForEach(viewModel.foodAndDrink.prefix(visibleFoodAndDrinkCount), id: \.self) { item in
                                NearbyResultRow(item: item, isSelected: selectedItem == item, isFavorited: isFavorited(item)) {
                                    handleItemTap(item: item)
                                } favoriteAction: {
                                    toggleFavorite(for: item)
                                }
                            }
                            if viewModel.foodAndDrink.count > visibleFoodAndDrinkCount {
                                Button("Show More") {
                                    visibleFoodAndDrinkCount += 10
                                }
                                .foregroundColor(.blue)
                            }
                        }
                        
                        Section(header: Text("Activities and Tourism")) {
                            ForEach(viewModel.activitiesAndTourism.prefix(visibleActivitiesCount), id: \.self) { item in
                                NearbyResultRow(item: item, isSelected: selectedItem == item, isFavorited: isFavorited(item)) {
                                    handleItemTap(item: item)
                                } favoriteAction: {
                                    toggleFavorite(for: item)
                                }
                            }
                            if viewModel.activitiesAndTourism.count > visibleActivitiesCount {
                                Button("Show More") {
                                    visibleActivitiesCount += 10
                                }
                                .foregroundColor(.blue)
                            }
                        }
                    }
                    .listStyle(GroupedListStyle())
                }
                .onAppear {
                    //initializeFavoriteResults()
                    viewModel.fetchNearbyResults()
                }
            }
            .navigationDestination(for: MKMapItem.self) { item in
                ResultDetailsView(item: item)
            }
            .navigationTitle("Nearby")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Trip") {
                        let stringAppend = "\(textLocation1)->\(textLocation2)@ \(locationName)"
                        saveTripData(stringAppend: stringAppend)
                    }
                }
            }
        }
    }
    
    private func toggleFavorite(for item: MKMapItem) {
        guard var favoriteResults = favoriteResults else { return }
        
        if let itemName = item.name {
            if favoriteResults.favoritePlaces.contains(itemName) {
                // Unfavorite: remove from favoritePlaces
                favoriteResults.favoritePlaces.removeAll { $0 == itemName }
            } else {
                // Favorite: add to favoritePlaces
                favoriteResults.favoritePlaces.append(itemName)
            }
            self.favoriteResults = favoriteResults
        }
        
        print("Toggled favorite for: \(item.name ?? "")")
        print(favoriteResults)
    }
    
    private func isFavorited(_ item: MKMapItem) -> Bool {
        guard let favoriteResults = favoriteResults, let itemName = item.name else {
            return false
        }
        return favoriteResults.favoritePlaces.contains(itemName)
    }
    
    private func handleItemTap(item: MKMapItem) {
        if selectedItem == item {
            // If already selected, navigate to the details view
            selectedItem = item // This will trigger navigation
        } else {
            selectedItem = item
        }
    }
    
    private func saveTripData(stringAppend: String) {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("\(stringAppend).json")
            
            let data = try JSONEncoder().encode(favoriteResults)
            try data.write(to: fileURL)
            
            print("Trip data saved successfully at \(fileURL)")
        } catch {
            print("Failed to save trip data: \(error.localizedDescription)")
        }
    }
}

struct NearbyResultRow: View {
    var item: MKMapItem
    var isSelected: Bool
    var isFavorited: Bool
    var action: () -> Void
    var favoriteAction: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(item.name ?? "Unknown Place")
                    .font(.headline)
                if let address = item.placemark.title {
                    Text(address)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            .background(isSelected ? Color.blue : Color.clear)
            .cornerRadius(8)
            .onTapGesture {
                action()
            }
            
            Spacer()
            
            Button(action: favoriteAction) {
                Image(systemName: isFavorited ? "star.fill" : "star")
                    .foregroundColor(isFavorited ? .yellow : .gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}

#Preview {
    NearbyResultsView(textLocation1: "Seattle, WA", textLocation2: "Los Angeles, CA", meetingpointCoordinate: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321), locationName: "Seattle, WA")
}
