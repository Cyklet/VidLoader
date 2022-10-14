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
   
    var adjustFuncCheck = FuncCheck<(Data, URL)>()
    var adjustStub: Result<Data, M3U8Error> = .success(.mock())
    func adjust(data: Data, baseURL: URL) -> Result<Data, M3U8Error> {
        adjustFuncCheck.call((data, baseURL))
        return adjustStub
    }
}
