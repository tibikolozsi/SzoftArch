//
//  LineChartView.swift
//  ChartApp
//
//  Created by Tibi Kolozsi on 28/09/14.
//  Copyright (c) 2014 tibikolozsi. All rights reserved.
//

import UIKit

enum LineViewAnimationType {
    case LineViewAnimationTypeDraw
    case LineViewAnimationTypeFade
    case LineViewAnimationTypeNone
}

let kDefaultNumberOfItems = 10;
let kDefaultStep:CGFloat = 320.0/CGFloat(kDefaultNumberOfItems);
let kDefaultArrayOfPoints:Array<CGPoint> = [CGPoint(x:10.0, y:100),
    CGPoint(x:1.0*kDefaultStep, y: 300),
    CGPoint(x:2.0*kDefaultStep, y: 40),
    CGPoint(x:3.0*kDefaultStep, y: 120),
    CGPoint(x:4.0*kDefaultStep, y: 230),
    CGPoint(x:5.0*kDefaultStep , y: 200),
    CGPoint(x:6.0*kDefaultStep , y: 100),
    CGPoint(x:7.0*kDefaultStep , y: 20),
    CGPoint(x:8.0*kDefaultStep , y: 150),
    CGPoint(x:9.0*kDefaultStep , y: 300)];



@objc public protocol LineChartDataSource {
    
    func lineChartNumberOfData(lineChart: LineChartView) -> Int
    func lineChartValueForData(linechart: LineChartView, index: Int) -> Float
    
    optional func lineChartDotColorForData(lineChart: LineChartView, index: Int) -> UIColor
    optional func lineChartDotSizeForData(lineChart: LineChartView, index: Int) -> CGFloat
    optional func lineChartTextForData(lineChart: LineChartView, index: Int) -> String
}

@objc public protocol LineChartDelegate {
    optional func lineChartWillSelectData(index: Int)
    optional func lineChartDidSelectData(index: Int)
    optional func lineChartWillDeselectData(index: Int)
    optional func lineChartDidDeselectData(index: Int)
}


//@IBDesignable
public class LineChartView: UIView, UIGestureRecognizerDelegate{
    // MARK: Inspectable properties
    
    public var dataSource:LineChartDataSource?
    public var delegate:LineChartDelegate?
    
    // graph line related properties
    @IBInspectable var lineAlpha: CGFloat = 1.0
    @IBInspectable var lineColor: UIColor = UIColor.redColor()
    @IBInspectable var lineWidth:CGFloat = 1.0
    
    // reference lines related properties
    @IBInspectable var enableReferenceLine: Bool = true
    @IBInspectable var referenceLineColor = UIColor.blackColor()
    
    // animation related properties
    @IBInspectable var animationType: LineViewAnimationType = LineViewAnimationType.LineViewAnimationTypeDraw
    @IBInspectable var animationTime: CGFloat = 0
    
    // default dot related properties
    @IBInspectable var dotSize:CGFloat = 5.0
    @IBInspectable var dotColor:UIColor = UIColor.whiteColor()
    
    // gradient colors
    @IBInspectable var gradientBackgroundColor:UIColor = UIColor.whiteColor()
    @IBInspectable var gradientHighlightedBackgroundColor:UIColor = UIColor.greenColor()
    
    // axis label steps
    @IBInspectable  var axisLabelDiff:Int = 2
    
    
    // views
    var lineView:UIView!
    var horizontalLabelsView:UIView!
    var verticalLabelsView:UIView!
    
    var verticalLabels:Array<UILabel>!
    var horizontalLabels:Array<UILabel>!
    
    var lineLayer:CALayer = CALayer()
    var fillToBottom = CAShapeLayer()
    var fillToBottomHighlighted = CAShapeLayer()
    
    
    // Line when touching
    var touchLineLeft: InterractionView?
    var touchLineRight: InterractionView?
    @IBInspectable var touchLineLineColor: UIColor = UIColor.whiteColor()
    @IBInspectable var touchLineBackgroundColor: UIColor = UIColor.grayColor()
    @IBInspectable var touchLineWidth: CGFloat = 1.0
    
