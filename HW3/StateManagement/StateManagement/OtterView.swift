//
//  OtterView.swift
//  StateManagement
//
//  Created by Alex Banning on 10/30/24.
//

import SwiftUI

struct OtterView: View {
    
    @State private var text = "Here is my new table!"
    @State private var hasClosed: Bool = false
    @State private var hasFlippedTable: Bool = false
    @State private var otterImage: String  = "HappyOtter.png"
    @State private var tableImage: String = "Table.png"
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        VStack {
            Image(uiImage: UIImage(named: otterImage)!)
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)
            Text(text)
                .font(.system(size: 40))
                .padding()
                .bold()
            Image(uiImage: UIImage(named: tableImage)!)
                .resizable()
                .scaledToFit()
                .padding()
                .frame(width: 400, height: 400)
        }
        .onChange(of: scenePhase) { currentPhase in
            if (currentPhase == .active) {
                if (self.hasClosed) {
                    self.text = "You again?? What was that for?!"
                    self.otterImage = "SkepticalOtter.png"
                    self.tableImage = "UpsideDownTable.png"
                }
                else {
                    if (hasFlippedTable) {
                        self.text = "That was a close one!"
                        self.otterImage = "HappyOtter.png"
                        self.tableImage = "Table.png"
                    }
                }
                print("App is active")
            }
            else if (currentPhase == .inactive) {
                if (!self.hasClosed) {
                    self.hasFlippedTable = true
                    self.text = "AH! BE CAREFUL!"
                    self.otterImage = "ShockedOtter.png"
                    self.tableImage = "FlippedTable.png"
                }
                print("App is inactive")
            }
            else if (currentPhase == .background) {
                self.hasClosed = true
                self.text = "You again?? What was that for?!"
                self.otterImage = "SkepticalOtter.png"
                self.tableImage = "UpsideDownTable.png"
                print("App is in the background")
            }
        }
    }
}

#Preview {
    OtterView()
}
