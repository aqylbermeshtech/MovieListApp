//
//  Array+Safe.swift
//  Movter
//
//  Created by Nurtore on 18.08.2026.
//

import Foundation

extension Array {
    /// Bounds-checked lookup: a stale index returns nil instead of trapping.
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
