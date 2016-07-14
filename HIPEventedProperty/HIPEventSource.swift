//
//  HIPEventSource.swift
//  HIPEventedProperty
//
//  Created by Steve Johnson on 7/14/16.
//  Copyright © 2016 Hipmunk, Inc. All rights reserved.
//

import Foundation


/**
 Collects callbacks and allows them to be fired. Each callback is associated with an object. If that object
 is ever deallocated, the callback will no longer be called.
 */
public class HIPEventSource: NSObject {
    private var _subscribers: [WeakRefSubscriber] = []

    /// You may assign this to a block which is called whenever a subscriber is added to this event source.
    public var onSubscriberAdded: (AnyObject, ()->()) -> () = { _ in }

    /// Add a callback associated with `object`.
    public func subscribe(withObject object: AnyObject, callback: () -> ()) -> () -> () {
        let s = WeakRefSubscriber(object: object, callback: callback)
        _subscribers.append(s)
        onSubscriberAdded(object, callback)
        return { [weak self] in
            self?._subscribers = self?._subscribers.filter({ return $0 !== s }) ?? []
        }
    }

    /// Add a callback associated with `object`, to be called at most once.
    public func subscribeOnce(withObject object: AnyObject, callback: () -> ()) -> () -> () {
        var unsubscribe: (() -> ())?
        unsubscribe = self.subscribe(withObject: object, callback: {
            callback()
            unsubscribe?()
            unsubscribe = nil
        })
        return unsubscribe!
    }

    /// Remove all subscribers
    public func removeAllSubscribers() { _subscribers = [] }

    private func _removeDeadSubscribers() { _subscribers = _subscribers.filter({ return $0.isObjectAlive }) }

    /// Call all callbacks whose objects have not yet been deallocated
    @objc public func fireEvent() {
        _removeDeadSubscribers()
        for subscriber in _subscribers {
            subscriber.call()
        }
    }
}