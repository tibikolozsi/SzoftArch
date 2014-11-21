//
//  PieChartView.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 27/10/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

let kPieChartFontSize:CGFloat = 12.0

@objc public protocol PieChartDataSource {
    
    func numberOfSlicesInPieChart(pieChart: PieChartView) -> Int
    func valueForSlice(pieChart: PieChartView, index: Int) -> CGFloat
    
    optional func colorForSlice(pieChart: PieChartView, index: Int) -> UIColor
    optional func textForSlice(pieChar: PieChartView, index: Int) -> String
}

@objc public protocol PieChartDelegate {
    optional func pieChartWillSelectSlice(index: Int)
    optional func pieChartDidSelectSlice(index: Int)
    optional func pieChartWillDeselectSlice(index: Int)
    optional func pieChartDidDeselectSlice(index: Int)
}

public class PieChartView: UIView {
    let kDefaultSliceZOrder:CGFloat = 100.0
    public var dataSource:PieChartDataSource?
    public var delegate:PieChartDelegate?
    
    var startPieAngle:CGFloat = 0.0
    var animationTime:NSTimeInterval = 1
    var pieRadius:CGFloat!
        {
        didSet(newPieRadius) {
            let origin = self.pieView.frame.origin
            let pieCenter = self.pieView.center
            let frame = CGRect(x: origin.x + pieCenter.x - pieRadius, y: origin.y + pieCenter.y - pieRadius, width: pieRadius * 2, height: pieRadius * 2)
            self.pieView.center = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
            self.pieView.frame = frame
            self.pieView.layer.cornerRadius = pieRadius
        }
    }
    var showLabel:Bool = true
    var labelFont:UIFont = UIFont.systemFontOfSize(kPieChartFontSize)
    var labelColor:UIColor = UIColor.whiteColor()
    var labelShadowColor:UIColor?
    var labelRadius:CGFloat = 0.0
    var selectedSliceStroke:CGFloat = 3.0
    var selectedSliceOffsetRadius:CGFloat = 0.0
    var showPercentage:Bool = true {
        didSet(newShowPercentage) {
            self.showPercentage = newShowPercentage
            for layer in self.pieView.layer.sublayers {
                var layera = layer as PieSliceLayer
                var textLayer = layera.sublayers[0] as CATextLayer
                textLayer.hidden = !self.showLabel
                if (!showLabel) {
                    return
                }
                var label:String = ""
                if (self.showPercentage) {
                    label = "\(layera.percentage)"
                } else {
                    if (layera.text.isEmpty) {
                        label = "\(layera.percentage)"
                    } else {
                        label = layera.text
                    }
                }

                var size:CGSize = CGSize(width: 100, height: 20)
                if (CGFloat(M_PI) * 2.0 * self.labelRadius * layera.percentage < max(size.width, size.height)) {
                    textLayer.string = ""
                } else {
                    textLayer.string = label
                    textLayer.bounds = CGRect(origin: CGPointZero, size: size)
                }
            }
        }
    }
    
    var selectedSliceIndex:Int = -1
    var pieView:UIView!
    var animationTimer:NSTimer!
    var animations:NSMutableArray!
    
    override public var backgroundColor:UIColor? {
        didSet(newBackgroundColor) {
            if let pie = self.pieView {
                pie.backgroundColor = newBackgroundColor
            }
        }
    }
    
    
    class func createArc(center: CGPoint, radius: CGFloat, startAngle: CGFloat, endAngle: CGFloat) -> CGPathRef {
//        println("createArc startAngle: \(startAngle) endAngle: \(endAngle)")
        var path = UIBezierPath()
        path.lineWidth = 0.0
        path.moveToPoint(center)
        path.addArcWithCenter(center, radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: true)
        path.closePath()
        return path.CGPath
        
    }
    
