//
//  RegexStrings.swift
//  VidLoader
//
//  Created by Petre Plotnic on 14.10.22.
//

import Foundation

struct RegexStrings {
    private static let uriKey = "URI=\""
    // \r\n -> windows
    // \r -> old macs
    // \n -> unix
    private static let newLine = "\\r\\n|\\r|\\n"
    
    static let uri = "[\\S\\s\(newLine)]*?\(uriKey)([^\(newLine),\"]+)"

    static let key: String = {
        let encryptionKey = "#EXT-X-KEY"

        return "\(encryptionKey)\(uri)"
    }()
    static let mediaSection: String = {
        let mediaSectionKey = "#EXT-X-MAP"
        
        return "\(mediaSectionKey)(?!https)\(uri)"
    }()
    static let relativePlaylist = "(?<=\(newLine))(?!#|https)[\\S]+?(?=\(newLine))"
}
