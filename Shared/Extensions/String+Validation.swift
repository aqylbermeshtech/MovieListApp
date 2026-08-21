//
//  String+Validation.swift
//  Movter
//

import Foundation

extension String {
    var isValidEmail: Bool {
        let regex = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return range(of: regex, options: .regularExpression) != nil
    }

    var isStrongPassword: Bool {
        return count >= 8
            && rangeOfCharacter(from: .decimalDigits) != nil
            && rangeOfCharacter(from: .letters) != nil
    }
}
