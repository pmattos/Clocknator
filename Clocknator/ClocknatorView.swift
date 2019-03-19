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
    
    var time = Date() {
        didSet {
            setClockTime()
        }
    }
    
    private func setClockTime() {
        let calendar = Calendar.current
        
        let hour = calendar.component(.hour, from: time) % 12
        let minutes = calendar.component(.minute, from: time)
        let seconds = calendar.component(.second, from: time)
        
        setPointerTime(
            for: clockBackgroundLayer,
            progress: CGFloat(seconds) / 60,
            duration: 60
        )
        setPointerTime(
            for: clockMinutesLayer,
            progress: CGFloat(minutes) / 60,
            duration: 60*60
        )
        setPointerTime(
            for: clockHoursLayer,
            progress: CGFloat(hour) / 12,
            duration: 12*60*60
        )

        print("Clock time updated to \(hour):\(minutes):\(seconds)")
    }
    
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
    private var clockTransform = CGAffineTransform()

    private let clockBackgroundLayer = CAShapeLayer()
    private let clockSecondsLayer = CAShapeLayer()
    private let clockMinutesLayer = CAShapeLayer()
    private let clockHoursLayer = CAShapeLayer()

    private let radius: CGFloat = 0.41
    private let animationSpeed: TimeInterval = 1
    
    // Vector color

    private func setUpLayers() {
        guard bounds != oldBounds else { return }
        oldBounds = bounds
        
        setUpLayersHierarchy()
        setUpClockBackgroundLayer()
        setUpClockMarkersLayer()
        setUpClockCenterCircleLayer()
        setUpClockSecondsLayer()
        setUpClockMinutesLayer()
        setUpClockHoursLayer()
        
        setClockTime()
    }
    
    private func setUpLayersHierarchy() {
        // For simplicity, *all* sublayers are represented in right-handed,
        // 1x1 unit coordinates system with a centered origin:
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
        
        clockTransform = CGAffineTransform.identity
        clockTransform = clockTransform.scaledBy(x: size, y: size)
        clockTransform = clockTransform.translatedBy(x: 0.5, y: 0.5)
        clockTransform = clockTransform.scaledBy(x: 1.0, y: -1.0)
        
        layer.bounds = bounds
        layer.backgroundColor = nil
        
        let clockFrame = CGRect(x: offset.dx, y: offset.dy, width: size, height: size)
        clockBackgroundLayer.frame = clockFrame
        
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
    }
    
    private func setUpClockSecondsLayer() {
        clockSecondsLayer.removeAllSublayers()
        clockSecondsLayer.strokeColor = nil
        clockSecondsLayer.fillColor = red
        clockSecondsLayer.backgroundColor = nil
        clockSecondsLayer.frame = clockBackgroundLayer.bounds
        clockSecondsLayer.path = secondsArrowPath()
        clockSecondsLayer.shadowOpacity = 0.5
        clockSecondsLayer.shadowOffset = CGSize(width: 0, height: 2.5)
        
        clockBackgroundLayer.addSublayer(clockSecondsLayer)
    }
    
    private func setUpClockMinutesLayer() {
        setUpClockPointerLayer(clockMinutesLayer, len: radius - 0.09)
    }

    private func setUpClockHoursLayer() {
        setUpClockPointerLayer(clockHoursLayer, len: radius - 0.20)
    }

    private func setUpClockPointerLayer(_ pointerLayer: CAShapeLayer, len: CGFloat) {
        pointerLayer.removeAllSublayers()
        pointerLayer.strokeColor = red
        pointerLayer.fillColor = yellow
        pointerLayer.lineWidth = 1.5
        pointerLayer.backgroundColor = nil
        pointerLayer.frame = clockBackgroundLayer.frame
        pointerLayer.path = clockPointerPath(len: len)
        pointerLayer.shadowOpacity = 0.5
        pointerLayer.shadowOffset = CGSize(width: 0, height: 5.5)

        let maskLayer = CAShapeLayer()
        maskLayer.strokeColor = nil
        maskLayer.fillColor = UIColor.white.cgColor
        maskLayer.backgroundColor = nil
        maskLayer.path = clockPointerPath(len: len)

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [yellow, red]
        gradientLayer.type = .axial
        gradientLayer.frame = pointerLayer.bounds
        gradientLayer.mask = maskLayer
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.85, y: 0.5)
        
        layer.addSublayer(pointerLayer)
        pointerLayer.addSublayer(gradientLayer)
    }
    
    private func setUpClockMarkersLayer() {
        let markersLayer = CAShapeLayer()
        markersLayer.strokeColor = nil
        markersLayer.fillColor = white
        markersLayer.opacity = 0.2
        markersLayer.backgroundColor = nil
        
        let angularGap = 2 * CGFloat.pi / 12
        let markersPath = CGMutablePath()
        
        for marker in 0..<12 {
            let center = CGPoint(angle: CGFloat(marker) * angularGap, length: 1)
            if marker % 3 == 0 {
                markersPath.addPath(circlePath(at: 0.34 * center, radius: 0.04))
            } else {
                markersPath.addPath(circlePath(at: 0.36 * center, radius: 0.015))
            }
        }
        markersLayer.path = markersPath

        markersLayer.frame = clockBackgroundLayer.frame
        layer.addSublayer(markersLayer)
    }

    private func setUpClockCenterCircleLayer() {
        let centerCircleLayer = CAShapeLayer()
        centerCircleLayer.strokeColor = magenta
        centerCircleLayer.fillColor = darkYellow
        centerCircleLayer.backgroundColor = nil
        centerCircleLayer.path = circlePath(at: .zero, radius: 0.020)
        
        centerCircleLayer.frame = clockBackgroundLayer.bounds
        clockBackgroundLayer.addSublayer(centerCircleLayer)
    }
    
    private func circlePath(at center: CGPoint, radius: CGFloat) -> CGPath {
        let circlePath = CGMutablePath()

        circlePath.addArc(
            center: center,
            radius: radius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true,
            transform: clockTransform
        )
        
        return circlePath
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
            transform: clockTransform
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
            transform: clockTransform
        )
        path.addCurve(
            to: pos2,
            control1: pos1 + tan1,
            control2: pos2 - tan2,
            transform: clockTransform
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
            transform: clockTransform
        )
        
        path.addArc(
            center: .zero,
            radius: 0.02,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true,
            transform: clockTransform
        )
        
        return path
    }

    private func clockPointerPath(len: CGFloat) -> CGPath {
        let height: CGFloat = 0.04
        let tail: CGFloat = 0.05
        
        let path = CGMutablePath()
        
        // Pointer body.
        path.addRoundedRect(
            in: CGRect(
                x: -tail , y: -height/2,
                width: len + tail, height: height
            ),
            cornerWidth: 0.10 * len,
            cornerHeight: 0.02,
            transform: clockTransform
        )
        
        // Pointer head.
        path.addPath(clockPointerHeadPath(tx: len - 0.07))
        
        return path
    }

    private func clockPointerHeadPath(tx: CGFloat) -> CGPath {
        let head: CGFloat = 0.11
        let tail: CGFloat = 0.05
        let height: CGFloat = 0.04
        let headHeight: CGFloat = 0.006

        let pathTransform = clockTransform.translatedBy(x: tx, y: 0)
        
        let path = CGMutablePath()
        
        path.move(to: CGPoint(x: -tail, y: 0), transform: pathTransform)
        path.addLine(to: CGPoint(x: 0, y: -height), transform: pathTransform)
        path.addLine(to: CGPoint(x: +head, y: -headHeight), transform: pathTransform)
        path.addLine(to: CGPoint(x: +head, y: +headHeight), transform: pathTransform)
        path.addLine(to: CGPoint(x: 0, y: +height), transform: pathTransform)
        path.closeSubpath()
        
        return path
    }
    
    private func setPointerTime(for pointerLayer: CALayer,
                                progress: CGFloat,
                                duration: TimeInterval) {
        precondition(progress >= 0 && progress <= 1)
        
        let startAngle = (2*progress - 0.5) * CGFloat.pi
        let endAngle = startAngle + 2 * CGFloat.pi
        
        let rotateAnimation = CABasicAnimation(keyPath: "transform.rotation")
        rotateAnimation.fromValue = startAngle
        rotateAnimation.toValue = endAngle
        rotateAnimation.duration = CFTimeInterval(duration / animationSpeed)
        rotateAnimation.repeatCount = .greatestFiniteMagnitude
        
        pointerLayer.removeAllAnimations()
        pointerLayer.add(rotateAnimation, forKey: "rotate")
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
