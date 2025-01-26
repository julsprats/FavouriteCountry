//
//  Julia_A1App.swift
//  Julia_A1
//
//  Created by Julia Prats on 2024-02-23.
//

import SwiftUI
import Firebase
import FirebaseCore
import FirebaseFirestore

@main
struct Julia_A1App: App {
    
    init(){
        FirebaseApp.configure()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
