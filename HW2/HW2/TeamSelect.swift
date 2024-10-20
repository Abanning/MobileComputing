//
//  TeamSelect.swift
//  HW2
//
//  Created by Alex Banning on 10/18/24.
//

import SwiftUI

struct TeamSelect: View {
    let griffinURL = URL(string: "https://t3.ftcdn.net/jpg/05/84/03/80/360_F_584038065_bTAe8Ly8ZBejUYsJZVJFgYVYGCwbXRtN.jpg")
    
    let dragonURL = URL(string:
        "https://img.freepik.com/free-photo/dragons-fantasy-artificial-intelligence-image_23-2150400884.jpg")
    
    @State private var selectedImageName: String? = nil
    @State private var navigateToPersonalFields = false
    
    func saveImage(image: UIImage, folderName: String = "Images") {
        let fileManager = FileManager.default
        let folderURL = getDocumentsDirectory().appendingPathComponent(folderName)
        
        // Create folder if it doesn't exist
        if !fileManager.fileExists(atPath: folderURL.path) {
            do {
                try fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Error creating folder: \(error)")
            }
        }
            
        let imageURL = folderURL.appendingPathComponent("teamImage.jpg")
        
        if let jpegData = image.jpegData(compressionQuality: 1.0) {
            do {
                try jpegData.write(to: imageURL)
                print("Image saved to \(imageURL)")
            } catch {
                print("Error saving image: \(error)")
            }
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.gray
                    .ignoresSafeArea()
                VStack {
                    Spacer()
                    Text("Select your team")
                        .foregroundStyle(Color.white)
                        .font(.largeTitle)
                    AsyncImage(url: griffinURL, content: { returnedImage in
                        returnedImage
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(100)
                            .scaleEffect(x: -1, y: 1)
                            .onTapGesture {
                                print("Griffin selected")
                                Task {
                                    if let imageData = try? Data(contentsOf: griffinURL!), let image = UIImage(data: imageData) {
                                        saveImage(image: image)
                                        selectedImageName = "Griffin"
                                        navigateToPersonalFields = true
                                    }
                                }
                            }
                    }, placeholder: {
                        ProgressView()
                    })
                    
                    Text("Griffin")
                        .foregroundStyle(Color.white)
                    
                    AsyncImage(url: dragonURL, content: { returnedImage in
                        returnedImage
                            .resizable()
                            .scaledToFit()
                            .cornerRadius(100)
                            .onTapGesture {
                                print("Dragon selected")
                                Task {
                                    if let imageData = try? Data(contentsOf: dragonURL!), let image = UIImage(data: imageData) {
                                        saveImage(image: image)
                                        selectedImageName = "Dragon"
                                        navigateToPersonalFields = true
                                    }
                                }
                            }
                    }, placeholder: {
                        ProgressView()
                    })
                    
                    Text("Dragon")
                        .foregroundStyle(Color.white)
                    
                    Spacer()
                }
                .padding()
                .background(
                    NavigationLink(destination: PersonalFields(selectedTeam: selectedImageName ?? ""), isActive: $navigateToPersonalFields) {
                        EmptyView()
                    }
                )
            }
        }
    }
}

struct PersonalFields: View {
    let selectedTeam: String
    
    @State private var name: String = ""
    @State private var age: String = ""
    @State private var saveMessage: String = ""
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func saveUserInfo(name: String, age: String, team: String) {
        let userInfo = [
            "name": name,
            "age": age,
            "team": team
        ]
        
        let fileURL = getDocumentsDirectory().appendingPathComponent("user_profile.json")
        
        do {
            // Convert the user info dictionary to JSON data
            let data = try JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted)
            try data.write(to: fileURL, options: .atomic)
            
            // Update the message for UI
            saveMessage = "User info saved successfully at \(fileURL.path)"
            print(saveMessage)
        } catch {
            // Handle any errors
            saveMessage = "Failed to save user info: \(error.localizedDescription)"
            print(saveMessage)
        }
    }
    
    var body: some View {
        VStack {
            Text("Team: \(selectedTeam)")
                .font(.title)
            
            TextField("Enter your name", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Enter your age", text: $age)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
                .keyboardType(.numberPad)
            
            Button("Submit") {
                // Save the user information to a file in the document directory
                saveUserInfo(name: name, age: age, team: selectedTeam)
            }
            .padding()
            
            // Display a message confirming whether the save was successful
            Text(saveMessage)
                .foregroundColor(.green)
                .padding()
            
            Spacer()
        }
        .padding()
    }
}
#Preview {
    TeamSelect()
}