    func initAll(frame: CGRect, center: CGPoint = CGPointZero, radius: CGFloat = 0) {
        self.pieView = UIView(frame: frame)
        self.backgroundColor = UIColor.clearColor()
        self.pieView.backgroundColor = UIColor.clearColor()
        self.addSubview(self.pieView)

        self.pieView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: nil, metrics: nil, views: ["view":self.pieView]))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: nil, metrics: nil, views: ["view":self.pieView]))
        
        self.animations = NSMutableArray()
        
        if center == CGPointZero {
            self.pieView.center = CGPoint(x: frame.size.width/2.0, y: frame.size.height/2.0)
        } else {
            self.pieView.center = center
        }
        
        if radius == 0 {
            self.pieRadius = min(frame.size.width/2.0, frame.size.height/2.0)
        } else {
            self.pieRadius = radius
        }
        
        self.labelFont = UIFont.boldSystemFontOfSize(kPieChartFontSize)
        self.labelRadius = pieRadius/2.0
        self.selectedSliceOffsetRadius = max(10, pieRadius/10)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initAll(frame)
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        self.initAll(self.bounds)
    }
    
    public func reloadData(){
        if let dataSource = self.dataSource {
            var parentLayer = pieView.layer
            var sliceLayers:Array<PieSliceLayer>
            if parentLayer.sublayers != nil {
                sliceLayers = parentLayer.sublayers as Array<PieSliceLayer>
            } else {
                sliceLayers = Array<PieSliceLayer>()
            }
            
            selectedSliceIndex = -1
            for (index, sliceLayer) in enumerate(sliceLayers) {
                if((sliceLayer as PieSliceLayer).isSelected) {
                    self.setSliceDeselected(index)
                }
            }
            
            var startToAngle:CGFloat = 0.0
            var endToAngle:CGFloat = startToAngle
            
            let sliceCount = dataSource.numberOfSlicesInPieChart(self)
            
            // Extract values from dataSource, calculate sum of values
            var sum:CGFloat = 0.0
            var values:Array<CGFloat> = Array<CGFloat>()
            for index in 0..<sliceCount {
                var value = dataSource.valueForSlice(self, index: index)
                values.append(value)
                sum += value
            }
            
            // Calculate angles from values
            var angles = Array<CGFloat>()
            for index in 0..<sliceCount {
                var div:CGFloat = 0
                if (sum == 0) {
                    div = 0
                } else {
                    div = CGFloat(values[index]) / sum
                }
                let angle = CGFloat(M_PI) * 2.0 * div
                angles.append(angle)
                println("\(index). : \(MathHelper.RadianToDegree(angle))")
            }
            
            CATransaction.begin()
            CATransaction.setAnimationDuration(animationTime)
            
            pieView.userInteractionEnabled = false
            
            
//            var layersToRemove = Array(sliceLayers)
            var layersToRemove = NSMutableArray(array:sliceLayers)
            let isOnStart = (sliceLayers.count == 0 && sliceCount > 0)
            let isOnEnd = ((sliceLayers.count > 0) && (sliceCount == 0 || sum <= 0))
                        
            var diff = sliceCount - sliceLayers.count
            if(isOnEnd) {
                for layer in pieView.layer.sublayers {
                    if let pieSliceLayer = layer as? PieSliceLayer {
                        self.updateLabel(pieSliceLayer, value: 0)
                        pieSliceLayer.createArcAnimation("startAngle", fromValue: startPieAngle, toValue: startPieAngle, delegate: self)
                        pieSliceLayer.createArcAnimation("endAngle", fromValue: startPieAngle, toValue: startPieAngle, delegate: self)
                    }
                }
                CATransaction.commit()
                return
            }
            
            for index in 0..<sliceCount {
                var layer:PieSliceLayer?
            
                var angle:CGFloat = angles[index]
                endToAngle += angle
                var startFromAngle:CGFloat = startPieAngle + startToAngle
                var endFromAngle:CGFloat = startPieAngle + endToAngle
                
                if (index >= sliceLayers.count) {
                    layer = self.createPieSliceLayer()
                    if(isOnStart) {
                        startFromAngle = startPieAngle
                        endFromAngle = startPieAngle
                    }
                    parentLayer.addSublayer(layer)
                    diff--
                } else {
                    var oneLayer:PieSliceLayer = sliceLayers[index]
                    if (diff == 0 || oneLayer.value == CGFloat(values[index])) {
                        layer = oneLayer
                        layersToRemove.removeObject(layer!)
                    } else if (diff > 0) {
                        layer = self.createPieSliceLayer()
                        parentLayer.insertSublayer(layer, atIndex: UInt32(index))
                        diff--
                    } else if (diff < 0) {
                        while(diff < 0) {
                            oneLayer.removeFromSuperlayer()
                            parentLayer.addSublayer(oneLayer)
                            diff++
                            oneLayer = sliceLayers[index]

                            if(oneLayer.value == CGFloat(values[index]) || diff == 0) {
                                layer = oneLayer;
                                layersToRemove.removeObject(layer!)
                                break;
                            }
                        }
                    }

                }
                layer!.value = values[index]
                layer!.percentage = (sum > 0) ? layer!.value / sum : 0
                var color:UIColor
                if let colorForSlice = dataSource.colorForSlice?(self, index: index) {
                    color = colorForSlice
                } else {
                    let hue = CGFloat(CGFloat((Int(index/8))%20)/20.0+0.02)
                    let saturation = CGFloat((CGFloat(Int(index)%8)+3.0)/10.0)
                    let brightness = CGFloat(91.0/100.0)
                    color = UIColor(hue:hue, saturation: saturation, brightness: brightness, alpha: 1.0)
                }
                layer?.fillColor = color.CGColor
//                layer?.strokeColor = color.CGColor
                if let text = dataSource.textForSlice?(self, index: index) {
                    layer?.text = text
                }
                self.updateLabel(layer!, value: values[index])
                layer?.createArcAnimation("startAngle", fromValue: startFromAngle, toValue: CGFloat(startToAngle)+CGFloat(startPieAngle), delegate: self)
                layer?.createArcAnimation("endAngle", fromValue: endFromAngle, toValue: CGFloat(endToAngle)+CGFloat(startPieAngle), delegate: self)
                startToAngle = endToAngle
                
            }
            CATransaction.setDisableActions(true)
            for l in (layersToRemove as Array) {
                if let layer = l as? CAShapeLayer {
                    layer.fillColor = self.backgroundColor?.CGColor;
                    layer.delegate = nil
                    layer.zPosition = 0
                    let textLayer = layer.sublayers.first as CATextLayer
                    textLayer.hidden = true
                    layer.removeFromSuperlayer()
                }
            }
            layersToRemove.removeAllObjects()
            
            for layer in pieView.layer.sublayers {
                (layer as CALayer).zPosition = kDefaultSliceZOrder
            }
            pieView.userInteractionEnabled = true
            
            CATransaction.setDisableActions(false)
            CATransaction.commit()
        }
    }
    
    // MARK: - Animation Delegate + Run Loop Timer
    
    func updateTimerFired(timer: NSTimer)
    {
        var parentLayer = pieView.layer
        var pieLayers = parentLayer.sublayers
        
        for pLayer in pieLayers {
            if let pieLayer = pLayer as? PieSliceLayer {
                
                let presentationLayerStartAngle:CGFloat = pieLayer.presentationLayer().valueForKey("startAngle") as CGFloat
                let presentationLayerEndAngle:CGFloat = pieLayer.presentationLayer().valueForKey("endAngle") as CGFloat

                let pieCenter = self.pieView.center
                println("start:\(presentationLayerStartAngle) end:\(presentationLayerEndAngle)")
                
                pieLayer.path = PieChartView.createArc(pieCenter, radius: pieRadius, startAngle: presentationLayerStartAngle, endAngle: presentationLayerEndAngle)
                
                var labelLayer = pieLayer.sublayers.first as CALayer
                var presentationLayerMidAngle = (presentationLayerEndAngle + presentationLayerStartAngle) / 2.0
                CATransaction.setDisableActions(true)
                labelLayer.position = CGPoint(x:pieCenter.x + (labelRadius * cos(presentationLayerMidAngle)), y:pieCenter.y + (labelRadius * sin(presentationLayerMidAngle)))
                CATransaction.setDisableActions(false)
            }
        }
    }

    override public func animationDidStart(anim: CAAnimation!) {
        if (animationTimer == nil) {
            var timeInterval:Float = 1.0/60.0
            animationTimer = NSTimer.scheduledTimerWithTimeInterval(Double(timeInterval), target: self, selector: Selector("updateTimerFired:"), userInfo: nil, repeats: true)
            NSRunLoop.mainRunLoop().addTimer(animationTimer, forMode: NSRunLoopCommonModes)
        }
        println(anim)
        
        animations.addObject(anim)
    }
    
    override public func animationDidStop(anim: CAAnimation!, finished flag: Bool) {
        animations.removeObject(anim)
        
        if (animations.count == 0) {
            animationTimer.invalidate()
            animationTimer = nil
        }
    }
    
    // MARK: - Touch Handing (Selection Notification)
    func getCurrentSelectedOnTouch(point: CGPoint) -> Int {
        var selectedIndex = -1 // currently nothing is selected
//        CGAffineTransform transform = CGAffineTransformIdentity
        let parentLayer = self.pieView.layer
        let pieLayers = parentLayer.sublayers
        for (index,pl) in enumerate(pieLayers) {
            if let pieLayer = pl as? PieSliceLayer {
                let path = pieLayer.path
                
                if(CGPathContainsPoint(path, nil, point, false)){
                    pieLayer.lineWidth = selectedSliceStroke
                    pieLayer.strokeColor = UIColor.whiteColor().CGColor
                    pieLayer.lineJoin = kCALineJoinBevel
                    pieLayer.zPosition = CGFloat(MAXFLOAT)
                    selectedIndex = index
                } else {
                    pieLayer.zPosition = kDefaultSliceZOrder
                    pieLayer.lineWidth = 0.0
                }
            }
        }
        return selectedIndex
    }
    
    override public func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
        self.touchesMoved(touches, withEvent: event)
    }

    override public func touchesMoved(touches: NSSet, withEvent event: UIEvent) {
        let t: AnyObject? = touches.anyObject()
        if let touch = t as? UITouch {
            let point = touch.locationInView(self.pieView)
            self.getCurrentSelectedOnTouch(point)
        }
    }
    
    override public func touchesEnded(touches: NSSet, withEvent event: UIEvent) {
        let t: AnyObject? = touches.anyObject()
        if let touch = t as? UITouch {
            let point = touch.locationInView(self.pieView)
            let selectedIndex = self.getCurrentSelectedOnTouch(point)
            self.notifyDelegateOfSelectionChange(selectedSliceIndex, newSel: selectedIndex)
            self.touchesCancelled(touches, withEvent: event)
        }
    }
    
    override public func touchesCancelled(touches: NSSet!, withEvent event: UIEvent!) {
        let parentLayer = self.pieView.layer
        let pieLayers = parentLayer.sublayers
        for pl in pieLayers {
            if let pieLayer = pl as? PieSliceLayer {
                pieLayer.zPosition = kDefaultSliceZOrder
                pieLayer.lineWidth = 0.0
            }
        }
    }
    
    // MARK: - Selection Notification
    
    func notifyDelegateOfSelectionChange(previousSel: Int, newSel: Int) {
        var previousSelection = previousSel
        var newSelection = newSel
        if (previousSelection != newSelection) {
            if (previousSelection != -1) {
                let savedPrevious = previousSelection;
                delegate?.pieChartWillDeselectSlice?(savedPrevious)
                self.setSliceDeselected(savedPrevious)
                previousSelection = newSelection
                delegate?.pieChartDidDeselectSlice?(savedPrevious)
            }
            
            if (newSelection != -1) {
                delegate?.pieChartWillSelectSlice?(newSelection)
                self.setSliceSelected(newSelection)
                selectedSliceIndex = newSelection
                delegate?.pieChartDidSelectSlice?(newSelection)
            }
        } else if (newSelection != -1) {
            let layer = pieView.layer.sublayers[newSelection] as PieSliceLayer
            if (selectedSliceOffsetRadius > 0) {
                if (layer.isSelected) {
                    delegate?.pieChartWillDeselectSlice?(newSelection)
                    self.setSliceDeselected(newSelection)
                    delegate?.pieChartDidDeselectSlice?(newSelection)
                    previousSelection = -1
                    selectedSliceIndex = -1
                } else {
                    delegate?.pieChartWillSelectSlice?(newSelection)
                    self.setSliceSelected(newSelection)
                    selectedSliceIndex = newSelection
                    previousSelection = newSelection
                    if (newSelection != -1) {
                        delegate?.pieChartDidSelectSlice?(newSelection)
                    }
                }
            }
        }
    }
    
    // MARK: - Selection Programmatically Without Notification

    func setSliceSelected(index:Int) {
        if (selectedSliceOffsetRadius <= 0) {
            return
        } else {
            var layer:PieSliceLayer = pieView.layer.sublayers[index] as PieSliceLayer
            if (!layer.isSelected) {
                var currPos = layer.position
                var middleAngle = (layer.startAngle + layer.endAngle)/2.0
                let x = currPos.x + selectedSliceOffsetRadius * CGFloat(cos(middleAngle))
                let y = currPos.y + selectedSliceOffsetRadius * CGFloat(sin(middleAngle))
                var newPosition = CGPoint(x: x, y: y)
                layer.position = newPosition
                layer.isSelected = true
                
                
            }
        }
    }

    func setSliceDeselected(index: Int) {
        if (selectedSliceOffsetRadius <= 0) {
            return
        } else {
            var layer:PieSliceLayer = pieView.layer.sublayers[index] as PieSliceLayer
            if (layer.isSelected) {
                layer.position = CGPointZero
                layer.isSelected = false
            }
        }
    }
    
    // MARK:- Pie Layer Creation Method
    func createPieSliceLayer() -> PieSliceLayer {
        var pieSliceLayer = PieSliceLayer()
        pieSliceLayer.zPosition = 0
        pieSliceLayer.strokeColor = nil
        
        var textLayer:CATextLayer = CATextLayer()
        textLayer.contentsScale = UIScreen.mainScreen().scale
        
        var font:UIFont = UIFont.systemFontOfSize(kPieChartFontSize)
        textLayer.font = font
        textLayer.fontSize = kPieChartFontSize
        textLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        textLayer.alignmentMode = kCAAlignmentCenter
        textLayer.backgroundColor = UIColor.clearColor().CGColor
        textLayer.foregroundColor = self.labelColor.CGColor
        
        if (self.labelShadowColor != nil) {
            textLayer.shadowColor = self.labelShadowColor!.CGColor
            textLayer.shadowOffset = CGSizeZero
            textLayer.shadowOpacity = 1.0
            textLayer.shadowRadius = 2.0
        }
        
        let str: String = "0"
        var size:CGSize = NSString(string: str).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(kPieChartFontSize)])
        
        CATransaction.setDisableActions(true)
        textLayer.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
        let pieCenter = self.pieView.center
        textLayer.position = CGPoint(x: pieCenter.x + (labelRadius*cos(0)), y: pieCenter.y + (labelRadius * sin(0)))
        
        CATransaction.setDisableActions(false)
        
        pieSliceLayer.addSublayer(textLayer)
        return pieSliceLayer
    }

    func updateLabel(pieSliceLayer: PieSliceLayer, value: CGFloat) {
        var textLayer:CATextLayer = pieSliceLayer.sublayers[0] as CATextLayer
        textLayer.hidden = !showLabel
        if (!showLabel) {
            return
        }
        var label:String
        let doubleToWrite = Double(pieSliceLayer.percentage*100.0)
        if (showPercentage) {
            label = String(format: "%.2f%", doubleToWrite) + "%"
        } else {
            label = pieSliceLayer.text.isEmpty ? String(format: "%.2f", doubleToWrite) + "%" : pieSliceLayer.text
        }
        var size:CGSize = NSString(string: label).sizeWithAttributes([NSFontAttributeName : UIFont.systemFontOfSize(kPieChartFontSize)])
        
        CATransaction.setDisableActions(true)
        if (value <= 0.0 || (CGFloat(M_PI) * 2.0 * labelRadius * pieSliceLayer.percentage < max(size.width,size.height))) {
            textLayer.string = ""
        } else {
            textLayer.string = label
            textLayer.bounds = CGRect(origin: CGPointZero, size: size)
        }
        
        CATransaction.setDisableActions(false)
    }
    
}
