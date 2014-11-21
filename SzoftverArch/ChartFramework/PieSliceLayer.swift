//
//  PieSliceLayer.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 27/10/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

public class PieSliceLayer: CAShapeLayer {

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var value:CGFloat = 0.0
    var percentage:CGFloat = 0.0
    public var startAngle:CGFloat = 0.0
    public var endAngle:CGFloat = 0.0 
    var isSelected:Bool = false
    var text:String = ""
    
    override init!() {
        super.init()
    }
    
    override init!(layer: AnyObject!) {
        super.init(layer: layer)
        if (layer.isKindOfClass(PieSliceLayer)) {
            self.startAngle = layer.startAngle
            self.endAngle = layer.endAngle
        }
    }
    
    override public var description: String {
        let startDegree:Int = Int(startAngle/CGFloat(M_PI)*180.0)
        let endDegree:Int = Int(endAngle/CGFloat(M_PI)*180.0)
        return "value:\(value), percentage:\(percentage), start:\(startDegree), end:\(endDegree)"
    }

    override public class func needsDisplayForKey(key: String!) -> Bool{
        if key == "startAngle" || key == "endAngle" {
            return true;
        } else {
            return super.needsDisplayForKey(key)
        }
    }
    
    func createArcAnimation(key: String, fromValue: NSNumber, toValue: NSNumber, delegate: AnyObject) {
        var arcAnimation:CABasicAnimation = CABasicAnimation(keyPath: key)
        
        var currentAngle:AnyObject
        if (self.presentationLayer()?.valueForKey(key) != nil) {
            currentAngle = self.presentationLayer().valueForKey(key)!
        } else {
            currentAngle = fromValue
        }
        
        arcAnimation.fromValue = currentAngle
        arcAnimation.toValue = toValue
        
//        println("from: \(fromValue) current: \(currentAngle) to: \(toValue)")
        arcAnimation.delegate = delegate
        arcAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
        self.addAnimation(arcAnimation, forKey: key)

//        println()
//        println("beforeSet : \(endAngle)")
        self.setValue(toValue, forKey: key)
//        println("afterSet : \(endAngle)")
    }
}
