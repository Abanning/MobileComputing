//
//  SliderToggleView.swift
//  StateManagement
//
//  Created by Alex Banning on 11/2/24.
//

import SwiftUI

struct SliderToggleView: View {
    @State private var sliderValue: Double = 0.0
    @State private var isLightOff: Bool = false


    var body: some View {
        ZStack {
            if (isLightOff) {
                Color.black.opacity(0.8)
                    .ignoresSafeArea()
            }
            
            VStack {
                Spacer()
                Text("Select your favorite integer")
                    .padding()
                Text(String(format: "%.0f", sliderValue))
                
                Slider(value: $sliderValue,
                       in: 0...9,
                       step: 1.0,
                       minimumValueLabel: Text("1"),
                       maximumValueLabel: Text("9"),
                       label: { Text("Slider Value: \(sliderValue)") }
                )
                .accentColor(.red)
                .padding(.horizontal, 40)
                Spacer()
                
                Toggle("Turn off the lights?", isOn: $isLightOff)
                    .padding(.horizontal, 40)
                Spacer()
                Text("Close the app and check that the favorite integer value has stayed the same and the background light remains in the same position you left it.")
                    .padding(.horizontal, 40)
                    .font(.title)
                Spacer()
                Spacer()
            }
        }
    }
}

#Preview {
    SliderToggleView()
}
