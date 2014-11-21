//
//  MathHelper.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 01/11/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

class MathHelper: NSObject {
    class func RadianToDegree(radian: CGFloat) -> CGFloat {
        return radian * (180.0 / CGFloat(M_PI))
    }
    
    class func DegreeToRadian(degree: CGFloat) -> CGFloat {
        return degree * (CGFloat(M_PI)/180.0)
    }
   
}
