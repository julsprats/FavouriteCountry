//
//  ContentView.swift
//  Julia_A1
//
//  Created by Julia Prats on 2024-02-23.
//

import SwiftUI
import Firebase
import FirebaseFirestore

// main screen
struct ContentView: View {
    @StateObject var favoritesManager = FavoritesDB()
    @State var countriesList: [Country] = []
    @State var selectedCountry: Country?

    var body: some View {
        NavigationView {
            VStack {
                if countriesList.isEmpty {
                    Text("Loading...")
                } else {
                    List(countriesList) { country in
                        NavigationLink(destination: CountryDetailsView(country: country, favoritesManager: favoritesManager)) {
                            Text(country.name.common)
                        }
                    }
                }
            }
            .navigationTitle("Countries")
            .onAppear {
                loadDataFromAPI()
            }
            // to the favs screen
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: FavoriteListView(favoritesManager: favoritesManager, countriesList: countriesList)) {
                        Image(systemName: "star.fill")
                    }
                }
            }
        }
        .sheet(item: $selectedCountry) { country in
            CountryDetailsView(country: country, favoritesManager: favoritesManager)
        }
    }

    func loadDataFromAPI() {
        print("Getting data from API")

        guard let url = URL(string: "https://restcountries.com/v3.1/all") else {
            print("Invalid URL")
            return
        }

        let request = URLRequest(url: url)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error fetching data: \(error)")
                return
            }

            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response")
                return
            }

            if let data = data {
                do {
                    let decodedData = try JSONDecoder().decode([Country].self, from: data)
                    DispatchQueue.main.async {
                        self.countriesList = decodedData
                    }
                } catch {
                    print("Error decoding data: \(error)")
                }
            }
        }

        task.resume()
    }
}

// second screen
struct CountryDetailsView: View {
    let country: Country
    @ObservedObject var favoritesManager: FavoritesDB
    @State private var showAlert = false

    var body: some View {
        VStack {
            Text(country.name.common)
                .font(.title)
            if let capital = country.capital {
                Text("Capital: \(capital.value)")
            } else {
                Text("Capital: N/A")
            }
            Text("Region: \(country.region)")
            Text("Population: \(country.population)")
            if let url = URL(string: country.flags.png),
               let imageData = try? Data(contentsOf: url),
               let uiImage = UIImage(data: imageData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 200, height: 100)
            }
            Button(action: {
                favoritesManager.addFavorite(countryName: country.name.common)
                showAlert = true
            }) {
                Text("MARK AS FAVORITE")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
        .navigationBarTitle(country.name.common, displayMode: .inline)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Added to Favorites"), message: Text("\(country.name.common) added to your favorites."), dismissButton: .default(Text("OK")))
        }
    }
}

// third screen
struct FavoriteListView: View {
    @ObservedObject var favoritesManager = FavoritesDB()
    @State var favoriteCountries: [Country] = []
    var countriesList: [Country]

    @State private var showingConfirmationAlert = false
    @State private var countryToDelete: Country?

    var body: some View {
        NavigationView {
            VStack {
                Section(header: Text("Favorite Countries").font(.title).fontWeight(.bold)) {
                    List {
                        ForEach(favoriteCountries) { country in
                            VStack(alignment: .leading) {
                                Text(country.name.common)
                                    .font(.headline)
                                if let capital = country.capital {
                                    Text("Capital: \(capital.value)")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                } else {
                                    Text("Capital: N/A")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .contextMenu {
                                Button(action: {
                                    self.countryToDelete = country
                                    self.showingConfirmationAlert = true
                                }) {
                                    Label("Remove", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete { indexSet in
                            let countryToDelete = favoriteCountries[indexSet.first!]
                            self.countryToDelete = countryToDelete
                            showingConfirmationAlert = true
                        }
                    }
                }
            }
            .alert(isPresented: $showingConfirmationAlert) {
                Alert(
                    title: Text("Remove Country"),
                    message: Text("Are you sure you want to remove \(countryToDelete?.name.common ?? "this country") from favorites?"),
                    primaryButton: .destructive(Text("Remove")) {
                        if let countryToRemove = countryToDelete {
                            favoritesManager.removeFavorite(countryName: countryToRemove.name.common)
                            favoriteCountries.removeAll(where: { $0 == countryToRemove })
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .onAppear {
                loadFavoriteCountries()
            }
        }
    }

    func loadFavoriteCountries() {
        let filteredCountries = favoritesManager.favorites.compactMap { favoriteName in
            return countriesList.first { $0.name.common == favoriteName }
        }
        self.favoriteCountries = filteredCountries
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
