//
//  Line.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 03/10/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

public enum LineType {
    case LineTypeSimple
    case LineTypeSpline
}

class Line {
    var points:Array<LinePoint>! {
        didSet {
            calculateLinePath(type:self.lineType)
        }
    }
    var path:UIBezierPath!
    var lineType:LineType = LineType.LineTypeSimple
    
    init() {
        self.points = Array<LinePoint>()
        self.path = UIBezierPath()
    }
    
    init(points: Array<LinePoint>, type:LineType = LineType.LineTypeSimple){
        self.points = points
        self.path = UIBezierPath()
        self.lineType = type

        calculateLinePath(type: type)
    }
    
    func calculateLinePath(type:LineType = LineType.LineTypeSimple) {
        if self.points.count < 2 {
            return
        }
        
        self.path.moveToPoint(points.first!.position)
        
        if self.lineType == LineType.LineTypeSpline {
            var modPoints = self.points
            modPoints.insert(points.first!, atIndex: 0)
            modPoints.insert(points.last!, atIndex: points.count)
            
            for (index,point) in enumerate(modPoints) {
                if (index >= 1 && index < modPoints.count - 2) {
                    var currentPoint:CGPoint = point.position
                    var nextPoint:CGPoint = modPoints[index+1].position
                    var secondNextPoint:CGPoint = modPoints[index+2].position
                    var previousPoint:CGPoint = modPoints[index-1].position
                    
                    if index == 1 {
                        previousPoint = CGPoint(x: currentPoint.x-(nextPoint.x-currentPoint.x), y: nextPoint.y)
                    }
                    if index == modPoints.count - 3 {
                        var diff:CGFloat = currentPoint.x-previousPoint.x
                        nextPoint = CGPoint(x: currentPoint.x+diff, y: nextPoint.y)
                        secondNextPoint = CGPoint(x: currentPoint.x + diff * 2.0, y:nextPoint.y)
                    }
                    
                    
                    var d1 = (currentPoint - previousPoint).length()
                    var d2 = (nextPoint - currentPoint).length()
                    var d3 = (secondNextPoint - nextPoint).length()
                    
                    let falpha:Float = Float(0.5)
                    var b1:CGPoint =  powf(Float(d1), Float(2.0)*falpha)*nextPoint
                    b1 = b1 - powf(Float(d2), Float(2.0)*falpha) * previousPoint
                    let part1:Float = 2.0 * powf(Float(d1), Float(2.0)*falpha)
                    let part2:Float = Float(3.0)*powf(Float(d1), falpha)*powf(Float(d2), falpha)
                    let part3:Float = powf(Float(d2), 2.0*falpha)
                    b1 = b1 + ( part1 +  part2 + part3) * currentPoint
                    b1 = (1.0 / (3.0*powf(Float(d1), falpha)*(powf(Float(d1), falpha)+powf(Float(d2), falpha)))) * b1
                    
                    var b2 = powf(Float(d3), 2.0*falpha) * currentPoint
                    b2 = b2 - powf(Float(d2), 2.0*falpha) * secondNextPoint
                    b2 = b2 + (2.0*powf(Float(d3), 2.0*falpha) + 3.0*powf(Float(d3), falpha)*powf(Float(d2), falpha) + powf(Float(d2), 2.0*falpha)) * nextPoint
                    b2 = (1.0 / (3.0*powf(Float(d3), falpha)*(powf(Float(d3), falpha)+powf(Float(d2), falpha)))) * b2
                    
                    self.path.addCurveToPoint(nextPoint, controlPoint1: b1, controlPoint2: b2)
                }
            }
        } else {
            for point in self.points {
                self.path.addLineToPoint(point.position)
            }
        }
    }
    

}

extension CGPoint {
    func length() -> CGFloat {
        return sqrt(self * self)
    }
}

public func -(lhs: CGPoint, rhs:CGPoint) -> CGPoint {
    return CGPoint(x:lhs.x-rhs.x,y:lhs.y-rhs.y)
}

public func +(left: CGPoint, right:CGPoint) -> CGPoint {
    return CGPoint(x:left.x+right.x,y:left.y+right.y)
}

public func *(left: CGPoint, right:CGPoint) -> CGFloat {
    return CGFloat(left.x * right.x + left.y * right.y)
}

public func *(lhs: CGFloat, rhs:CGPoint) -> CGPoint {
    return CGPoint(x:lhs * rhs.x,y: lhs * rhs.y)
}
public func *(lhs: Float, rhs:CGPoint) -> CGPoint {
    return CGPoint(x:CGFloat(lhs) * rhs.x,y: CGFloat(lhs) * rhs.y)
}
