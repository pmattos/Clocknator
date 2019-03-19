//
//  ClocknatorView.swift
//  Clocknator
//
//  Created by Paulo Mattos on 18/03/19.
//  Copyright © 2019 Paulo Mattos. All rights reserved.
//

import UIKit
import CoreGraphics

final class ClocknatorView: UIView, CAAnimationDelegate {

    // MARK: - View Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initView()
    }
    
    private func initView() {
        isUserInteractionEnabled = false
        setUpLayers()
    }

    // MARK: - View Properties
    
    var circleColor = UIColor(white: 0.95, alpha: 1.0)
    
    // MARK: - View Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setUpLayers()
    }
    
    // MARK: - Vectornator Color Palette

    private let black      = UIColor.black.cgColor
    private let white      = UIColor.white.cgColor
    private let yellow     = UIColor(red: 254, green: 221, blue:  51).cgColor
    private let red        = UIColor(red: 252, green:  23, blue: 112).cgColor
    private let cyan       = UIColor(red:  46, green: 238, blue: 226).cgColor
    private let magenta    = UIColor(red: 236, green:  41, blue: 226).cgColor
    private let darkYellow = UIColor(red: 193, green: 182, blue:  40).cgColor

    // MARK: - Clock Layers

    private var oldBounds: CGRect? = nil
    private var unitTransform = CGAffineTransform()

    private let clockBackgroundLayer = CAShapeLayer()

    private let radius: CGFloat = 0.41
    private let animationSpeed: CFTimeInterval = 7
    
    // Vector color

    private func setUpLayers() {
        guard bounds != oldBounds else { return }
        oldBounds = bounds
        
        setUpLayersHierarchy()
        setUpClockBackgroundLayer()
        setUpCenterCircleLayer()
        setUpSecondsLayer()
        setUpMinutesLayer()
    }
    
    private func setUpLayersHierarchy() {
        // For simplicity, *all* sublayers are represented in right-handed,
        // 1.0 x 1.0 unit coordinates system with a centered origin:
        //
        //    -------------------------
        //    |         ⬆︎ y           |
        //    |         ┃             |
        //    |         ┃             |
        //    |         ┃          x  |
        //    |         ┃𑁋𑁋𑁋𑁋𑁋𑁋➜  |
        //    |                        |
        //    |                        |
        //    |                        |
        //     -------------------------
        //
        let size: CGFloat
        let offset: CGVector
        if bounds.width >= bounds.height {
            size = bounds.height
            offset = CGVector(dx: (bounds.width - size) / 2, dy: 0)
        } else {
            size = bounds.width
            offset = CGVector(dx: 0, dy: (bounds.height - size) / 2)
        }
        print("Clock size (points): \(size) x \(size)")
        
        unitTransform = CGAffineTransform.identity
        unitTransform = unitTransform.scaledBy(x: size, y: size)
        unitTransform = unitTransform.translatedBy(x: 0.5, y: 0.5)
        unitTransform = unitTransform.scaledBy(x: 1.0, y: -1.0)
        
        layer.bounds = bounds
        layer.backgroundColor = nil
        //layer.backgroundColor = UIColor(white: 0.95, alpha: 1).cgColor
        
        let sublayerFrame = CGRect(x: offset.dx, y: offset.dy, width: size, height: size)
        
        clockBackgroundLayer.frame = sublayerFrame
        layer.removeAllSublayers()
        layer.addSublayer(clockBackgroundLayer)
    }
    
    private func setUpClockBackgroundLayer() {
        clockBackgroundLayer.removeAllSublayers()
        clockBackgroundLayer.strokeColor = UIColor(white: 0.5, alpha: 1).cgColor
        clockBackgroundLayer.fillColor = nil
        clockBackgroundLayer.lineWidth = 2.5
        clockBackgroundLayer.backgroundColor = nil
        clockBackgroundLayer.path = clockBorderWithNotchPath()

        let maskLayer = CAShapeLayer()
        maskLayer.strokeColor = nil
        maskLayer.fillColor = UIColor.black.cgColor
        maskLayer.backgroundColor = nil
        maskLayer.path = clockBorderWithNotchPath()

        let radialGradientLayer = CAGradientLayer()
        radialGradientLayer.colors = [cyan, magenta]
        radialGradientLayer.locations = [0.0, 1.0]
        radialGradientLayer.type = .radial
        radialGradientLayer.frame = clockBackgroundLayer.bounds
        radialGradientLayer.mask = maskLayer
        radialGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        radialGradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        
        clockBackgroundLayer.addSublayer(radialGradientLayer)
        rotate(layer: clockBackgroundLayer, duration: 60)
    }
    
    private func setUpSecondsLayer() {
        let secondsPointerLayer = CAShapeLayer()
        secondsPointerLayer.strokeColor = nil
        secondsPointerLayer.fillColor = red
        secondsPointerLayer.backgroundColor = nil
        secondsPointerLayer.frame = clockBackgroundLayer.bounds
        secondsPointerLayer.path = secondsArrowPath()
        secondsPointerLayer.shadowOpacity = 0.5
        secondsPointerLayer.shadowOffset = CGSize(width: 0, height: 2.5)
        
        clockBackgroundLayer.addSublayer(secondsPointerLayer)
    }

    private func setUpMinutesLayer() {
        let minutesPointerLayer = CAShapeLayer()
        minutesPointerLayer.strokeColor = red
        minutesPointerLayer.fillColor = yellow
        minutesPointerLayer.lineWidth = 1.5
        minutesPointerLayer.backgroundColor = nil
        minutesPointerLayer.frame = clockBackgroundLayer.frame
        minutesPointerLayer.path = minutesArrowPath()
        minutesPointerLayer.shadowOpacity = 0.5
        minutesPointerLayer.shadowOffset = CGSize(width: 0, height: 4.5)

        let maskLayer = CAShapeLayer()
        maskLayer.strokeColor = nil
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.backgroundColor = nil
        maskLayer.path = minutesArrowPath()

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [yellow, red]
        gradientLayer.type = .axial
        gradientLayer.frame = minutesPointerLayer.bounds
        gradientLayer.mask = maskLayer
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.78, y: 0.5)

        layer.addSublayer(minutesPointerLayer)
        minutesPointerLayer.addSublayer(gradientLayer)
        rotate(layer: minutesPointerLayer, duration: 200)
    }

    private func setUpCenterCircleLayer() {
        let centerCircleLayer = CAShapeLayer()
        centerCircleLayer.strokeColor = magenta
        centerCircleLayer.fillColor = darkYellow
        centerCircleLayer.backgroundColor = nil
        centerCircleLayer.frame = clockBackgroundLayer.bounds
        clockBackgroundLayer.addSublayer(centerCircleLayer)

        let path = CGMutablePath()
        path.addArc(
            center: .zero,
            radius: 0.020,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true,
            transform: unitTransform
        )
        centerCircleLayer.path = path
    }

    private func clockBorderWithNotchPath() -> CGPath {
        let path = CGMutablePath()
        let halfGap: CGFloat = 0.06 * CGFloat.pi
        
        path.addArc(
            center: .zero,
            radius: radius,
            startAngle: -halfGap,
            endAngle:   +halfGap,
            clockwise: true,
            transform: unitTransform
        )
        
        // We need to compute proper tangent vectors to ensure C0 and C1 continuity.
        // Also need to use tiny tangents otherwise the bezier curve goes crazy ;)

        let tanLen: CGFloat = 0.05

        let pos0 = CGPoint(angle: +halfGap, length: radius)
        let tan0 = CGVector(angle: +halfGap, length: tanLen).perp
        
        let pos1 = CGPoint(x: radius + 0.075, y: 0)
        let tan1 = CGVector(dx: 0, dy: -tanLen)
        
        let tan2 = CGVector(angle: -halfGap, length: tanLen).perp
        let pos2 = CGPoint(angle: -halfGap, length: radius)
        
        path.addCurve(
            to: pos1,
            control1: pos0 + tan0,
            control2: pos1 - tan1,
            transform: unitTransform
        )
        path.addCurve(
            to: pos2,
            control1: pos1 + tan1,
            control2: pos2 - tan2,
            transform: unitTransform
        )
        
        return path
    }

    private func secondsArrowPath() -> CGPath {
        let height: CGFloat = 0.01
        let tail: CGFloat = 0.03
        let len: CGFloat = radius + 0.048
        
        let path = CGMutablePath()
        
        path.addRoundedRect(
            in: CGRect(
                x: -tail , y: -height/2,
                width: len + tail, height: height
            ),
            cornerWidth: 0.15,
            cornerHeight: 0.002,
            transform: unitTransform
        )
        
        path.addArc(
            center: .zero,
            radius: 0.02,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true,
            transform: unitTransform
        )
        
        return path
    }

    private func minutesArrowPath() -> CGPath {
        let height: CGFloat = 0.05
        let tail: CGFloat = 0.05
        let len: CGFloat = radius - 0.1
        
        let path = CGMutablePath()
        
        path.addRoundedRect(
            in: CGRect(
                x: -tail , y: -height/2,
                width: len + tail, height: height
            ),
            cornerWidth: 0.15,
            cornerHeight: 0.02,
            transform: unitTransform
        )
        
        return path
    }

    private func rotate(layer: CALayer, duration: CFTimeInterval) {
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = -0.5 * CGFloat.pi
        rotateAnimation.toValue = 1.5 * CGFloat.pi
        rotateAnimation.duration = duration / animationSpeed
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        
        layer.removeAllAnimations()
        layer.add(rotateAnimation, forKey: "rotate")
    }
    
    
    // MARK: - Helpers
    
    private func printCurrentPoint(of path: CGPath) {
        print("currentPoint: \(path.currentPoint)")
    }
}

extension CALayer {
    
    func removeAllSublayers() {
        guard let sublayers = self.sublayers else { return }
        for sublayer in sublayers {
            sublayer.removeFromSuperlayer()
        }
    }
}
