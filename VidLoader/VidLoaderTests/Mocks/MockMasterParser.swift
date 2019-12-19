//
//  MockMasterParser.swift
//  VidLoaderTests
//
//  Created by Petre on 12/18/19.
//  Copyright © 2019 Petre. All rights reserved.
//

@testable import VidLoader

struct MockMasterParser: MasterParser {
    
    var adjustFuncCheck = FuncCheck<Data>()
    var adjustStub: Result<Data, M3U8Error> = .success(.mock())
    func adjust(data: Data) -> Result<Data, M3U8Error> {
        adjustFuncCheck.call(data)
        return adjustStub
    }
}
