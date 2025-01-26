//
//  Country.swift
//  Julia_A1
//
//  Created by Julia Prats on 2024-02-23.
//

import Foundation

import SwiftUI

struct Country: Codable, Identifiable, Equatable {
    var id: String { name.common }
    let name: Name
    let capital: Capital?
    let region: String
    let population: Int
    let flags: Flags

    static func == (lhs: Country, rhs: Country) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Name: Codable {
    let common: String
}

enum Capital: Codable {
    case single(String)
    case multiple([String])

    init(from decoder: Decoder) throws {
        if let singleValue = try? decoder.singleValueContainer().decode(String.self) {
            self = .single(singleValue)
            return
        }
        if let arrayValue = try? decoder.singleValueContainer().decode([String].self) {
            self = .multiple(arrayValue)
            return
        }
        throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Expected String or [String], but found neither."))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .single(let value):
            try container.encode(value)
        case .multiple(let values):
            try container.encode(values)
        }
    }

    var value: String {
        switch self {
        case .single(let value):
            return value
        case .multiple(let values):
            return values.joined(separator: ", ")
        }
    }
}

struct Flags: Codable {
    let png: String
}
