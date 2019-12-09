//
//  Swizzling.swift
//  VidLoaderTests
//
//  Created by Petre on 12/9/19.
//  Copyright © 2019 Petre. All rights reserved.
//

import Foundation

func swizzle(className: AnyClass, original: Selector, new: Selector) -> () {
    let originalMethod = class_getInstanceMethod(className, original)!
    let swizzledMethod = class_getInstanceMethod(className, new)!
    let swizzledMethodImp = method_getImplementation(swizzledMethod)
    method_setImplementation(originalMethod, swizzledMethodImp)
}
