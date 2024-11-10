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
            Text(item.name ?? "Unknown")
                .font(.title)
                .padding()
            
            Text(item.placemark.title ?? "No address available")
                .font(.subheadline)
                .padding(.bottom)
            
            Button("View on Maps") {
                if let url = item.url {
                    UIApplication.shared.open(url)
                }
            }
            .padding()
            
            Spacer()
        }
        .navigationTitle("Details")
        .padding()
        }
}
