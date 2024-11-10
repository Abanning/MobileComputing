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
    }
    
    init(textLocation1: String, textLocation2: String, meetingpointCoordinate: CLLocationCoordinate2D, locationName: String) {
        self.textLocation1 = textLocation1
        self.textLocation2 = textLocation2
        self.meetingpointCoordinate = meetingpointCoordinate
        self.locationName = locationName
        _viewModel = StateObject(wrappedValue: NearbyResultsViewModel(meetingpointCoordinate: meetingpointCoordinate))
        
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
                    MapView(meetingpointCoordinate: meetingpointCoordinate, selectedItem: selectedItem)
                        .frame(height: 400)
                    
                    List {
                        hotelsSection
                        foodAndDrinkSection
                        activitiesSection
                    }
                    .listStyle(GroupedListStyle())
                }
            }
            .navigationTitle("Nearby")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save Trip") {
                        saveTripData()
                    }
                }
            }
        }
    }
    
    private func saveTripData() {
        let stringAppend = "\(textLocation1)->\(textLocation2)@ \(locationName)"
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
    
    private func toggleFavorite(for item: MKMapItem) {
        guard var favoriteResults = favoriteResults else { return }
        
        if let itemName = item.name {
            if favoriteResults.favoritePlaces.contains(itemName) {
                favoriteResults.favoritePlaces.removeAll { $0 == itemName }
            } else {
                favoriteResults.favoritePlaces.append(itemName)
            }
            self.favoriteResults = favoriteResults
        }
    }
    
    private func isFavorited(_ item: MKMapItem) -> Bool {
        guard let favoriteResults = favoriteResults, let itemName = item.name else {
            return false
        }
        return favoriteResults.favoritePlaces.contains(itemName)
    }
    
    // MARK: - Sections
    
    private var hotelsSection: some View {
        Section(header: Text("Hotels")) {
            ForEach(viewModel.hotels.prefix(visibleHotelCount), id: \.self) { item in
                NearbyResultRow(
                    item: item,
                    isSelected: selectedItem == item,
                    isFavorited: isFavorited(item),
                    action: {
                        handleItemTap(item: item)
                    },
                    favoriteAction: {
                        toggleFavorite(for: item)
                    },
                    infoAction: {
                        // Action to show more details in Apple Maps (e.g., open a map view)
                        showInfoForItem(item)
                    }
                )
            }
            if viewModel.hotels.count > visibleHotelCount {
                Button("Show More") {
                    visibleHotelCount += 10
                }
                .foregroundColor(.blue)
            }
        }
    }

    private var foodAndDrinkSection: some View {
        Section(header: Text("Food and Drink")) {
            ForEach(viewModel.foodAndDrink.prefix(visibleFoodAndDrinkCount), id: \.self) { item in
                NearbyResultRow(
                    item: item,
                    isSelected: selectedItem == item,
                    isFavorited: isFavorited(item),
                    action: {
                        handleItemTap(item: item)
                    },
                    favoriteAction: {
                        toggleFavorite(for: item)
                    },
                    infoAction: {
                        showInfoForItem(item)
                    }
                )
            }
            if viewModel.foodAndDrink.count > visibleFoodAndDrinkCount {
                Button("Show More") {
                    visibleFoodAndDrinkCount += 10
                }
                .foregroundColor(.blue)
            }
        }
    }

    private var activitiesSection: some View {
        Section(header: Text("Activities and Tourism")) {
            ForEach(viewModel.activitiesAndTourism.prefix(visibleActivitiesCount), id: \.self) { item in
                NearbyResultRow(
                    item: item,
                    isSelected: selectedItem == item,
                    isFavorited: isFavorited(item),
                    action: {
                        handleItemTap(item: item)
                    },
                    favoriteAction: {
                        toggleFavorite(for: item)
                    },
                    infoAction: {
                        showInfoForItem(item)
                    }
                )
            }
            if viewModel.activitiesAndTourism.count > visibleActivitiesCount {
                Button("Show More") {
                    visibleActivitiesCount += 10
                }
                .foregroundColor(.blue)
            }
        }
    }

    private func showInfoForItem(_ item: MKMapItem) {
        // Ensure the location is valid
        guard let coordinate = item.placemark.location?.coordinate else {
            print("Invalid location data.")
            return
        }
        
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let name = item.name ?? "Unknown Place"
        
        // Add optional website and phone info if available
        let address = item.placemark.thoroughfare ?? ""
        let website = item.url?.absoluteString ?? ""
        let phone = item.phoneNumber ?? ""
        
        // Construct the URL for Apple Maps (with optional query for name)
        var appleMapsURL = "http://maps.apple.com/?ll=\(latitude),\(longitude)&q=\(name)"
        
        // Append website to URL if available
        if !website.isEmpty {
            appleMapsURL += "&url=\(website)"
        }
        
        // Construct a phone number URL for phone dialer (if phone number is available)
        if !phone.isEmpty {
            appleMapsURL += "&telprompt://\(phone)"
        }
        
        // Open the URL in Apple Maps
        if let url = URL(string: appleMapsURL), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            print("Apple Maps cannot open URL")
        }
        
        // Show info within your app
        print("Name: \(name)")
        print("Address: \(address)")
        print("Phone: \(phone)")
        print("Website: \(website)")
    }
    
    private func handleItemTap(item: MKMapItem) {
        if selectedItem == item {
            selectedItem = nil
        } else {
            selectedItem = item
        }
    }
}

// MARK: - MapView Subview
struct MapView: View {
    var meetingpointCoordinate: CLLocationCoordinate2D
    var selectedItem: MKMapItem?
    
    var body: some View {
        Map {
            Marker(coordinate: meetingpointCoordinate) {
                Text("Meeting Point")
            }
            
            if let selectedItem = selectedItem {
                Marker(coordinate: selectedItem.placemark.coordinate) {
                    Text(selectedItem.name ?? "Unknown Place")
                }
                .tint(.blue)
            }
        }
    }
}

struct NearbyResultRow: View {
    var item: MKMapItem
    var isSelected: Bool
    var isFavorited: Bool
    var action: () -> Void
    var favoriteAction: () -> Void
    var infoAction: () -> Void
    
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
            .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
            .cornerRadius(8)

            Spacer()

            // Info button
            infoButton

            // Favorite button
            favoriteButton
        }
        .contentShape(Rectangle()) // Ensures the whole row is tappable
        .onTapGesture {
            action() // Trigger row selection
        }
    }

    // Info button
    private var infoButton: some View {
        Button(action: infoAction) {
            Image(systemName: "info.circle")
                .foregroundColor(.blue)
        }
        .buttonStyle(PlainButtonStyle())
        .font(.title)
        .padding(.trailing)
    }

    // Favorite button
    private var favoriteButton: some View {
        Button(action: favoriteAction) {
            Image(systemName: isFavorited ? "star.fill" : "star")
                .foregroundColor(isFavorited ? .yellow : .gray)
        }
        .buttonStyle(PlainButtonStyle())
        .font(.title)
    }
}
           

#Preview {
    NearbyResultsView(
        textLocation1: "Seattle, WA",
        textLocation2: "Los Angeles, CA",
        meetingpointCoordinate: CLLocationCoordinate2D(latitude: 47.6062, longitude: -122.3321),
        locationName: "Seattle, WA"
    )
}