    // Gesture recognizers
    var tapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    var panGestureRecognizer: UIPanGestureRecognizer = UIPanGestureRecognizer()
    var doubleTapGestureRecognizer: UITapGestureRecognizer = UITapGestureRecognizer()
    var pinchGestureRecognizer: UIPinchGestureRecognizer = UIPinchGestureRecognizer()
    
    var values: Array<Float> = []
//        {
//        didSet {
//            refreshPoints()
//        }
//    }
    
    var dots:Array<DotView> = Array<DotView>()
    
    var maxValue:Float = 0.0
    var minValue:Float = 0.0
    
    var line:Line = Line()
    var points:Array<LinePoint> = Array<LinePoint>()
    
    public var lineType:LineType = LineType.LineTypeSpline {
        didSet {
            self.line.lineType = self.lineType
            self.setNeedsDisplay()
        }
    }
    
    // MARK: init methods
    
    required override public init(frame: CGRect) {
        super.init(frame: frame)
        self.initAll()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.initAll()
    }
    
    func addView() {
        // new view for storing the line
        self.lineView = UIView()
        self.lineView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(self.lineView)
        
        // views for storing horizontal and vertical labels
        self.verticalLabelsView = UIView()
        self.verticalLabelsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(self.verticalLabelsView)
        self.verticalLabelsView.backgroundColor = UIColor.clearColor()
        
        self.horizontalLabelsView = UIView()
        self.horizontalLabelsView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.addSubview(self.horizontalLabelsView)
        self.horizontalLabelsView.backgroundColor = UIColor.clearColor()
        
        // autolayout constraint for positioning the views
        let metrics = ["lHeight" : 20.0, "lWidth" : 40]
        let views = ["vlView": self.verticalLabelsView, "superView" : self, "lineView" : self.lineView, "hView" : self.horizontalLabelsView]
        let hConstraint = NSLayoutConstraint.constraintsWithVisualFormat("H:|[vlView]-2.0-[lineView]|", options: NSLayoutFormatOptions(0), metrics: metrics, views:views)
        let hConstraint2 = NSLayoutConstraint.constraintsWithVisualFormat("H:|[vlView]-2.0-[hView]|", options: NSLayoutFormatOptions(0), metrics: metrics, views:views)
        
        let vConstraint = NSLayoutConstraint.constraintsWithVisualFormat("V:|[vlView(superView)]", options: NSLayoutFormatOptions(0), metrics: metrics, views:views)
        let vConstraint2 = NSLayoutConstraint.constraintsWithVisualFormat("V:|[lineView]-2.0-[hView]|", options: NSLayoutFormatOptions(0), metrics: metrics, views:views)
        self.addConstraints(hConstraint)
        self.addConstraints(vConstraint)
        self.addConstraints(vConstraint2)
        self.addConstraints(hConstraint2)
        self.addConstraint(NSLayoutConstraint(item: self.verticalLabelsView, attribute: NSLayoutAttribute.Width, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Width, multiplier: 0.1, constant: 0))
        self.addConstraint(NSLayoutConstraint(item: self.horizontalLabelsView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: self, attribute: NSLayoutAttribute.Height, multiplier: 0.1, constant: 0))
        
        self.bringSubviewToFront(self.lineView)
        
        self.layoutIfNeeded()
        
    }
    
    // method to init them all
    func initAll() {
        self.addView()
        self.initLayers()
        self.initGestureRecognizers()
        self.addTouchLineToView()
        self.lineType = LineType.LineTypeSpline
        self.backgroundColor = UIColor.clearColor()
    }
    
    // method to init and add layers
    func initLayers() {
        self.lineView.layer.addSublayer(self.lineLayer)
    }
    
    // init all gesture recognizers and add them to the view
    func initGestureRecognizers() {
        Logger.Log(className: NSStringFromClass(self.classForCoder))
        
        // tap gesture recognizer
        self.tapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("tapHandler:"))
        self.tapGestureRecognizer.delegate = self
        self.lineView.addGestureRecognizer(self.tapGestureRecognizer)
        
