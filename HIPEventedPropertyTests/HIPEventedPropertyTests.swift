//
//  HIPEventedPropertyTests.swift
//  HIPEventedPropertyTests
//
//  Created by Steve Johnson on 7/14/16.
//  Copyright © 2016 Hipmunk, Inc. All rights reserved.
//

import XCTest
@testable import HIPEventedProperty

class HIPEventedPropertyTests: XCTestCase {
    func testSubscribeOnce() {
        let p = HIPEventedProperty<Bool>(false)
        var numTimesFired = 0
        _ = p.subscribeOnce(withObject: self) {
            numTimesFired += 1
        }
        p.value = true
        p.value = false
        XCTAssert(numTimesFired == 1)
    }

    func testSubscribeOnceCanUnsubscribe() {
        let p = HIPEventedProperty<Bool>(false)
        var numTimesFired = 0
        let unsubscribe = p.subscribeOnce(withObject: self) {
            numTimesFired += 1
        }
        unsubscribe()
        p.value = true
        p.value = false
        XCTAssert(numTimesFired == 0)
    }

    func testOnSubscriberAdded() {
        let p = HIPEventedProperty<Bool>(false)

        let expectation = self.expectation(description: "did fire callback")
        p.onSubscriberAdded = { _ in expectation.fulfill() }

        _ = p.subscribe(withObject: self, callback: { })

        waitForExpectations(timeout: 0.1, handler: nil)
    }
}
