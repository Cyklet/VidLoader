//
//  VidLoaderExecutionQueueTests.swift
//  VidLoaderTests
//
//  Created by Petre on 03.12.19.
//  Copyright © 2019 Petre. All rights reserved.
//
import XCTest
@testable import VidLoader

final class VidLoaderExecutionQueueTests: XCTestCase {

    func testCalculationOnSameExecutionQueue() {
        // GIVEN
        let completedExpectation = expectation(description: "Completed")
        let executionQueue = VidLoaderExecutionQueue(label: "CustomQueueLabel")
        let expectedResult = 1.0
        var finalResult = 1.0
        let numberOfTimes = 100

        // WHEN
        for _ in 1..<numberOfTimes {
            calculate(on: executionQueue, completion: { finalResult += $0 })
        }

        // THEN
        executionQueue.async {
            finalResult /= Double(numberOfTimes)
            XCTAssertEqual(expectedResult, finalResult)
            completedExpectation.fulfill()
        }
        waitForExpectations(timeout: 0.1, handler: nil)
    }

    func testCalculationOnDifferentExecutionsQueues() {
        // GIVEN
        let expectedResult = 1.0
        var finalResult = 1.0
        let numberOfTimes = 100

        // WHEN
        for _ in 1..<numberOfTimes {
            finalResult += calculateOnDifferentThreads()
        }
        finalResult /= Double(numberOfTimes)

        // THEN
        XCTAssertNotEqual(expectedResult, finalResult)
    }

    // MARK: - Private functions

    private func calculate(on executionQueue: VidLoaderExecutionQueueable, completion: @escaping (Double) -> Void) {
        var result = 1.0
        executionQueue.async {
            result += 1
        }
        executionQueue.async {
            result *= 2
        }
        executionQueue.async {
            result /= 4
        }
        executionQueue.async {
            result += 5
        }
        executionQueue.async {
            result /= 5
        }
        executionQueue.async {
            result *= 10
        }
        executionQueue.async {
            result -= 11
        }
        executionQueue.async {
            completion(result)
        }
    }

    private func calculateOnDifferentThreads() -> Double {
           var result = 1.0
           let sumQueue = VidLoaderExecutionQueue(label: "SumQueue")
           let diferenceQueue = VidLoaderExecutionQueue(label: "DiferenceQueue")
           let divisionQueue = VidLoaderExecutionQueue(label: "DivisionQueue")
           let multiplyQueue = VidLoaderExecutionQueue(label: "MultiplyQueue")
           sumQueue.async {
               result += 1
           }
           multiplyQueue.async {
               result *= 2
           }
           divisionQueue.async {
               result /= 4
           }
           DispatchQueue.main.async {
               result += 5
           }
           DispatchQueue.main.async {
               result /= 5
           }
           multiplyQueue.async {
               result *= 10
           }
           diferenceQueue.async {
               result -= 11
           }

           return result
       }
}
