//
//  WeakrefSubscriber.swift
//  HIPEventedProperty
//
//  Created by Steve Johnson on 7/14/16.
//  Copyright © 2016 Hipmunk, Inc. All rights reserved.
//

import Foundation


/**
 A reference to a callback associated with an object. When the object is deallocated, the subscriber is
 considered dead and will never be called again.
 */
internal class WeakRefSubscriber {
    fileprivate weak var object: AnyObject?
    fileprivate var callback: () -> Void

    init(object: AnyObject, callback: @escaping () -> Void) {
        self.callback = callback
        self.object = object
    }

    /// Returns `true` iff the object is still allocated
    var isObjectAlive: Bool { get { return object != nil } }

    /// Call the callback iff the object is still allocated
    func call() {
        guard isObjectAlive else {
            assertionFailure("Prune your subscriber list before calling its items")
            return
        }
        callback()
    }
}
