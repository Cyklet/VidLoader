//
//  StringExtensions.swift
//  VidLoader
//
//  Created by Petre on 01.09.19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

extension String {
    func matches(for pattern: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: pattern)
            let results = regex.matches(in: self, range: NSRange(self.startIndex..., in: self))

            return results.compactMap {
                // M3U8 parsers works with capture groups, last capture group is the correct result
                let captureGroup = $0.numberOfRanges - 1
                guard let range = Range($0.range(at: captureGroup), in: self) else { return nil }
                return String(self[range])
            }
        } catch _ {
            return []
        }
    }

    var data: Data? {
        return data(using: .utf8)
    }

    var removingIllegalCharacters: String {
        let illegalCharacters = CharacterSet.alphanumerics.union(.whitespaces)
        let validString = components(separatedBy: illegalCharacters.inverted).joined()

        return validString.truncate(length: 200)
    }

    private func truncate(length: Int) -> String {
        return count <= length ? self : String(prefix(length))
    }
}
