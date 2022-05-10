//
//  MockPlaylistParser.swift
//  VidLoaderTests
//
//  Created by Petre on 12/18/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader
import Foundation

struct MockPlaylistParser: PlaylistParser {

    var adjustFuncCheck = FuncCheck<(Data, URL, [String : String]?)>()
    var adjustStub: Result<Data, M3U8Error> = .success(.mock())
    func adjust(data: Data, with baseURL: URL, headers: [String : String]?, completion: @escaping (Result<Data, M3U8Error>) -> Void) {
        adjustFuncCheck.call((data, baseURL, headers))
        completion(adjustStub)
    }
}
