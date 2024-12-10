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
        request.region = MKCoordinateRegion(center: meetingpointCoordinate, latitudinalMeters: 1000, longitudinalMeters: 1000)
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                DispatchQueue.main.async {
                    completion(response.mapItems)
                }
            } else {
                print("Error fetching \(query) results: \(String(describing: error))")
                print()
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
        performSearch(query: "entertainment") { items in
            self.activitiesAndTourism = items
        }
    }
    
    func fetchBusinessID(phone_number: String, completion: @escaping (Result<String, Error>) -> Void) {
        var phone = phone_number.replacingOccurrences(of: " ", with: "")
        phone = phone.replacingOccurrences(of: "(", with: "")
        phone = phone.replacingOccurrences(of:")", with: "")
        phone = phone.replacingOccurrences(of:"-", with: "")
        let URL = URL(string: "https://api.yelp.com/v3/businesses/search/phone?phone=\(phone)")
        let api_key = "YOUR_API_KEY"
        
        var request = URLRequest(url: URL!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("Bearer \(api_key)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        print("Attempting to Fetch Yelp API Business ID...")
        print("@URL: \(URL!)")
        
        // Perform the network request
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                let response = try JSONDecoder().decode(SingleBusinessResponse.self, from: data)
                if let business = response.businesses.first {
                    let businessID = business.id
                    print("Business ID Captured!    ID: \(businessID)")
                    print()
                    completion(.success(businessID))
                } else {
                    print("No business found.")
                    completion(.failure(NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No business found"])))
                }
            } catch {
                print("Error decoding JSON: \(error)")
                completion(.failure(error))
            }
        }.resume()
        
    }
}

struct NearbyResultsView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var navigationPath = NavigationPath()
    
    @State private var selectedCategory: Category = .hotels
    
    var textLocation1: String
    var textLocation2: String
    var locationName: String
    @State var meetingpointCoordinate: CLLocationCoordinate2D?
    
    @StateObject private var viewModel: NearbyResultsViewModel
    @State private var visibleHotelCount = 10
    @State private var visibleFoodAndDrinkCount = 10
    @State private var visibleActivitiesCount = 10
    @State private var selectedItem: MKMapItem?
    @State private var favoriteResults: FavoriteResults?
    @State private var isShowingDetails: Bool = false
    @State private var businessID: String?
    @State private var businessURL: URL?
    @State private var isShowingAlert: Bool = false
    @State private var reloadMap: Bool = false
    
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
        
        // Set highlight color to user accent color
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(Color.accentColor)
    }
    
    enum Category: String, CaseIterable {
        case hotels = "Hotels"
        case foodAndDrink = "Food & Drink"
        case activities = "Activities"
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    if (reloadMap == false) {
                        NearbyResultsMapView(meetingpointCoordinate: meetingpointCoordinate ?? CLLocationCoordinate2D(), selectedItem: selectedItem)
                    }
                    else {
                        NearbyResultsMapView(meetingpointCoordinate: meetingpointCoordinate ?? CLLocationCoordinate2D(), selectedItem: selectedItem)
                    }
                    
                    Picker("Category", selection: $selectedCategory) {
                        ForEach(Category.allCases, id: \.self) { category in
                            Text(category.rawValue).tag(category)
                        }
                    }
                    .backgroundStyle(Color.blue)
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    List {
                        switch selectedCategory {
                        case .hotels:
                            hotelsSection
                        case .foodAndDrink:
                            foodAndDrinkSection
                        case .activities:
                            activitiesSection
                        }
                    }
                    .listStyle(GroupedListStyle())
                    
                    .sheet(isPresented: $isShowingDetails) {
                        VStack {
                            // Close button in the top right corner
                            HStack {
                                Spacer()
                                Button(action: {
                                    isShowingDetails = false
                                }) {
                                    Image(systemName: "xmark.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.black)
                                }
                            }
                            .padding()
                            
                            if self.businessURL != nil {
                                WebView(url: self.businessURL!)
                                    .colorScheme(.dark)
                            } else {
                                Spacer()
                                Spacer()
                                
                                VStack {
                                    ProgressView()
                                        .colorScheme(.dark)
                                    Text("Loading website...")
                                        .font(.title)
                                }
                                Spacer()
                            }
                        }
                    }
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
            .alert(isPresented: $isShowingAlert) {
                Alert(
                    title: Text("Trip Saved"),
                    message: Text("Your trip favorites have been saved successfully. Please select the \"Saved Trips\" tap to view your trip details."),
                    dismissButton: .default(Text("OK"))
                )
            }
            // To implement state save after app kill
            /*
            .onChange(of: scenePhase) {
                if (scenePhase == .background) {
                    print("App has moved to the background.")
                    print("Attempting to save user state...")
                    saveTripInProgress()
                    saveNavigationPath(navigationPath: self.navigationPath)
                }
            }*/
        }
        .colorScheme(.dark)
    }
    
    private func saveNavigationPath(navigationPath: NavigationPath) {
        let pathString = String(describing: navigationPath)
        print(pathString)
        
        // Save the string representation of the navigation path to UserDefaults
        UserDefaults.standard.set(pathString, forKey: "savedNavigationPath")
    }
    
    private func saveTripInProgress() {
        let stringAppend = "CachedTrip"
        do {
            let fileURL = try FileManager.default
                .url(for: .cachesDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathComponent("\(stringAppend).json")
            
            let data = try JSONEncoder().encode(favoriteResults)
            try data.write(to: fileURL)
            print("Trip data saved successfully at \(fileURL)")
        } catch {
            print("Failed to save trip data: \(error.localizedDescription)")
        }
    }
    
    private func saveTripData() {
        let stringAppend = "\(textLocation1)->\(textLocation2)@\(locationName)"
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
        
        isShowingAlert = true
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
    
    private var hotelsSection: some View {
        Section(header: Text("Hotels")) {
            ForEach(viewModel.hotels.prefix(visibleHotelCount), id: \.self) { item in
                NearbyResultRow(
                    item: item,
                    isSelected: selectedItem == item,
                    isFavorited: isFavorited(item),
                    action: { handleItemTap(item: item) },
                    favoriteAction: { toggleFavorite(for: item) },
                    infoAction: { showInfoForItem(item) }
                )
            }
            if viewModel.hotels.count > visibleHotelCount {
                Button("Show More") { visibleHotelCount += 10 }.foregroundColor(.blue)
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
                    action: { handleItemTap(item: item) },
                    favoriteAction: { toggleFavorite(for: item) },
                    infoAction: { showInfoForItem(item) }
                )
            }
            if viewModel.foodAndDrink.count > visibleFoodAndDrinkCount {
                Button("Show More") { visibleFoodAndDrinkCount += 10 }.foregroundColor(.blue)
            }
        }
    }

    private var activitiesSection: some View {
        Section(header: Text("Activities")) {
            ForEach(viewModel.activitiesAndTourism.prefix(visibleActivitiesCount), id: \.self) { item in
                NearbyResultRow(
                    item: item,
                    isSelected: selectedItem == item,
                    isFavorited: isFavorited(item),
                    action: { handleItemTap(item: item) },
                    favoriteAction: { toggleFavorite(for: item) },
                    infoAction: { showInfoForItem(item) }
                )
            }
            if viewModel.activitiesAndTourism.count > visibleActivitiesCount {
                Button("Show More") { visibleActivitiesCount += 10 }.foregroundColor(.blue)
            }
        }
    }

    private func handleItemTap(item: MKMapItem) {
        toggleReloadMap()
        selectedItem = item
    }
    
    private func showInfoForItem(_ item: MKMapItem) {
        guard let phone_number = item.phoneNumber else { return }
        self.isShowingDetails = true
        self.businessURL = nil
        
        viewModel.fetchBusinessID(phone_number: phone_number) { result in
            switch result {
            case .success(let businessID):
                self.businessID = businessID
                self.businessURL = URL(string: "https://www.yelp.com/biz/\(businessID)")
                print("Created Yelp URL: \(businessURL!)")
                print()
                
            case .failure(let error):
                self.businessURL = item.url ?? nil
                print("Error fetching Yelp details: \(error)")
                print()
            }
        }
    }
    
    private func toggleReloadMap() {
        self.reloadMap.toggle()
    }
}

// MARK: - MapView Subview
struct NearbyResultsMapView: View {
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
        .frame(height: 250)
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
            Spacer()
            Text(item.name ?? "Unnamed")
                .padding(.leading)
                .frame(width: 200, alignment: .leading)
            Spacer()
            
            Button(action: infoAction) {
                Image(systemName: "info.circle")
            }
            .buttonStyle(PlainButtonStyle())
            
            Spacer()
            
            Button(action: favoriteAction) {
                Image(systemName: isFavorited ? "star.fill" : "star")
            }
            .buttonStyle(PlainButtonStyle())
            Spacer()
            
        }
        .padding()
        .background(isSelected ? Color.gray.opacity(0.2) : Color.clear)
        .cornerRadius(8)
        .onTapGesture { action() }
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
