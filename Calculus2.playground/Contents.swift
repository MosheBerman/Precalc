//: Playground - noun: a place where people can play

import UIKit
import CoreGraphics
import XCPlayground

/*:
 
 # Graphing Equations
 
 To graph an equation, we need to define a coordinate. Luckily, Core Graphics has just what we need: CGPoint.
 
 */

typealias Coordinate = CGPoint

/*:
 
 # Equation Protocol
 
 Every equation is ultimately drawn in our graph as a collection of points at coordinates calculated on our given range. The implementation of the computation is usually how we identify it, but when we are graphing, we don't want to draw out the entire range of values that the equation will yield because it's potentially infinite for a given function, so we compute on a given interval.
 
 */

protocol Equation
{
    var coordinates : [Coordinate] { get }
    
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat)
    
}

/*:
 
 #  Modifying Equations
 
 If we want to do things like translate, rotate, or reflect an equation,
 we could implement those methods here. What might that look like? What about composing a function?
 
 Some equations, such as various trigonometric functions, already support some of these operations as part of their formulae. (Phase shift of a sine wave, for example.)
 
 To require these protocols, you can add an extension which adopts this protocol.
 
 */

protocol ModifiableEquation
{
    func reflect(overXAxis: Bool, overYAxis: Bool)
    
    func translate(deltaX: CGFloat, deltaY: CGFloat)
    
    func rotate(withAngle theta: CGFloat)
}

/*:
 
 # Pick a Color. Any Color.
 
 If we draw multiple equations on the same graph, we might want to change the color. to support this, all Graphable equations implement a color property.
 
 */

protocol GraphableEquation : Equation
{
    var drawingColor : UIColor { get set }
}

/*:
 
 # The Graph
 
 When we draw graphs on paper, we usually draw an x axis and a y axis. Then, we calculate and plot points using a given interval. The graph view works in a similar way. By defining our positive and negative x limits, we can easily draw a square graph that scales to fit the frame of the view, and fits the defined number of calculations in our range.
 
 */

class GraphView : UIView
{
    private(set) var equations : [GraphableEquation] = []
    
    var x1: CGFloat = -15.0
    var x2: CGFloat = 15.0
    var interval : CGFloat = 1.0
    
    private let graphBackgroundColor = UIColor(red: 0.95, green: 0.95, blue: 1.0, alpha: 1.0)
    private let graphLineColor = UIColor(red: 0.8, green: 0.9, blue: 1.0, alpha: 1.0)
    
    private lazy var scale : CGFloat = self.frame.width / (max(self.x1, self.x2) - min(self.x1, self.x2))
    
    private var numberOfLines : Int {
        return Int(CGRectGetWidth(self.frame)) / Int(scale)
    }
    
    // MARK: - Initializer
    
