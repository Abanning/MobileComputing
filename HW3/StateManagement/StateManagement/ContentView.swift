//
//  ContentView.swift
//  StateManagement
//
//  Created by Alex Banning on 10/30/24.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        TabView {
            OtterView()
                .tabItem {
                    Image(systemName: "photo")
                }
            
            TextInputView(inputText: .constant(""))
                .tabItem {
                    Image(systemName: "keyboard")
                }
            
            SliderToggleView()
                .tabItem {
                    Image(systemName: "lightbulb.max")
                }
        }
    }
}

#Preview {
    ContentView()
}
