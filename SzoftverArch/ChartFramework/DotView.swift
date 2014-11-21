//
//  DotView.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 28/09/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

class DotView: UIView {
    
    var color: UIColor = UIColor.whiteColor(){
        didSet{
            self.setNeedsDisplay()
        }
    }
    var value: Float = 0.0
    
    func commonInit() {
        self.backgroundColor = UIColor.clearColor()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    init(value: Float, center:CGPoint, radius:CGFloat, color:UIColor) {
        super.init(frame: CGRect(origin: CGPointZero, size: CGSize(width: radius, height: radius)))
        self.center = center
        self.value = value
        self.backgroundColor = UIColor.clearColor()
        self.color = color
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func drawRect(rect: CGRect) {
        var context = UIGraphicsGetCurrentContext()
        CGContextAddEllipseInRect(context, rect)
        self.color.set()
        self.layer.cornerRadius = 3.0
        CGContextFillPath(context)
    }
}