    convenience init(withSmallerXBound x1: CGFloat, largerXBound x2: CGFloat, andInterval interval: CGFloat)
    {
        // If this isn't square, weird things will happen. Sorry!
        self.init(frame: CGRectMake(0, 0, 600.0, 600.0))
        
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
    
    func addEquation(equation: GraphableEquation)
    {
        equation.compute(withInterval: self.interval, between: self.x1, and: self.x2)
        
        self.equations.append(equation)
        self.setNeedsDisplay()
    }
    
    // MARK: - Drawing
    
    override func drawRect(rect: CGRect) {
        
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
    
    func drawEquation(equation: GraphableEquation, withContext context: CGContext, inRect rect: CGRect)
    {
        self.drawLines(betweenCoordinates: equation.coordinates, withContext: context, inRect: rect
            , usingColor: equation.drawingColor.CGColor)
        self.drawPoints(atCoordinates: equation.coordinates, withContext: context, inRect: rect, usingColor: equation.drawingColor.CGColor)
    }
    
    // MARK: - Fill With Background Color
    
    func fillBackground(withContext context: CGContext, andRect rect: CGRect)
    {
        CGContextSetFillColorWithColor(context, self.graphBackgroundColor.CGColor)
        CGContextFillRect(context, rect)
    }
    
    // MARK: - Draw Grid
    
    func drawHorizontalLines(withContext context: CGContext)
    {
        var y : CGFloat = 0.0
        
        CGContextSetStrokeColorWithColor(context, self.graphLineColor.CGColor)
        CGContextSetLineWidth(context, 0.5)
        
        while y < self.frame.height
        {
            if CGContextIsPathEmpty(context) == false
            {
                CGContextStrokePath(context)
                
                // Stroke Axis
                if y == CGRectGetWidth(self.frame)/2.0
                {
                    CGContextSetLineWidth(context, 2.0)
                }
                else
                {
                    CGContextSetLineWidth(context, 1.0)
                }
            }
            
            CGContextMoveToPoint(context, 0, y)
            CGContextAddLineToPoint(context, self.frame.height, y)
            
            y = y + self.scale
        }
        
        CGContextStrokePath(context)
    }
    
    func drawVerticalLines(withContext context: CGContext)
    {
        var x : CGFloat = 0.0
        
        CGContextSetStrokeColorWithColor(context, self.graphLineColor.CGColor)
        CGContextSetLineWidth(context, 0.5)
        
        while x < self.frame.height
        {
            if CGContextIsPathEmpty(context) == false
            {
                CGContextStrokePath(context)
            }
            
            // Stroke Axis
            if x == CGRectGetHeight(self.frame)/2.0
            {
                CGContextSetLineWidth(context, 2.0)
            }
            else
            {
                CGContextSetLineWidth(context, 1.0)
            }
            
            CGContextMoveToPoint(context, x, 0)
            CGContextAddLineToPoint(context, x, self.frame.width)
            
            x = x + self.scale
        }
        
        CGContextStrokePath(context)
    }
    
    // MARK: - Draw the Graph
    
    func drawPoints(atCoordinates coordinates: [Coordinate], withContext context: CGContext, inRect rect: CGRect, usingColor color: CGColor)
    {
        CGContextSetStrokeColorWithColor(context, color)
        CGContextSetLineWidth(context, 2.0)
        
        for coordinate in coordinates
        {
            let translated = self.translated(coordinate: coordinate, toRect: rect)
            CGContextMoveToPoint(context, translated.x, translated.y)
            self.drawCircle(inContext: context, atCoordinate: translated)
        }
        
        CGContextStrokePath(context)
    }
    
    func drawLines(betweenCoordinates coordinates: [Coordinate], withContext context: CGContext, inRect rect: CGRect, usingColor color: CGColor)
    {
        CGContextSetStrokeColorWithColor(context, color)
        CGContextSetLineWidth(context, 1.0)
        
        let translated = self.translated(coordinate: coordinates[0], toRect: rect)
        CGContextMoveToPoint(context, translated.x, translated.y)
        
        for coordinate in coordinates
        {
            let translated = self.translated(coordinate: coordinate, toRect: rect)
            CGContextAddLineToPoint(context, translated.x, translated.y)
            CGContextMoveToPoint(context, translated.x, translated.y)
        }
        
        CGContextStrokePath(context)
        
    }
    
    // MARK: - Convert Coordinates to the CGContext
    
    func translated(coordinate coord: Coordinate, toRect rect: CGRect) -> Coordinate
    {
        var coordinate : Coordinate = coord
        let scale = self.scale
        
        coordinate.x = (CGRectGetWidth(rect) / 2.0) + (coordinate.x * scale)
        coordinate.y = (CGRectGetHeight(rect) / 2.0) + (-coordinate.y * scale)
        
        return coordinate
    }
    
    // MARK: - Draw a Circle
    
    func drawCircle(inContext context: CGContext, atCoordinate coordinate: Coordinate)
        
    {
        CGContextAddArc(context, coordinate.x, coordinate.y, 1.0, 0.0, CGFloat(M_PI) * 2.0, 0)
    }
}

/*:
 
 # Defining Some Equations
 
 Here are some sample implementations of equations.
 
 - Exponential Function: Takes an exponent and calculates a simple x = y^n, where n is user supplied.
 - Line Function: Takes a slope and y offset and draws a line.
 - Sine: Supports amplitude, phase shift, vertical shift, and period.
 - Cosine: Same as sine, but with the cosine function.
 
 Because I haven't worked out how to use Swift's `for x in x1...x2` with CGFloats, I use a where loop,
 manually incrementing by our interval on each iteration. When the computation for an equation is finished,
 I assign the collected values to the equation's `coordinates` property. The GraphView knows what to do with that.
 
 Also, the GraphView asks the Equations to compute as necessary, so you don't usually need to call this yourself.
 
 */

//: Exponential

class Exponential : GraphableEquation
{
    var exponent : CGFloat = 0.0
    
    // MARK: - Initializers
    
    init(exponent: CGFloat)
    {
        self.exponent = exponent
    }
    
    // MARK: - Graphable Equation
    
    var coordinates: [Coordinate] = []
    var drawingColor: UIColor = UIColor.redColor()
    
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat)
    {
        var coordinates : [Coordinate] = []
        var x = x1
        
        while x  <= x2
        {
            let y = pow(x, exponent)
            coordinates.append(Coordinate(x: x, y: y))
            x = x + interval
        }
        
        self.coordinates = coordinates
    }
}

//: Line

class Line : GraphableEquation
{
    var m : CGFloat = 1.0
    var b : CGFloat = 2.0
    
