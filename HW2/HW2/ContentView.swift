//
//  ContentView.swift
//  HW2
//
//  Created by Alex Banning on 10/18/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            TeamSelect()
                .tabItem {
                    Text("Team Select")
                }
            
            ViewUserInfo()
                .tabItem {
                    Text("View User Info")
                }
        }
    }
}

#Preview {
    ContentView()
}
