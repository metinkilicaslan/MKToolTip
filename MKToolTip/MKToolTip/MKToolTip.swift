//
//  MKToolTip.swift
//
// Copyright (c) 2018 Metin Kilicaslan
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

import UIKit

@objc public protocol MKToolTipDelegate: class {
    func toolTipViewDidAppear(for identifier: String)
    func toolTipViewDidDisappear(for identifier: String, with timeInterval: TimeInterval)
}

// MARK: Public methods extensions

public extension UIView {

    @objc public func showToolTip(identifier: String, title: String? = nil, message: String, arrowPosition: MKToolTip.ArrowPosition, preferences: Preferences = Preferences(), delegate: MKToolTipDelegate? = nil) {
        let tooltip = MKToolTip(view: self, identifier: identifier, title: title, message: message, arrowPosition: arrowPosition, preferences: preferences, delegate: delegate)
        tooltip.calculateFrame()
        tooltip.show()
    }
    
}

public extension UIBarItem {
    
    @objc public func showToolTip(identifier: String, title: String? = nil, message: String, arrowPosition: MKToolTip.ArrowPosition, preferences: Preferences = Preferences(), delegate: MKToolTipDelegate? = nil) {
        if let view = self.view {
            view.showToolTip(identifier: identifier, title: title, message: message, arrowPosition: arrowPosition, preferences: preferences, delegate: delegate)
        }
    }
    
}

// MARK: Preferences

@objc public class Preferences: NSObject {
    
    @objc public class Drawing: NSObject {
        @objc public var arrowTip: CGPoint = .zero
        @objc public var arrowSize: CGSize = CGSize(width: 20, height: 10)
        @objc public var arrowTipCornerRadius: CGFloat = 5
        
        @objc public var bubbleInset: CGFloat = 15
        @objc public var bubbleSpacing: CGFloat = 5
        @objc public var bubbleCornerRadius: CGFloat = 5
        @objc public var bubbleMaxWidth: CGFloat = 210
        @objc public var bubbleGradientlocations: [CGFloat] = [0.05, 1.0]
        @objc public var bubbleGradientColors: [UIColor] = [UIColor(red: 0.761, green: 0.914, blue: 0.984, alpha: 1.000), UIColor(red: 0.631, green: 0.769, blue: 0.992, alpha: 1.000)]
        
        @objc public var titleFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .bold)
        @objc public var titleColor: UIColor = .white
        
        @objc public var messageFont: UIFont = UIFont.systemFont(ofSize: 12, weight: .regular)
        @objc public var messageColor: UIColor = .white
        
        @objc public var backgroundGradientlocations: [CGFloat] = [0.05, 1.0]
        @objc public var backgrounGradientColors: [UIColor] = [UIColor.clear, UIColor.black.withAlphaComponent(0.4)]
    }
    
    @objc public class Animating: NSObject {
        @objc public var dismissTransform: CGAffineTransform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        @objc public var showInitialTransform: CGAffineTransform = CGAffineTransform(scaleX: 0, y: 0)
        @objc public var showFinalTransform: CGAffineTransform = .identity
        @objc public var springDamping: CGFloat = 0.7
        @objc public var springVelocity: CGFloat = 0.7
        @objc public var showInitialAlpha: CGFloat = 0
        @objc public var dismissFinalAlpha: CGFloat = 0
        @objc public var showDuration: TimeInterval = 0.7
        @objc public var dismissDuration: TimeInterval = 0.7
    }
    
    @objc public var drawing: Drawing = Drawing()
    @objc public var animating: Animating = Animating()
    
    @objc public override init() {}
    
}

// MARK: MKToolTip class implementation

open class MKToolTip: UIView {
    
    @objc public enum ArrowPosition: Int {
        case top
        case right
        case bottom
        case left
    }
    
    // MARK: Variables
    
    private var arrowPosition: ArrowPosition = .top
    private var bubbleFrame: CGRect = .zero
    
    private var containerWindow: UIWindow?
    private unowned var presentingView: UIView
    
