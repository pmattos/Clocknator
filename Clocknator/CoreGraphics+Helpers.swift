//
//  CoreGraphics+Helpers.swift
//  Clocknator
//
//  Created by Paulo Mattos on 18/03/19.
//  Copyright © 2019 Paulo Mattos. All rights reserved.
//

import CoreGraphics

extension CGPoint {

    /// Point from polar coordinates.
    init(angle: CGFloat, length: CGFloat) {
        self.init()
        self.x = length * cos(angle)
        self.y = length * sin(angle)
    }
}

extension CGVector {
    
    /// Vector from polar coordinates.
    init(angle: CGFloat, length: CGFloat) {
        self.init()
        self.dx = length * cos(angle)
        self.dy = length * sin(angle)
    }
    
    var length: CGFloat {
        return sqrt(dx*dx + dy*dy)
    }
    
    var normalized: CGVector {
        let length = self.length
        return CGVector(dx: dx/length, dy: dy/length)
    }
    
    var perp: CGVector {
        return CGVector(dx: dy, dy: -dx)
    }
    
    var pos: CGPoint {
        return CGPoint(x: dx, y: dy)
    }
}

func + (left: CGPoint, right: CGPoint) -> CGPoint {
    return CGPoint(x: left.x + right.x, y: left.y + right.y)
}

func + (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x + right.dx, y: left.y + right.dy)
}

func - (left: CGPoint, right: CGVector) -> CGPoint {
    return CGPoint(x: left.x - right.dx, y: left.y - right.dy)
}

func + (left: CGVector, right: CGVector) -> CGVector {
    return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
}

func - (left: CGPoint, right: CGPoint) -> CGVector {
    return CGVector(dx: left.x - right.x, dy: left.y - right.y)
}

func * (scalar: CGFloat, pt: CGPoint) -> CGPoint {
    return CGPoint(x: scalar*pt.x, y: scalar*pt.y)
}

func * (scalar: CGFloat, vec: CGVector) -> CGVector {
    return CGVector(dx: scalar*vec.dx, dy: scalar*vec.dy)
}

func / (vec: CGVector, scalar: CGFloat) -> CGVector {
    return CGVector(dx: vec.dx/scalar, dy: vec.dy/scalar)
}

func / (point: CGPoint, scalar: CGFloat) -> CGPoint {
    return CGPoint(x: point.x/scalar, y: point.y/scalar)
}

prefix func - (vec: CGVector) -> CGVector {
    return CGVector(dx: -vec.dx, dy: -vec.dy)
}

extension CGRect {
    
    var center: CGPoint {
        return CGPoint(x: origin.x + width/2, y: origin.y + height/2)
    }
}
