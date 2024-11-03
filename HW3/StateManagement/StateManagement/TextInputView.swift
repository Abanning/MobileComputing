//
//  TextInputView.swift
//  StateManagement
//
//  Created by Alex Banning on 10/30/24.
//

import SwiftUI

struct TextInputView: View {
    @Binding var inputText: String
    @State private var input: String = ""
    
    @Environment(\.scenePhase) var scenePhase
    
    var body: some View {
        VStack {
            Spacer()
            Text ("Step 1: Enter some text. The top box represents a State variable, the bottom a normal variable.")
                .font(.title)
                .padding(.horizontal, 40)
                .padding(.bottom)
            HStack {
                Spacer()
                TextField("Enter text here", text: $input)
                    .padding(.horizontal, 80)
                    .frame(width: 300, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(40)
                Spacer()
            }
            .padding(.bottom)
            HStack {
                Spacer()
                TextField("Enter text here", text: $inputText)
                    .padding(.horizontal, 80)
                    .frame(width: 300, height: 40)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(40)
                Spacer()
            }
            .padding(.bottom)
            Text("Step 2: Close the app and come back to this screen.")
                .font(.title)
                .padding(.horizontal, 40)
                .padding(.bottom)
            Text("Step 3: Confirm that the top text field retained the data entered, and the bottom reset. This is because state variables maintain their values across the app lifecycle until forcefully killed.")
                .font(.title)
                .padding(.horizontal, 40)
            Spacer()
        }
        .onChange(of: scenePhase) { currentPhase in
            if currentPhase == .active {
                print("Variable inputText: \(inputText)")
                print("State Variable input: \(input)")
            }
            else if currentPhase == .inactive {
                print("Variable inputText: \(inputText)")
                print("State Variable input: \(input)")
            }
            else if currentPhase == .background {
                print("Variable inputText: \(inputText)")
                print("State Variable input: \(input)")
            }
        }
    }
}

#Preview {
    TextInputView(inputText: .constant(""))
}
