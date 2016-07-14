# HIPEventedProperty

HIPEventedProperty is a simple library of observables, intended to be the minimum viable support
for a Model-View-ViewModel (MVVM) architecture. At Hipmunk, we've used it for exactly that, and
have hardly changed anything over a year of app development.

Think of it as
[ReactiveCocoa](https://github.com/ReactiveCocoa/ReactiveCocoa)
stripped way, way down. It's less than 150 lines long.

## Design goals

* Small stack traces
* Easily understood memory model
* Simple, clear code with no complex type system tricks
* Obvious API

ReactiveCocoa is a lot more powerful, and even more succinct in most cases, but
HIPEventedProperty asks very little of your brain.

## Examples

### `HIPEventSource`
 
The most basic class in the module is `HIPEventSource`. A `HIPEventSource` collects callbacks
that are tied to the memory lifecycle of objects, and allows them to be fired iff their associated
objects are still alive.

```swift
let p = HIPEventedProperty()
var x: NSObject? = NSObject()

p.subscribe(withObject: x) {
    print("Event fired")
}

p.fireEvent()  // prints "Event fired"
x = nil
p.fireEvent()  // nothing happens
```

99.9% of the time, you'll be instantiating a `HIPEventSource` inside a class, and you'll want its
callback to be cleaned up whenever `self` is deallocated.

```swift
class MyViewController: UIViewController {
    var taps: HIPEventSource!
    @IBOutlet var tapLabel: UILabel!

    override func viewDidLoad() {
        taps = HIPEventSource()
        taps.subscribe(withObject: self) { [weak self] in
            self?.tapLabel.text += (self?.tapLabel.text ?? "") + "tap "
        }
    }
}
```

### HIPEventedProperty

To store a value inside your event source, you'll need to use one of the variants of the
`HIPEventedProperty` class:

* `HIPEventedProperty`: Equatable, non-optional
* `HIPEventedPropertyOptional`: Equatable, optional
* `HIPEventedPropertyBasic`: No restrictions, no skipping of duplicate values

```swift
// numTaps.value has type `Int`
let numTaps = HIPEventedProperty<Int>(0)

// rating.value has type `Int?`
let rating = HIPEventedPropertyOptional<Int>(nil)

// asyncImage.value has type `UIImage?`
let asyncImage = HIPEventedPropertyBasic<UIImage?>(nil)

// Properties have more methods. Here's one:

let x = NSObject()  // this is just an example, never deallocate this
rating.subscribeToValue(withObject: x) {
  if let r = $0 {
    print("Rating: \(r)")
  } else {
    print("Rating: no rating")
  }
}
```