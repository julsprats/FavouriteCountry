//
//  CountryData.swift
//  Julia_A1
//
//  Created by Julia Prats on 2024-02-23.
//

import Foundation

// dummy
struct CountryData {
    static let countries: [Country] = [
        Country(
            name: Name(common: "Spain"),
            capital: .single("Madrid"),
            region: "Europe",
            population: 47351567,
            flags: Flags(png: "https://mainfacts.com/media/images/coats_of_arms/es.svg")
        ),
        Country(
            name: Name(common: "Canada"),
            capital: .single("Ottawa"),
            region: "Americas",
            population: 38005238,
            flags: Flags(png: "https://mainfacts.com/media/images/coats_of_arms/ca.svg")
        )
    ]
}
