//
//  LinePoint.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 03/10/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

class LinePoint {
    let value:Float // actual value of the point
    let position:CGPoint // position of the point
    let text:String // text of the point 
    
    init(value:Float, position:CGPoint, text:String = "label") {
        self.value = value
        self.position = position
        self.text = text
    }
    
}
