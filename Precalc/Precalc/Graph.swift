//
//  Graph.swift
//  Precalc
//
//  Created by Moshe Berman on 12/25/16.
//  Copyright © 2016 Moshe Berman. All rights reserved.
//

import CoreGraphics

/*:
 
 # The Graph
 
 When we draw graphs on paper, we usually draw an x axis and a y axis. Then, we calculate and plot points using a given interval. The graph view works in a similar way. By defining our positive and negative x limits, we can easily draw a square graph that scales to fit the frame of the view, and fits the defined number of calculations in our range.
 
 */

class GraphView : UIView
{
    fileprivate(set) var equations : [GraphableEquation] = []
    
    var x1: CGFloat = -15.0
    var x2: CGFloat = 15.0
    var interval : CGFloat = 1.0
    
    fileprivate let graphBackgroundColor = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)
    fileprivate let graphLineColor = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
    
    fileprivate lazy var scale : CGFloat = self.frame.width / (max(self.x1, self.x2) - min(self.x1, self.x2))
    
    fileprivate var numberOfLines : Int {
        return Int(self.frame.width) / Int(scale)
    }
    
    // MARK: - Initializer
    
    convenience init(withSmallerXBound x1: CGFloat, largerXBound x2: CGFloat, andInterval interval: CGFloat)
    {
        // If this isn't square, weird things will happen. Sorry!
        self.init(frame: CGRect(x: 0, y: 0, width: 600, height: 600))
        
        self.x1 = x1
        self.x2 = x2
        self.interval = interval
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // MARK: - Adding Equations
    
    func clear()
    {
        self.equations = []
        self.setNeedsDisplay()
    }
    
    func addEquation(_ equation: GraphableEquation)
    {
        _ = equation.compute(withInterval: self.interval, between: self.x1, and: self.x2)
        
        self.equations.append(equation)
        self.setNeedsDisplay()
    }
    
    // MARK: - Drawing
    
    override func draw(_ rect: CGRect) {
        
        guard let context = UIGraphicsGetCurrentContext() else
        {
            return
        }
        
        self.fillBackground(withContext: context, andRect: rect)
        self.drawHorizontalLines(withContext: context)
        self.drawVerticalLines(withContext: context)
        
        for equation in self.equations
        {
            self.drawEquation(equation, withContext: context, inRect: rect)
        }
    }
    
    // MARK: - Draw Equation
    
    func drawEquation(_ equation: GraphableEquation, withContext context: CGContext, inRect rect: CGRect)
    {
        let coordinates = equation.compute(withInterval: self.interval, between: x1, and: x2)
        
        self.drawLines(betweenCoordinates: coordinates, withContext: context, inRect: rect
            , usingColor: equation.drawingColor.cgColor)
        self.drawPoints(atCoordinates: coordinates, withContext: context, inRect: rect, usingColor: equation.drawingColor.cgColor)
    }
    
    // MARK: - Fill With Background Color
    
    func fillBackground(withContext context: CGContext, andRect rect: CGRect)
    {
        context.setFillColor(self.graphBackgroundColor.cgColor)
        context.fill(rect)
    }
    
    // MARK: - Draw Grid
    
    func drawHorizontalLines(withContext context: CGContext)
    {
        var y : CGFloat = 0.0
        
        context.setStrokeColor(self.graphLineColor.cgColor)
        context.setLineWidth(0.5)
        
        while y < self.frame.height
        {
            if context.isPathEmpty == false
            {
                context.strokePath()
                
                // Stroke Axis
                if y == self.frame.width/2.0
                {
                    context.setLineWidth(2.0)
                }
                else
                {
                    context.setLineWidth(1.0)
                }
            }
            
            context.move(to: CGPoint(x: 0.0, y: y))
            context.addLine(to: CGPoint(x: self.frame.height, y: y))
            
            y = y + self.scale
        }
        
        context.strokePath()
    }
    
    func drawVerticalLines(withContext context: CGContext)
    {
        var x : CGFloat = 0.0
        
        context.setStrokeColor(self.graphLineColor.cgColor)
        context.setLineWidth(0.5)
        
        while x < self.frame.height
        {
            if context.isPathEmpty == false
            {
                context.strokePath()
            }
            
            // Stroke Axis
            if x == self.frame.height/2.0
            {
                context.setLineWidth(2.0)
            }
            else
            {
                context.setLineWidth(1.0)
            }
            
            context.move(to: CGPoint(x: x, y: 0.0))
            context.addLine(to: CGPoint(x: x, y: self.frame.width))
            
            x = x + self.scale
        }
        
        context.strokePath()
    }
    
    // MARK: - Draw the Graph
    
    func drawPoints(atCoordinates coordinates: [Coordinate], withContext context: CGContext, inRect rect: CGRect, usingColor color: CGColor)
    {
        context.setStrokeColor(color)
        context.setLineWidth(2.0)
        
        for coordinate in coordinates
        {
            let translated = self.translated(coordinate: coordinate, toRect: rect)
            context.move(to: translated)
            self.drawCircle(inContext: context, atCoordinate: translated)
        }
        
        context.strokePath()
    }
    
    func drawLines(betweenCoordinates coordinates: [Coordinate], withContext context: CGContext, inRect rect: CGRect, usingColor color: CGColor)
    {
        context.setStrokeColor(color)
        context.setLineWidth(1.0)
        
        let translated = self.translated(coordinate: coordinates[0], toRect: rect)
        context.move(to: translated)
        
        for coordinate in coordinates
        {
            let translated = self.translated(coordinate: coordinate, toRect: rect)
            context.addLine(to: translated)
            context.move(to: translated)
        }
        
        context.strokePath()
        
    }
    
    // MARK: - Convert Coordinates to the CGContext
    
    func translated(coordinate coord: Coordinate, toRect rect: CGRect) -> Coordinate
    {
        var coordinate : Coordinate = coord
        let scale = self.scale
        
        coordinate.x = (rect.width / 2.0) + (coordinate.x * scale)
        coordinate.y = (rect.height / 2.0) + (-coordinate.y * scale)
        
        return coordinate
    }
    
    // MARK: - Draw a Circle
    
    func drawCircle(inContext context: CGContext, atCoordinate coordinate: Coordinate)
    {
        context.addArc(center: coordinate, radius: 1.0, startAngle: 0.0, endAngle: CGFloat(M_PI) * 2.0, clockwise: false)
    }
}
