//
//  MockPlaylistParser.swift
//  VidLoaderTests
//
//  Created by Petre on 12/18/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

struct MockPlaylistParser: PlaylistParser {
    
    var adjustFuncCheck = FuncCheck<(Data, URL)>()
    var adjustStub: Result<Data, M3U8Error> = .success(.mock())
    func adjust(data: Data, with baseURL: URL, completion: @escaping (Result<Data, M3U8Error>) -> Void) {
        adjustFuncCheck.call((data, baseURL))
        completion(adjustStub)
    }
}
