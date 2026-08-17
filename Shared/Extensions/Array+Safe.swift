//
//  Array+Safe.swift
//  MovieListApp
//
//  Created by Nurtore on 18.08.2026.
//

import Foundation

extension Array {
    /// Bounds-checked lookup, so a stale index — a reused control's tag, a table row
    /// read after the data changed — returns nil instead of trapping.
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