    private var identifier: String
    private var title: String?
    private var message: String
    
    private weak var delegate: MKToolTipDelegate?
    
    private var viewDidAppearDate: Date = Date()
    
    private var preferences: Preferences
    
    // MARK: Lazy variables
    
    private lazy var gradient: CGGradient = { [unowned self] in
        let colors = self.preferences.drawing.bubbleGradientColors.map { $0.cgColor } as CFArray
        let locations = self.preferences.drawing.bubbleGradientlocations
        return CGGradient(colorsSpace: nil, colors: colors, locations: locations)!
        }()
    
    private lazy var titleSize: CGSize = { [unowned self] in
        var attributes = [NSAttributedStringKey.font : self.preferences.drawing.titleFont]
        
        var textSize = CGSize.zero
        if self.title != nil {
            textSize = self.title!.boundingRect(with: CGSize(width: self.preferences.drawing.bubbleMaxWidth - self.preferences.drawing.bubbleInset * 2, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        }
        
        textSize.width = ceil(textSize.width)
        textSize.height = ceil(textSize.height)
        
        return textSize
        }()
    
    private lazy var messageSize: CGSize = { [unowned self] in
        var attributes = [NSAttributedStringKey.font : self.preferences.drawing.messageFont]
        
        var textSize = self.message.boundingRect(with: CGSize(width: self.preferences.drawing.bubbleMaxWidth - self.preferences.drawing.bubbleInset * 2, height: .greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
        
        textSize.width = ceil(textSize.width)
        textSize.height = ceil(textSize.height)
        
        return textSize
        }()
    
    private lazy var bubbleSize: CGSize = { [unowned self] in
        var height = self.preferences.drawing.bubbleInset + self.messageSize.height + self.preferences.drawing.bubbleInset
        
        if self.title != nil {
            height += self.titleSize.height + self.preferences.drawing.bubbleSpacing
        }
        
        let inset = self.preferences.drawing.bubbleInset * 2
        let width = min(self.preferences.drawing.bubbleMaxWidth, max(self.titleSize.width + inset, self.messageSize.width + inset))
        return CGSize(width: width, height: height)
        }()
    
    private lazy var contentSize: CGSize = { [unowned self] in
        var height: CGFloat = 0
        var width: CGFloat = 0
        
        switch self.arrowPosition {
        case .top, .bottom:
            height = self.preferences.drawing.arrowSize.height + self.bubbleSize.height
            width = self.bubbleSize.width
        case .right, .left:
            height = self.bubbleSize.height
            width = self.preferences.drawing.arrowSize.height + self.bubbleSize.width
        }
        
        return CGSize(width: width, height: height)
        }()
    
    // MARK: Initializer
    
    init(view: UIView, identifier: String, title: String? = nil, message: String, arrowPosition: ArrowPosition, preferences: Preferences, delegate: MKToolTipDelegate? = nil) {
        self.presentingView = view
        self.identifier = identifier
        self.title = title
        self.message = message
        self.arrowPosition = arrowPosition
        self.preferences = preferences
        self.delegate = delegate
        super.init(frame: .zero)
        self.backgroundColor = .clear
    }
    
    @available(*, unavailable)
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Gesture methods
    
    @objc func handleTap() {
        dismissWithAnimation()
    }
    
    // MARK: Private methods
    
    fileprivate func calculateFrame() {
        let refViewFrame = presentingView.convert(presentingView.bounds, to: UIApplication.shared.keyWindow);
        
        var xOrigin: CGFloat = 0
        var yOrigin: CGFloat = 0
        
        switch arrowPosition {
        case .top:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y + refViewFrame.height
            preferences.drawing.arrowTip = CGPoint(x: refViewFrame.center.x - xOrigin, y: 0)
            bubbleFrame = CGRect(x: 0, y: preferences.drawing.arrowSize.height, width: bubbleSize.width, height: bubbleSize.height)
        case .right:
            xOrigin = refViewFrame.x - contentSize.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            preferences.drawing.arrowTip = CGPoint(x: bubbleSize.width + preferences.drawing.arrowSize.height, y: refViewFrame.center.y - yOrigin)
            bubbleFrame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .bottom:
            xOrigin = refViewFrame.center.x - contentSize.width / 2
            yOrigin = refViewFrame.y - contentSize.height
            preferences.drawing.arrowTip = CGPoint(x: refViewFrame.center.x - xOrigin, y: bubbleSize.height + preferences.drawing.arrowSize.height)
            bubbleFrame = CGRect(x: 0, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        case .left:
            xOrigin = refViewFrame.x + refViewFrame.width
            yOrigin = refViewFrame.center.y - contentSize.height / 2
            preferences.drawing.arrowTip = CGPoint(x: 0, y: refViewFrame.center.y - yOrigin)
            bubbleFrame = CGRect(x: preferences.drawing.arrowSize.height, y: 0, width: bubbleSize.width, height: bubbleSize.height)
        }
        
        let calculatedFrame = CGRect(x: xOrigin, y: yOrigin, width: contentSize.width, height: contentSize.height)
        frame = adjustFrame(calculatedFrame)
    }
    
    private func adjustFrame(_ frame: CGRect) -> CGRect {
        let bounds = UIScreen.main.bounds
        let restrictedBounds = CGRect(x: bounds.x + preferences.drawing.bubbleInset, y: bounds.y + preferences.drawing.bubbleInset, width: bounds.width - preferences.drawing.bubbleInset * 2, height: bounds.height - preferences.drawing.bubbleInset * 2)
        
        if !restrictedBounds.contains(frame) {
            var newFrame = frame
            
            if frame.x < restrictedBounds.x {
                let diff = -frame.x + preferences.drawing.bubbleInset
                newFrame.x = frame.x + diff
                if arrowPosition == .top || arrowPosition == .bottom {
                    preferences.drawing.arrowTip.x = max(preferences.drawing.arrowSize.width, preferences.drawing.arrowTip.x - diff)
                }
            }
            
            if frame.x + frame.width > restrictedBounds.x + restrictedBounds.width {
                let diff = frame.x + frame.width - restrictedBounds.x - restrictedBounds.width
                newFrame.x = frame.x - diff
                if arrowPosition == .top || arrowPosition == .bottom {
                    preferences.drawing.arrowTip.x = min(newFrame.width - preferences.drawing.arrowSize.width, preferences.drawing.arrowTip.x + diff)
                }
            }
            
            return newFrame
        }
        
        return frame
    }
    
    fileprivate func show() {
        let viewController = UIViewController()
        viewController.view.alpha = 0
        viewController.view.addSubview(self)
        
        createWindow(with: viewController)
        addTapGesture(for: viewController)
        showWithAnimation()
    }
    
    private func createWindow(with viewController: UIViewController) {
        self.containerWindow = UIWindow(frame: UIScreen.main.bounds)
        self.containerWindow!.rootViewController = viewController
        self.containerWindow!.windowLevel = UIWindowLevelAlert + 1;
        self.containerWindow!.makeKeyAndVisible()
    }
    
    private func addTapGesture(for viewController: UIViewController) {
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        viewController.view.addGestureRecognizer(tap)
    }
    
    private func showWithAnimation() {
        transform = preferences.animating.showInitialTransform
        alpha = preferences.animating.showInitialAlpha
        
        UIView.animate(withDuration: preferences.animating.showDuration, delay: 0, usingSpringWithDamping: preferences.animating.springDamping, initialSpringVelocity: preferences.animating.springVelocity, options: [.curveEaseInOut], animations: {
            self.transform = self.preferences.animating.showFinalTransform
            self.alpha = 1
            self.containerWindow?.rootViewController?.view.alpha = 1
        }, completion: { (completed) in
            self.viewDidAppear()
        })
    }
    
    private func dismissWithAnimation() {
        UIView.animate(withDuration: preferences.animating.dismissDuration, delay: 0, usingSpringWithDamping: preferences.animating.springDamping, initialSpringVelocity: preferences.animating.springVelocity, options: [.curveEaseInOut], animations: {
            self.transform = self.preferences.animating.dismissTransform
            self.alpha = self.preferences.animating.dismissFinalAlpha
            self.containerWindow?.rootViewController?.view.alpha = 0
        }) { (finished) -> Void in
            self.viewDidDisappear()
            self.removeFromSuperview()
            self.transform = CGAffineTransform.identity
            self.containerWindow?.resignKey()
            self.containerWindow = nil
        }
    }
    
    override open func draw(_ rect: CGRect) {
        let context = UIGraphicsGetCurrentContext()!
        drawBackgroundLayer()
        drawBubble(context)
        drawTexts(to: context)
    }
    
    private func viewDidAppear() {
        self.viewDidAppearDate = Date()
        self.delegate?.toolTipViewDidAppear(for: self.identifier)
    }
    
    private func viewDidDisappear() {
        let viewDidDisappearDate = Date()
        let timeInterval = viewDidDisappearDate.timeIntervalSince(self.viewDidAppearDate)
        self.delegate?.toolTipViewDidDisappear(for: self.identifier, with: timeInterval)
    }
    
    // MARK: Drawing methods
    
    private func drawBackgroundLayer() {
        if let view = self.containerWindow?.rootViewController?.view {
            let refViewFrame = presentingView.convert(presentingView.bounds, to: UIApplication.shared.keyWindow);
            let radius = refViewFrame.center.farCornerDistance()
            let frame = view.bounds
            let layer = RadialGradientBackgroundLayer(frame: frame, center: refViewFrame.center, radius: radius, locations: preferences.drawing.backgroundGradientlocations, colors: preferences.drawing.backgrounGradientColors)
            view.layer.addSublayer(layer)
        }
    }
    
    private func drawBubble(_ context: CGContext) {
        context.saveGState()
        let path = CGMutablePath()
        
        switch arrowPosition {
        case .top:
            let startingPoint = CGPoint(x: preferences.drawing.arrowTip.x - preferences.drawing.arrowSize.width / 2, y: bubbleFrame.y)
            path.move(to: startingPoint)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrowTip.x + preferences.drawing.arrowSize.width / 2, y: bubbleFrame.y))
            addArrowTipArc(with: startingPoint, to: path)
        case .right:
            let startingPoint = CGPoint(x: preferences.drawing.arrowTip.x - preferences.drawing.arrowSize.height, y: preferences.drawing.arrowTip.y - preferences.drawing.arrowSize.width / 2)
            path.move(to: startingPoint)
            addRightArc(to: path)
            addTopArc(to: path)
            addLeftArc(to: path)
            addBottomArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrowTip.x - preferences.drawing.arrowSize.height, y: preferences.drawing.arrowTip.y + preferences.drawing.arrowSize.width / 2))
            addArrowTipArc(with: startingPoint, to: path)
        case .bottom:
            let startingPoint = CGPoint(x: preferences.drawing.arrowTip.x + preferences.drawing.arrowSize.width / 2, y: bubbleFrame.y + bubbleFrame.height)
            path.move(to: startingPoint)
            addBottomArc(to: path)
            addRightArc(to: path)
            addTopArc(to: path)
            addLeftArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrowTip.x - preferences.drawing.arrowSize.width / 2, y: bubbleFrame.y + bubbleFrame.height))
            addArrowTipArc(with: startingPoint, to: path)
        case .left:
            let startingPoint = CGPoint(x: preferences.drawing.arrowTip.x + preferences.drawing.arrowSize.height, y: preferences.drawing.arrowTip.y + preferences.drawing.arrowSize.width / 2)
            path.move(to: startingPoint)
            addLeftArc(to: path)
            addBottomArc(to: path)
            addRightArc(to: path)
            addTopArc(to: path)
            path.addLine(to: CGPoint(x: preferences.drawing.arrowTip.x + preferences.drawing.arrowSize.height, y: preferences.drawing.arrowTip.y - preferences.drawing.arrowSize.width / 2))
            addArrowTipArc(with: startingPoint, to: path)
        }
        
