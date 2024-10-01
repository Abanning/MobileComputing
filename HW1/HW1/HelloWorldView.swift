//
//  HelloWorldView.swift
//  HW1
//
//  Created by Alex Banning on 9/30/24.
//

import SwiftUI

struct HelloWorldView: View {
    @AppStorage("firstTime") var firstTime: Bool = true

    var body: some View {
        NavigationStack {
            ZStack {
                Image("Earth")
                    .resizable()
                    .ignoresSafeArea()
                    .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                VStack {
                    Text("Hello, World")
                        .font(.title)
                        .foregroundColor(Color.white)
                        .padding(.top, 200)
                    Spacer()
                    NavigationLink(destination: NavigationView()) {
                        Text("Tap here to continue")
                            .foregroundStyle(.white)
                            .padding(.bottom, 50)
                    }
                }
                .padding(.all)
            }
        }

    }
}

struct NavigationView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.black)
                    .ignoresSafeArea()
                ScrollView {
                    VStack(spacing: 40) {
                        Text("Navigation Test")
                            .foregroundStyle(.white)
                            .font(.title)
                            .padding(.all)
                        ForEach(1..<11) { x in
                            NavigationLink(destination: {
                                MySecondView(value: x)
                            }, label: {
                                Text("Page: \(x)")
                                    .foregroundStyle(.white)
                            })
                        }
                        .navigationTitle("Navigation Test")
                        .foregroundStyle(.white)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct MySecondView: View {
    let value: Int
    init(value: Int) {
        self.value = value
        print("INIT SCREEN: \(value)")
    }

    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            VStack {
                Spacer()
                if (value != 5) {
                    Text("Hello from page \(value)")
                        .font(.title)
                        .foregroundColor(.white)
                }
                else {
                    Text("YOU'RE HALFWAY THERE!")
                        .foregroundStyle(.white)
                    Text("KEEP GOING! 🥳")
                        .foregroundStyle(.white)
                }
                Spacer()
                NavigationLink(destination: HelloWorldView()) {
                    Text("Tap here to go back to home")
                        .foregroundStyle(.white)
                        .padding(.bottom, 50)
                }
            }
        }
    }
}

#Preview {
    HelloWorldView()
}
