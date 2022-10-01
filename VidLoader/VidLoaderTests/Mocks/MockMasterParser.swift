//
//  MockMasterParser.swift
//  VidLoaderTests
//
//  Created by Petre on 12/18/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader
import Foundation

struct MockMasterParser: MasterParser {
   
    var adjustFuncCheck = FuncCheck<Data>()
    var adjustStub: Result<Data, M3U8Error> = .success(.mock())
    func adjust(data: Data, completion: @escaping (Result<Data, M3U8Error>) -> Void) {
        adjustFuncCheck.call(data)
        completion(adjustStub)
    }
}