        path.closeSubpath()
        
        context.addPath(path)
        context.clip()
        context.fillPath()
        context.drawLinearGradient(gradient, start: CGPoint.zero, end: CGPoint(x: 0, y: frame.height), options: [])
        context.restoreGState()
    }
    
    private func addTopArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x, y:  bubbleFrame.y), tangent2End: CGPoint(x: bubbleFrame.x, y: bubbleFrame.y + bubbleFrame.height), radius: preferences.drawing.bubbleCornerRadius)
    }
    
    private func addRightArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y), tangent2End: CGPoint(x: bubbleFrame.x, y: bubbleFrame.y), radius: preferences.drawing.bubbleCornerRadius)
    }
    
    private func addBottomArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y + bubbleFrame.height), tangent2End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y), radius: preferences.drawing.bubbleCornerRadius)
    }
    
    private func addLeftArc(to path: CGMutablePath) {
        path.addArc(tangent1End: CGPoint(x: bubbleFrame.x, y: bubbleFrame.y + bubbleFrame.height), tangent2End: CGPoint(x: bubbleFrame.x + bubbleFrame.width, y: bubbleFrame.y + bubbleFrame.height), radius: preferences.drawing.bubbleCornerRadius)
    }
    
    private func addArrowTipArc(with startingPoint: CGPoint, to path: CGMutablePath) {
        path.addArc(tangent1End: preferences.drawing.arrowTip, tangent2End: startingPoint, radius: preferences.drawing.arrowTipCornerRadius)
    }
    
    private func drawTexts(to context: CGContext) {
        context.saveGState()
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .left
        paragraphStyle.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        let xOrigin = bubbleFrame.x + preferences.drawing.bubbleInset
        var yOrigin = bubbleFrame.y + preferences.drawing.bubbleInset
        
        if title != nil {
            let titleRect = CGRect(x: xOrigin, y: yOrigin, width: titleSize.width, height: titleSize.height)
            title!.draw(in: titleRect, withAttributes: [NSAttributedStringKey.font : preferences.drawing.titleFont, NSAttributedStringKey.foregroundColor : preferences.drawing.titleColor, NSAttributedStringKey.paragraphStyle : paragraphStyle])
            
            yOrigin = titleRect.y + titleRect.height + preferences.drawing.bubbleSpacing
        }
        
        let messageRect = CGRect(x: xOrigin, y: yOrigin, width: messageSize.width, height: messageSize.height)
        message.draw(in: messageRect, withAttributes: [NSAttributedStringKey.font : preferences.drawing.messageFont, NSAttributedStringKey.foregroundColor : preferences.drawing.messageColor, NSAttributedStringKey.paragraphStyle : paragraphStyle])
    }
}

// MARK: RadialGradientBackgroundLayer

private class RadialGradientBackgroundLayer: CALayer {
    
    private var center: CGPoint = .zero
    private var radius: CGFloat = 0
    private var locations: [CGFloat] = [CGFloat]()
    private var colors: [UIColor] = [UIColor]()
    
    @available(*, unavailable)
    required override init(layer: Any) {
        super.init(layer: layer)
    }
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init(frame: CGRect, center: CGPoint, radius: CGFloat, locations: [CGFloat], colors: [UIColor]) {
        super.init()
        needsDisplayOnBoundsChange = true
        self.frame = frame
        self.center = center
        self.radius = radius
        self.locations = locations
        self.colors = colors
    }
    
    override func draw(in ctx: CGContext) {
        ctx.saveGState()
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let colors = self.colors.map { $0.cgColor }
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations)
        ctx.drawRadialGradient(gradient!, startCenter: center, startRadius: 0, endCenter: center, endRadius: radius, options: [])
        ctx.restoreGState()
    }
}

