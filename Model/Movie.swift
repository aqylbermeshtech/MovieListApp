import Foundation

struct Movie: Decodable {
    let title: String
    let overview: String
    let posterPath: String
    let releaseDate: String
    let voteAverage: Double
}