        // pan gesture recognizer
        self.panGestureRecognizer = UIPanGestureRecognizer(target: self, action: Selector("panHandler:"))
        self.panGestureRecognizer.delegate = self
        self.panGestureRecognizer.maximumNumberOfTouches = 1
        self.lineView.addGestureRecognizer(self.panGestureRecognizer)
        
        // pinch gesture recognizer
        self.pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: Selector("pinchHandler:"))
        self.pinchGestureRecognizer.delegate = self
        self.lineView.addGestureRecognizer(self.pinchGestureRecognizer)
        
        // double tap gesture recognizer
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("doubleTapHandler:"))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.addGestureRecognizer(self.doubleTapGestureRecognizer)
    }
    
    // MARK: Drawing methods
    
    public func reloadData() {
        if let dataSource = self.dataSource {
            let dataCount = dataSource.lineChartNumberOfData(self)
            
            // Extract values from dataSource, calculate sum of values
            self.values = Array<Float>()
            for index in 0..<dataCount {
                var value = dataSource.lineChartValueForData(self, index: index)
                self.addValueToLine(value)
            }
            self.setNeedsDisplay()
        }
    }
    
    override public func drawRect(rect: CGRect) {
        // remove previously drawn layers
        removeLineView()
        
        // refresh points to the current scale
        refreshPoints()
        
        // calculate reference line and line
        var referenceLinesShapeLayer = self.calculateReferenceLineLayer()
        var line = Line(points:self.points, type: self.lineType)
        
        var pathLayer: CAShapeLayer = CAShapeLayer()
        pathLayer.frame.size = self.lineView.frame.size
        pathLayer.path = line.path.CGPath
        pathLayer.strokeColor = self.lineColor.CGColor
        pathLayer.fillColor = UIColor.clearColor().CGColor
        pathLayer.lineWidth = self.lineWidth
        pathLayer.lineJoin = kCALineJoinBevel
        pathLayer.lineCap = kCALineCapRound
        
        // animate line chart and reference lines
        self.animateForLayer(pathLayer, animationType:LineViewAnimationType.LineViewAnimationTypeDraw, isAnimatingReferenceLine:true)
        self.animateForLayer(referenceLinesShapeLayer, animationType: LineViewAnimationType.LineViewAnimationTypeDraw, isAnimatingReferenceLine: true)
        
        // add gradient layer (one for normal mode, and one for highlighted)
        self.addGradientLayers(line)
        
        drawDots()
    }
    
    // add gradient layer (one for normal mode, and one for highlighted)
    func addGradientLayers(line:Line) {
        if line.points.count > 0 {
            var fillToBottomPath = line.path
            fillToBottomPath.addLineToPoint(CGPoint(x:line.points.last!.position.x,y:self.lineView.frame.size.height))
            fillToBottomPath.addLineToPoint(CGPoint(x:line.points.first!.position.x,y:self.lineView.frame.size.height))
            fillToBottomPath.closePath()
            
            // normal gradient
            self.fillToBottom = CAShapeLayer()
            self.fillToBottom.path = fillToBottomPath.CGPath
            self.fillToBottom.strokeColor = nil
            self.fillToBottom.fillColor = self.gradientBackgroundColor.CGColor
            self.fillToBottom.frame.size = self.lineView.frame.size
            
            var gradientLayer = CAGradientLayer()
            gradientLayer.anchorPoint = CGPointZero
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
            
            var topColor:CGColorRef = UIColor(white: 1.0, alpha: 0.4).CGColor
            var bottomColor:CGColorRef = UIColor(white: 1.0, alpha: 0.0).CGColor
            
            gradientLayer.colors = [topColor,bottomColor]
            gradientLayer.locations = [Float(0.0),Float(1.0)]
            gradientLayer.bounds = CGRect(origin: CGPointZero, size: self.lineView.bounds.size)
            
            self.fillToBottom.mask = gradientLayer
            self.animateForLayer(fillToBottom, animationType: LineViewAnimationType.LineViewAnimationTypeFade)
            
            // highlighted
            self.fillToBottomHighlighted = CAShapeLayer()
            self.fillToBottomHighlighted.path = fillToBottomPath.CGPath
            self.fillToBottomHighlighted.strokeColor = nil
            self.fillToBottomHighlighted.hidden = true
            self.fillToBottomHighlighted.fillColor = self.gradientHighlightedBackgroundColor.CGColor
            self.fillToBottomHighlighted.frame.size = self.lineView.frame.size
            
            self.lineLayer.addSublayer(self.fillToBottomHighlighted)
        }
    }
    
    // method for making axis labels
    func makeAxisLabel(position:CGPoint,labelText:String) -> UILabel
    {
        var label = UILabel(frame: CGRect(origin: CGPoint(x:0,y:0), size: CGSize(width: 50, height: 20)))
        label.text = labelText
        label.font = UIFont.systemFontOfSize(12.0)
        label.sizeToFit()
        label.center = position
        label.textAlignment = NSTextAlignment.Center
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.0
        return label
    }
    
    // calculate
    func calculateReferenceLineLayer()  -> CAShapeLayer {
        var referenceLinePathLayer = CAShapeLayer()
        if (self.enableReferenceLine) {
            // customize path
            var referenceLinePath: UIBezierPath = UIBezierPath()
            referenceLinePath.lineCapStyle = kCGLineCapButt
            referenceLinePath.lineWidth = 0.1
            referenceLinePath.strokeWithBlendMode(kCGBlendModeNormal, alpha: 1.0)
            
            // remove previously created axis labels
            self.verticalLabels = Array<UILabel>()
            for view in self.verticalLabelsView.subviews
            {
                view.removeFromSuperview()
            }
            self.horizontalLabels = Array<UILabel>()
            for view in self.horizontalLabelsView.subviews
            {
                view.removeFromSuperview()
            }
            
            // draw vertical reference lines
            for var i = 0; i < self.points.count; i+=self.axisLabelDiff {
                // current point x position
                let pointX = self.points[i].position.x
                // draw line between top and bottom point
                let topEnd:CGPoint = CGPointMake(pointX, self.lineView.frame.size.height)
                let bottomEnd:CGPoint = CGPointMake(pointX, 0)
                referenceLinePath.moveToPoint(topEnd)
                referenceLinePath.addLineToPoint(bottomEnd)
                
                // current LinePoint
                let point:LinePoint = self.points[i]
                
                var textGood:String
                if let text = self.dataSource?.lineChartTextForData?(self, index: i) {
                    textGood = text
                } else {
                    textGood = point.text
                }
                
                // make label with current text
                var label = self.makeAxisLabel(CGPoint(x:point.position.x,y:self.horizontalLabelsView.frame.size.height/2.0), labelText: textGood)
                
                // check if it fits
                if (self.horizontalLabels.count >= 1 ) {
                    let previousLabel = self.horizontalLabels.last!
                    // only draw if it fits
                    if (fabs(previousLabel.center.x - label.center.x) > label.frame.size.width * 2) {
                        self.horizontalLabels.append(label)
                        self.horizontalLabelsView.addSubview(label)
                    }
                } else { // first label to add, it has to fit
                    self.horizontalLabels.append(label)
                    self.horizontalLabelsView.addSubview(label)
                }
                
            }
            
            // sort points for drawing every diff. lines (eg. only 2nd lines)
            let sortedPoints = sorted(self.points, { (p1:LinePoint, p2:LinePoint) -> Bool in
                return p1.position.y > p2.position.y
            })
            
            // draw first horizontal line at y=0
            var leftEnd:CGPoint = CGPointMake(0, 0)
            var rightEnd:CGPoint = CGPointMake(self.lineView.frame.size.width, 0)
            referenceLinePath.moveToPoint(leftEnd)
            referenceLinePath.addLineToPoint(rightEnd)
            
            // draw horizontal lines
            for var i = 0; i < sortedPoints.count; i+=self.axisLabelDiff {
                // current point y value
                let pointY = sortedPoints[i].position.y
                var leftEnd:CGPoint = CGPointMake(0, pointY)
                var rightEnd:CGPoint = CGPointMake(self.lineView.frame.size.width, pointY)
                referenceLinePath.moveToPoint(leftEnd)
                referenceLinePath.addLineToPoint(rightEnd)
                
                // make label with current value
                let point:LinePoint = sortedPoints[i]
                var label = self.makeAxisLabel(CGPoint(x:self.verticalLabelsView.frame.size.width/2.0,y:point.position.y), labelText: String("\(point.value)"))
                
                // only draw if it fits
                if (self.verticalLabels.count >= 1 ) {
                    let previousLabel = self.verticalLabels.last!
                    if (fabs(previousLabel.center.y - label.center.y) > label.frame.size.height * 2) {
                        self.verticalLabels.append(label)
                        self.verticalLabelsView.addSubview(label)
                    }
                } else { // first label, it has to fit
                    self.verticalLabels.append(label)
                    self.verticalLabelsView.addSubview(label)
                }
            }
            referenceLinePath.closePath()
            
            // add path to self.layer
            referenceLinePathLayer.frame.size = self.lineView.frame.size
            referenceLinePathLayer.path = referenceLinePath.CGPath
            referenceLinePathLayer.opacity = Float(self.lineAlpha)/2.0
            referenceLinePathLayer.strokeColor = self.referenceLineColor.CGColor
            referenceLinePathLayer.fillColor = nil
            referenceLinePathLayer.lineWidth = 0.3
        }
        return referenceLinePathLayer
    }
    
    
    // draw all dots
    func drawDots() {
        // first remove all previous dots
        self.dots.removeAll(keepCapacity: false)
        // add a dot for every point in line
        for (index,point) in enumerate(points) {
            var goodColor:UIColor
            if let color = self.dataSource?.lineChartDotColorForData?(self, index: index) {
                goodColor = color
            } else {
                goodColor = self.dotColor
            }
            var dot = DotView(value: point.value, center: point.position, radius: self.dotSize, color: goodColor)
            dot.alpha = 0.0 // needed for fading animation
            self.lineView.addSubview(dot)
            self.dots.append(dot)
            UIView.animateWithDuration(2.0, animations: { () -> Void in
                dot.alpha = 0.7
            })
        }
    }
    
    // removes the whole line view
    func removeLineView() {
        self.lineLayer.sublayers = nil
        for dot in self.dots {
            dot.removeFromSuperview()
        }
    }
    
    // adds the two touch view to the view
    func addTouchLineToView()
    {
        Logger.Log(className: NSStringFromClass(self.classForCoder))
        let leftFrame = CGRect(x: 0, y: 0, width: self.touchLineWidth, height: self.lineView.frame.size.height)
        self.touchLineLeft = InterractionView(frame: leftFrame, lineColor: self.touchLineLineColor, backgroundColor: self.touchLineBackgroundColor)
        self.touchLineLeft?.alpha = 0
        self.lineView.addSubview(self.touchLineLeft!)
        
        let rightFrame = CGRect(x: 0, y: 0, width: self.touchLineWidth, height: self.lineView.frame.size.height)
        self.touchLineRight = InterractionView(frame: rightFrame, lineColor: self.touchLineLineColor, backgroundColor: self.touchLineBackgroundColor)
        self.touchLineRight?.alpha = 0
        self.lineView.addSubview(self.touchLineRight!)
    }
    
    // scales all points relative to the current frame
    func refreshPoints() {
        Logger.Log(className: NSStringFromClass(self.classForCoder))
        let oldMin:Float = self.minValue < 0 ? Float(self.minValue) : 0
        let oldMax:Float = Float(self.maxValue)
        let newMargin:Float = 10.0
        let newMin:Float = Float(0.0) + newMargin
        let newMax:Float = Float(self.lineView.frame.size.height) - newMargin
        var oldRange:Float = Float(oldMax) - Float(oldMin)
        let newRange:Float = newMax - newMin
        self.points = Array<LinePoint>()
        var step:CGFloat = CGFloat(self.lineView.frame.width)/CGFloat(self.values.count-1)
        for (index,value) in enumerate(values) {
            var newValue:Float = newMax-(((Float(value) - Float(oldMin))*Float(newRange)) / Float(oldRange)) + Float(newMin)
            var pointToAdd = LinePoint(value: value, position: CGPoint(x: CGFloat(step)*CGFloat(index), y: CGFloat(newValue)))
            self.points.append(pointToAdd)
        }
        self.setNeedsDisplay()
    }
    
    
    // MARK: Animation methods
    
    func animateForLayer(shapeLayer: CAShapeLayer, animationType:LineViewAnimationType, isAnimatingReferenceLine:Bool = false)
    {
        if (animationType == LineViewAnimationType.LineViewAnimationTypeNone) {
            // do nothing no animation is neded
        } else if (animationType == LineViewAnimationType.LineViewAnimationTypeFade) {
            var animation = CABasicAnimation(keyPath: "opacity")
            animation.duration = CFTimeInterval(self.animationTime)
            animation.fromValue = 0.0
            if (isAnimatingReferenceLine) {
                animation.toValue = self.lineAlpha/2.0
            } else {
                animation.toValue = self.lineAlpha
            }
            shapeLayer.addAnimation(animation, forKey: "opacity")
        } else {
            var animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = CFTimeInterval(self.animationTime)
            animation.fromValue = 0.0
            animation.toValue = 1.0
            shapeLayer.addAnimation(animation, forKey: "strokeEnd")
        }
        self.lineLayer.addSublayer(shapeLayer)
    }
    
    // MARK: Gesture recognizer handlers
    
    func tapHandler(recognizer:UIPanGestureRecognizer){
        Logger.Log(className: NSStringFromClass(self.classForCoder))
    }
    
    func doubleTapHandler(recognizer:UIPanGestureRecognizer){
        Logger.Log(className: NSStringFromClass(self.classForCoder))
//        addRandomValueToLine()
    }
    
    // pan handler, for showing current values
    func panHandler(recognizer:UIPanGestureRecognizer){
        // show touchline
        self.touchLineLeft!.alpha = 1.0
        
        // finding closest dot for touchline current position
        var closestDotLeft = self.closestDotFromTouchLine(self.touchLineLeft!)
        
        let translation = recognizer.locationInView(self.lineView.viewForBaselineLayout())
        // To make sure the vertical line doesn't go beyond the frame of the graph.
        if (!((translation.x + self.lineView.frame.origin.x) <= self.lineView.frame.origin.x) &&
            !((translation.x + self.lineView.frame.origin.x) >= self.lineView.frame.origin.x + self.lineView.frame.size.width))
        {
            var origin = CGPoint(x: translation.x - self.touchLineWidth/2.0, y: 0.0)
            var frame = self.touchLineLeft!.frame
            frame.origin = origin
            self.touchLineLeft?.frame = frame
            self.touchLineLeft?.center.x = translation.x
            self.touchLineLeft?.pin.center.y = closestDotLeft.center.y
            self.touchLineLeft?.text = closestDotLeft.value.description
            self.touchLineLeft?.line.frame.size.height = self.lineView.frame.size.height
        }
        
        // hide touch view when gesture ended
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                self.touchLineLeft!.alpha = 0.0
                }, completion: nil)
        }
    }
    
    func pinchHandler(recognizer:UIPinchGestureRecognizer){
        if (recognizer.numberOfTouches() == 2) {
            var leftTouch: CGPoint
            var rightTouch: CGPoint
            var touch1 = recognizer.locationOfTouch(0, inView: self.lineView)
            var touch2 = recognizer.locationOfTouch(1, inView: self.lineView)
            
            // calculate which touch is left and which is right
            if (touch1.x > touch2.x) {
                rightTouch = touch1
                leftTouch = touch2
            } else {
                rightTouch = touch2
                leftTouch = touch1
            }
            
            // show both touch views
            self.touchLineLeft!.alpha = 1.0
            self.touchLineRight!.alpha = 1.0
            
            // calculate colsest dots
            var closestDotLeft = self.closestDotFromTouchLine(self.touchLineLeft!)
            var closestDotRight = self.closestDotFromTouchLine(self.touchLineRight!)
            
            // show highlighted layer between the two touches
            self.fillToBottomHighlighted.hidden = false
            var maskLayer = CALayer()
            maskLayer.backgroundColor = UIColor.blackColor().CGColor
            maskLayer.frame = CGRect(x: leftTouch.x, y: 0, width: rightTouch.x-leftTouch.x, height: self.lineView.frame.size.height)
            self.fillToBottomHighlighted.mask = maskLayer
            
            // To make sure the vertical line doesn't go beyond the frame of the graph.
            if (!((leftTouch.x + self.lineView.frame.origin.x) <= self.lineView.frame.origin.x) &&
                !((leftTouch.x + self.lineView.frame.origin.x) >= self.lineView.frame.origin.x + self.lineView.frame.size.width))
            {
                var origin = CGPoint(x: leftTouch.x - self.touchLineWidth/2.0, y: 0.0)
                var frame = self.touchLineLeft!.frame
                frame.origin = origin
                self.touchLineLeft?.frame = frame
                self.touchLineLeft?.center.x = leftTouch.x
                self.touchLineLeft?.pin.center.y = closestDotLeft.center.y
                self.touchLineLeft?.text = closestDotLeft.value.description
                self.touchLineLeft?.line.frame.size.height = self.lineView.frame.size.height
                
            }
            // To make sure the vertical line doesn't go beyond the frame of the graph.
            if (!((rightTouch.x + self.lineView.frame.origin.x) <= self.lineView.frame.origin.x) &&
                !((rightTouch.x + self.lineView.frame.origin.x) >= self.lineView.frame.origin.x + self.lineView.frame.size.width))
            {
                var origin = CGPoint(x: rightTouch.x - self.touchLineWidth/2.0, y: 0.0)
                var frame = self.touchLineLeft!.frame
                frame.origin = origin
                self.touchLineRight?.frame = frame
                self.touchLineRight?.center.x = rightTouch.x
                self.touchLineRight?.pin.center.y = closestDotRight.center.y
                self.touchLineRight?.text = closestDotRight.value.description
                self.touchLineRight?.line.frame.size.height = self.lineView.frame.size.height
                
            }
            
        }
        if (recognizer.state == UIGestureRecognizerState.Ended) {
            UIView.animateWithDuration(0.2, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: { () -> Void in
                // hide touch views
                self.touchLineLeft!.alpha = 0.0
                self.touchLineRight!.alpha = 0.0
                var closestDotLeft = self.closestDotFromTouchLine(self.touchLineLeft!)
                var closestDotRight = self.closestDotFromTouchLine(self.touchLineRight!)
                
                self.fillToBottomHighlighted.hidden = true
                
                }, completion: nil)
            
        }
    }
    
    // finds the closest dot from the touch view
    func closestDotFromTouchLine(line:UIView) -> DotView {
        var dotView = self.dots.first!
        var closestDiff: CGFloat = self.lineView.frame.width*2.0
        let lineXPos = line.frame.origin.x
        for dot in self.dots {
            var currentDif = fabs(dot.frame.origin.x - lineXPos)
            if currentDif <= closestDiff{
                closestDiff = currentDif
                dotView = dot
            }
        }
        return dotView
    }
    
    public override func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    // MARK: Interface builder helper
    
    public override func prepareForInterfaceBuilder() {
        // provide sample data for Interface Builder
        
        self.values = [0,100,30,180,10,200]
        drawDots()
    }
    
    // MARK: Helper methods
    
    public func addValueToLine(value:Float) {
        let v:Float = Float(value)
        if self.values.count == 0 {
            self.maxValue = v
            self.minValue = v
        } else {
            if self.maxValue <= v {
                self.maxValue = v
            }
            if self.minValue >= v {
                self.minValue = v
            }
        }
        self.values.append(value)
    }
    
    func addRandomValueToLine() {
        var randomValue: Float = Float(arc4random_uniform(2000))
        var minus:Float = Float(arc4random_uniform(4))
        
        if minus == 2 {
            randomValue *= -1
        }
        
        self.addValueToLine(randomValue)
    }
    
    
}