    // Initiializer
    
    init(slope m: CGFloat, offset b: CGFloat)
    {
        self.m = m
        self.b = b
    }
    
    // MARK: = Graphable Equation
    
    var coordinates: [Coordinate] = []
    var drawingColor: UIColor = UIColor.greenColor()
    
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat) {
        var coordinates : [Coordinate] = []
        
        var x = x1
        
        while x <= x2
        {
            let y = (self.m * x) + self.b
            
            coordinates.append(Coordinate(x: x, y: y))
            
            x = x + interval
        }
        
        self.coordinates = coordinates
    }
}

//: Sine

class Sine : GraphableEquation
{
    var period: CGFloat
    var amplitude: CGFloat
    var phaseShift: CGFloat
    var verticalShift: CGFloat
    
    // MARK: - Initializer
    
    init(period: CGFloat, amplitude: CGFloat, phaseShift: CGFloat, verticalShift: CGFloat)
    {
        self.period = period
        self.amplitude = amplitude
        self.phaseShift = phaseShift
        self.verticalShift = verticalShift
    }
    
    convenience init()
    {
        self.init(period: 1.0, amplitude: 1.0, phaseShift: 0.0, verticalShift: 0.0)
    }
    
    // MARK: - GraphableEquation
    
    var coordinates: [Coordinate] = []
    var drawingColor: UIColor = UIColor.blackColor()
    
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat) {
        
        var coordinates : [Coordinate] = []
        
        var x = x1
        
        while x <= x2
        {
            let y : CGFloat
            
            y = amplitude * sin((self.period * x) - (self.phaseShift/self.period)) + self.verticalShift
            
            coordinates.append(Coordinate(x: x, y: y))
            
            x = x + interval
        }
        
        self.coordinates = coordinates
    }
}

//: Cosine

class Cosine : GraphableEquation
{
    var period: CGFloat
    var amplitude: CGFloat
    var phaseShift: CGFloat
    var verticalShift: CGFloat
    
    // MARK: - Initializer
    
    init(period: CGFloat, amplitude: CGFloat, phaseShift: CGFloat, verticalShift: CGFloat)
    {
        self.period = period
        self.amplitude = amplitude
        self.phaseShift = phaseShift
        self.verticalShift = verticalShift
    }
    
    convenience init()
    {
        self.init(period: 1.0, amplitude: 1.0, phaseShift: 0.0, verticalShift: 0.0)
    }
    
    // MARK: - GraphableEquation
    
    var coordinates: [Coordinate] = []
    var drawingColor: UIColor = UIColor.blackColor()
    
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat) {
        
        var coordinates : [Coordinate] = []
        
        var x = x1
        
        while x <= x2
        {
            let y : CGFloat
            
            y = amplitude * cos((self.period * x) - (self.phaseShift/self.period)) + self.verticalShift
            
            coordinates.append(Coordinate(x: x, y: y))
            
            x = x + interval
        }
        
        self.coordinates = coordinates
    }
}

/*:
 
 #  Graphing Some Functions
 
 Here's an example of graphing a few equations on a graph. Try playing with some of the lines below to see what the graph draws. You can also implement your own equations.
 
 */

func demo()
{
    let graph = GraphView(withSmallerXBound: -15.0, largerXBound: 15.0, andInterval: 0.5)
    let sine = Sine()
    let line = Line(slope: 1.0, offset: 4.0)
    let exponential = Exponential(exponent: 2.0)
    
    //: You can add these yourself.
    
//    let shiftedSine = Sine(period: 1.0, amplitude: 3.0, phaseShift: 1.0, verticalShift: 0.0)
//    shiftedSine.drawingColor = UIColor(red: 0.2, green: 0.2, blue: 0.7, alpha: 1.0)
//    
//    let cosine = Cosine()
//    cosine.drawingColor = UIColor(red: 0.2, green: 0.7, blue: 0.2, alpha: 1.0)
    
    graph.addEquation(sine)
    graph.addEquation(line)
    graph.addEquation(exponential)
    

    
    XCPlaygroundPage.currentPage.liveView = graph
}

demo()

