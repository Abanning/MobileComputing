//
//  LocationInputView.swift
//  MeetMeHalfwayV1.1
//
//  Created by Alex Banning on 11/7/24.
//

import SwiftUI
import MapKit

struct LocationInputView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLocation: String
    @Binding var selectedLocationCoordinate: CLLocationCoordinate2D?
    
    @State private var searchText = ""
    @ObservedObject private var searchCompleterDelegate = SearchCompleterDelegate()
    
    var body: some View {
        VStack {
            // Text field for user input
            TextField("Enter a location", text: $searchText)
                .padding()
                .background(Color(.systemGray5))
                .cornerRadius(8)
                .padding()
                .onChange(of: searchText) { value in
                    searchCompleterDelegate.searchCompleter.queryFragment = value
                }
            
            // List of search results
            List(searchCompleterDelegate.searchResults, id: \.self) { result in
                Button(action: {
                    selectedLocation = result.title
                    geocodeSelectedLocation(selectedLocation)
                    dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(result.title)
                            .font(.headline)
                        Text(result.subtitle)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            .background(Color.black)
            .navigationTitle("Search Location")
        }
    }
    
    private func geocodeSelectedLocation(_ address: String) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }
            if let coordinate = placemarks?.first?.location?.coordinate {
                selectedLocationCoordinate = coordinate
            }
        }
    }
}

// ObservableObject for the delegate class
class SearchCompleterDelegate: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchResults: [MKLocalSearchCompletion] = []
    let searchCompleter = MKLocalSearchCompleter()

    override init() {
        super.init()
        searchCompleter.delegate = self
        searchCompleter.resultTypes = .address
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Error in search completer: \(error.localizedDescription)")
    }
}

#Preview {
    LocationInputView(selectedLocation: .constant(""), selectedLocationCoordinate: .constant(CLLocationCoordinate2D()))
}
