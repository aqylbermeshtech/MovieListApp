//
//  MovieCredits.swift
//  MovieListApp
//
//  Created by Nurtore on 24.03.2026.
//
import UIKit

struct MovieCredits: Codable {
    let cast: [Actor]
}

struct Actor: Codable, Identifiable {
    let id: Int
    let name: String
    let character: String
    let profilePath: String?

    var profileURL: URL? {
        guard let path = profilePath else { return nil }
        return URL(string: "https://image.tmdb.org/t/p/w185\(path)")
    }

    enum CodingKeys: String, CodingKey {
        case id, name, character
        case profilePath = "profile_path"
    }
}
