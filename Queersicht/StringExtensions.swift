//
//  StringExtensions.swift
//  Queersicht
//
//  Created by Fabio Huwyler on 14.07.2024.
//

import Foundation

extension String {
    func stripHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
            .replacingOccurrences(of: "&[^;]+;", with: " ", options: .regularExpression, range: nil)
    }
}
