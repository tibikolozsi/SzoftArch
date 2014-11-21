//
//  SliceData.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 01/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

let kSliceDataDefaultColor = UIColor.blackColor()
public class SliceData: NSObject {
    public var value:CGFloat = -1;
    public var text:String = ""
    public var color:UIColor = UIColor.clearColor()
    
    public init(value: CGFloat, text: String = "", color: UIColor = kSliceDataDefaultColor) {
        super.init()
        self.value = value
        self.text = text
        self.color = color
    }
   
}
