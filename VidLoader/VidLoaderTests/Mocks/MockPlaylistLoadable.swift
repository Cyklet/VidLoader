//
//  MockPlaylistLoadable.swift
//  VidLoaderTests
//
//  Created by Petre on 12/11/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

final class MockPlaylistLoadable: PlaylistLoadable {
    var nextStreamResource: (String, StreamResource)?
    
    var loadFuncCheck = FuncCheck<(String, URL)>()
    var loadStub: Result<Void, Error> = .success(())
    func load(identifier: String, at url: URL, completion: @escaping Completion<Result<Void, Error>>) {
        loadFuncCheck.call((identifier, url))
        completion(loadStub)
    }
    
    var cancelFuncCheck = FuncCheck<String>()
    func cancel(identifier: String) {
        cancelFuncCheck.call(identifier)
    }
}
