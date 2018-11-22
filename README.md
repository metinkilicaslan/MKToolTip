[![Languages](https://img.shields.io/badge/language-swift%204.2%20|%20objc-FF69B4.svg?style=plastic)](#) <br/>

Description
--------------

```MKToolTip``` is a customizable tooltip view written in Swift that can be used as a informative tip inside your both Swift and Objective-C projects.

<img src="https://github.com/metinkilicaslan/MKToolTip/blob/master/MKToolTip.gif" width="320">

Requirements
-----------------------------

- iOS 9.0+

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

### Carthage

To integrate MKToolTip into your Xcode project using Carthage, specify it in your `Cartfile`:

```ogdl
github "metinkilicaslan/MKToolTip"
```

Run `carthage update` to build the framework and drag the built `MKToolTip.framework` into your Xcode project.

### Manually

If you prefer not to use dependency managers, you can integrate MKToolTip into your project manually.

Usage
--------------

1) First you should customize the preferences:

```swift
let gradientColor = UIColor(red: 0.886, green: 0.922, blue: 0.941, alpha: 1.000)
let gradientColor2 = UIColor(red: 0.812, green: 0.851, blue: 0.875, alpha: 1.000)
let preference = ToolTipPreferences()
preference.drawing.bubble.gradientColors = [gradientColor, gradientColor2]
preference.drawing.arrow.tipCornerRadius = 0
preference.drawing.message.color = .black
```

2) Secondly call the ``showToolTip(identifier: title: message: arrowPosition: preferences: delegate:)`` method:

```swift
let view = UIView()
view.showToolTip(identifier: "identifier", title: "Dapibus", message: "Aenean eu leo quam. Pellentesque ornare sem lacinia quam venenatis vestibulum.", arrowPosition: .top)
```

Public interface
--------------

### Delegate

```swift
public protocol MKToolTipDelegate: class {
    func toolTipViewDidAppear(for identifier: String)
    func toolTipViewDidDisappear(for identifier: String, with timeInterval: TimeInterval)
}
```

### Public extension methods

```swift
public extension UIView {
    public func showToolTip(identifier: String, title: String? = nil, message: String, arrowPosition: MKToolTip.ArrowPosition, preferences: ToolTipPreferences = ToolTipPreferences(), delegate: MKToolTipDelegate? = nil)
}

public extension UIBarItem {
    public func showToolTip(identifier: String, title: String? = nil, message: String, arrowPosition: MKToolTip.ArrowPosition, preferences: ToolTipPreferences = ToolTipPreferences(), delegate: MKToolTipDelegate? = nil)
}
```


License
--------------

MIT License, Copyright (c) 2018 Metin Kilicaslan, [@metinkilicaslan](https://twitter.com/metinkilicaslan)
