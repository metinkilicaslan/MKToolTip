Description
--------------

```MKToolTip``` is a customizable tooltip view written in Swift that can be used as a informative tip.

Installation
--------------

### CocoaPods

To integrate MKToolTip into your Xcode project using CocoaPods, specify it in your `Podfile`:

```ruby
pod 'MKToolTip'
```

Then, run the following command:

```bash
$ pod install
```

### Manually

If you prefer not to use dependency managers, you can integrate MKToolTip into your project manually.

Usage
--------------

1) First you should customize the preferences:

```swift
let gradientColor = UIColor(red: 0.886, green: 0.922, blue: 0.941, alpha: 1.000)
let gradientColor2 = UIColor(red: 0.812, green: 0.851, blue: 0.875, alpha: 1.000)
var preferences = Preferences()
preferences.drawing.bubbleGradientColors = [gradientColor.cgColor, gradientColor2.cgColor]
preferences.drawing.arrowTipCornerRadius = 0
preferences.drawing.messageColor = .black
```

2) Secondly call the ``show(view: identifier: title: message: arrowPosition: preferences: delegate:)`` method:

```swift
MKToolTip.show(view: button1, identifier: "identifier", title: "Dapibus", message: "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.", arrowPosition: .top)
```

Public interface
--------------

###Delegate

```swift
public protocol MKToolTipDelegate: class {
    func toolTipViewDidAppear(for identifier: String)
    func toolTipViewDidDisappear(for identifier: String, with timeInterval: TimeInterval)
}
```

###Public methods

```swift
public class func show(item: UIBarItem, identifier: String, title: String? = nil, message: String, arrowPosition: ArrowPosition, preferences: Preferences = Preferences(), delegate: MKToolTipDelegate? = nil)
    
public class func show(view: UIView, identifier: String, title: String? = nil, message: String, arrowPosition: ArrowPosition, preferences: Preferences = Preferences(), delegate: MKToolTipDelegate? = nil)
```


License
--------------

MIT License, Copyright (c) 2018 Metin Kilicaslan, [@metinkilicaslan](https://twitter.com/metinkilicaslan)
