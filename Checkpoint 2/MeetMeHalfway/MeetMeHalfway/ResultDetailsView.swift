//
//  ResultDetailsView.swift
//  MeetMeHalfway
//
//  Created by Alex Banning on 10/26/24.
//

import SwiftUI
import MapKit

struct ResultDetailsView: View {
    var item: MKMapItem
    
    var body: some View {
        VStack {
            Text(item.name ?? "Unknown Place")
                .font(.largeTitle)
                .padding()
            
            if let address = item.placemark.title {
                Text(address)
                    .font(.headline)
                    .padding()
            }
            
            // You can add more details about the item here
            Spacer()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }
}
