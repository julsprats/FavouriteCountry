//
//  FavoritesDB.swift
//  Julia_A1
//
//  Created by Julia Prats on 2024-02-23.
//

import Foundation
import Firebase
import FirebaseFirestore

class FavoritesDB: ObservableObject {
    @Published var favorites: [String] = []

    init() {
        loadFavorites()
    }

    func addFavorite(countryName: String) {
        if !favorites.contains(countryName) {
            favorites.append(countryName)
            saveFavorites()
        }
    }

    private func loadFavorites() {
        let db = Firestore.firestore()
        let favoritesRef = db.collection("Countries").document("Favorites")

        favoritesRef.getDocument { document, error in
            if let document = document, document.exists {
                if let favoritesArray = document.data()?["favorites"] as? [String] {
                    DispatchQueue.main.async {
                        self.favorites = favoritesArray
                    }
                }
            } else {
                print("Document does not exist")
            }
        }
    }

    private func saveFavorites() {
        let db = Firestore.firestore()
        let favoritesRef = db.collection("Countries").document("Favorites")

        favoritesRef.setData(["favorites": favorites]) { error in
            if let error = error {
                print("Error saving favorites: \(error)")
            } else {
                print("Favorites saved successfully")
            }
        }
    }
    
    func removeFavorite(countryName: String) {
            favorites.removeAll(where: { $0 == countryName })
            saveFavorites()
    }
}
