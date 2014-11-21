//
//  PSColor.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 01/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

public class PSColor: UIColor {
    public init(r:Int, g:Int, b:Int, a:CGFloat) {
        super.init(red: CGFloat(CGFloat(r)/255.0), green: CGFloat(CGFloat(g)/255.0), blue: CGFloat(CGFloat(b)/255.0), alpha: CGFloat(a))
    }
    required public init(coder aDecoder: NSCoder) {
        super.init()
    }
}
