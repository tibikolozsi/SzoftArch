//
//  InterractionView.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 02/10/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

public class InterractionView: UIView {
    
    var line:UIView = UIView()
    var pin:DotView
    var info:UIView = UIView()
    var infoLabel:UILabel = UILabel()
    var text:String = String() {
        didSet {
            self.infoLabel.text = text
        }
    }

    public override func drawRect(rect: CGRect)
    {
        Logger.Log(className: "InterractionView")
    }

    init(frame: CGRect, lineColor: UIColor, backgroundColor:UIColor)
    {
        Logger.Log(className: "InterractionView")
        self.pin = DotView(frame: CGRect(x: 0, y: 0, width: 15, height: 15))
        super.init(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.line = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: self.frame.height))
        self.line.backgroundColor = lineColor
        self.line.alpha = 1

        self.addSubview(self.line)

        self.addConstraint(NSLayoutConstraint(item: self.line, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 1.0, constant: 0))
        self.layoutIfNeeded()

        self.pin.color = UIColor.blueColor()
        self.pin.center.x = self.line.center.x
        self.addSubview(self.pin)
        
        self.info = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        self.info.layer.cornerRadius = 10.0
        self.info.center.x = self.line.center.x
        self.info.backgroundColor = backgroundColor
        self.infoLabel = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 20))
        infoLabel.textAlignment = NSTextAlignment.Center
        infoLabel.text = "text"
        info.addSubview(infoLabel)
        self.addSubview(self.info)
    }
    
    public required init(coder aDecoder: NSCoder) {
        Logger.Log(className: "InterractionView")
        self.pin = DotView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        super.init(coder: aDecoder)
    }

}
