//
//  ViewUserInfo.swift
//  HW2
//
//  Created by Alex Banning on 10/19/24.
//

import SwiftUI

struct ViewUserInfo: View {
    @State private var userInfo: [String: String]? = nil
    @State private var userImage: UIImage? = nil
    @State private var loadMessage: String = ""
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func loadUserInfo() {
        let fileURL = getDocumentsDirectory().appendingPathComponent("user_profile.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            let loadedUserInfo = try JSONSerialization.jsonObject(with: data, options: []) as? [String: String]
            userInfo = loadedUserInfo
            
            if let loadedUserInfo = loadedUserInfo {
                loadMessage = "User info loaded successfully."
                print("Loaded user info: \(loadedUserInfo)")
            } else {
                loadMessage = "No user info found."
            }
        } catch {
            loadMessage = "Failed to load user info: \(error.localizedDescription)"
            print("Error loading user info: \(error)")
        }
    }
    
    func loadImage() {
        let imageURL = getDocumentsDirectory().appendingPathComponent("Images/teamImage.jpg")
        
        if FileManager.default.fileExists(atPath: imageURL.path) {
            if let imageData = try? Data(contentsOf: imageURL) {
                userImage = UIImage(data: imageData)
            } else {
                loadMessage = "Failed to load the image."
                print("Error loading image from \(imageURL)")
            }
        } else {
            loadMessage = "No image found at the path."
            print("No image found at \(imageURL.path)")
        }
    }
    
    var body: some View {
        ZStack {
            Color.gray
                .ignoresSafeArea()
            VStack {
                Spacer()
                ZStack {
                    Color.black
                        .frame(width: 200, height: 80)
                        .cornerRadius(20)
                    Text("User Profile")
                        .font(.largeTitle)
                        .foregroundStyle(Color.white)
                        .padding()
                }
                
                if let userInfo = userInfo {
                    if let userImage = userImage {
                        Image(uiImage: userImage)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 300, height: 300)
                    }
                    
                    ZStack {
                        Color.black
                            .frame(width: 200, height: 100)
                            .cornerRadius(20)
                        VStack {
                            Text("Name: \(userInfo["name"] ?? "Unknown")")
                                .foregroundStyle(Color.white)
                            Text("Age: \(userInfo["age"] ?? "Unknown")")
                                .foregroundStyle(Color.white)
                            Text("Team: \(userInfo["team"] ?? "Unknown")")
                                .foregroundStyle(Color.white)
                        }
                    }
                } else {
                    Text(loadMessage)
                        .foregroundColor(.red)
                }
                
                Spacer()
            }
            .onAppear {
                loadUserInfo()
                loadImage() // Load the image when the view appears
            }
            .padding()
        }
    }
}

#Preview {
    ViewUserInfo()
}
