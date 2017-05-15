//: Playground - noun: a place where people can play

import UIKit
import CoreGraphics
import PlaygroundSupport

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
    func compute(at x: CGFloat) -> CGFloat   
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
    func reflect(_ overXAxis: Bool, overYAxis: Bool)
    
    func translate(_ deltaX: CGFloat, deltaY: CGFloat)
    
    func rotate(withAngle theta: CGFloat)
}

/*:
 
 # Pick a Color. Any Color.
 
 If we draw multiple equations on the same graph, we might want to change the color. to support this, all Graphable equations implement a color property.
 
 */

protocol GraphableEquation : Equation
{
    var drawingColor : UIColor { get set }
    var drawingDomain: Range<CGFloat>? { get set }
}

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

    // Should we call setNeedsDisplay automatically
    var autoUpdatesAfterAddingEquation: Bool = true
    
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
        if autoUpdatesAfterAddingEquation 
        {
            self.setNeedsDisplay()
        }
    }
    
    func addEquation(_ equation: GraphableEquation, between min: CGFloat?=nil, and max: CGFloat?=nil, inclusive:Bool = true)
    {
        self.equations.append(equation)

        if autoUpdatesAfterAddingEquation 
        {
            self.setNeedsDisplay()
        }
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
        
        for x in stride(from: x1, through: x2, by: interval)
        {
            for equation in self.equations
            {
                self.drawEquation(equation, withContext: context, inRect: rect, at:x)
            }
        }
        
        
    }
    
    // MARK: - Draw Equation
    
    func drawEquation(_ equation: GraphableEquation, withContext context: CGContext, inRect rect: CGRect, at x: CGFloat)
    {
        let previousX = x - self.interval
        var rangeContainsPreviousX = true
        
        if let range = equation.drawingDomain
        {
            // Don't draw dangling lines at the start of the graph.
            rangeContainsPreviousX = range.contains(previousX)
            
            // If the equation provides a domain, respect it.    
            if !range.contains(x)
            {
                return
            }
        }
        
        let coordinate: Coordinate = Coordinate(x: x, y: equation.compute(at:x))
        
        if previousX > self.x1, rangeContainsPreviousX
        {
            let previousCoordinate = Coordinate(x: previousX, y: equation.compute(at:previousX))
            
            let coordinates = [previousCoordinate, coordinate]
            
            self.drawLines(betweenCoordinates: coordinates, withContext: context, inRect: rect, usingColor: equation.drawingColor.cgColor)
        }
        
        self.drawPoints(atCoordinates: [coordinate], withContext: context, inRect: rect, usingColor: equation.drawingColor.cgColor)
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
        context.addArc(center: coordinate, radius: 1.0, startAngle: 0.0, endAngle: .pi * 2.0, clockwise: false)
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
    
    var drawingColor: UIColor = UIColor.red
    var drawingDomain: Range<CGFloat>?
    
    // MARK: - Equation
    
    func compute(at x: CGFloat) -> CGFloat {
        return pow(x, exponent)
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
    
    var drawingColor: UIColor = UIColor.green
    var drawingDomain: Range<CGFloat>?
    
    // MARK: - Equation
    
    func compute(at x: CGFloat) -> CGFloat {
        return (self.m * x) + self.b
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
    
    var drawingColor: UIColor = UIColor.black
    var drawingDomain: Range<CGFloat>?
    
    // MARK: - Equation
    
    func compute(at x: CGFloat) -> CGFloat
    {
        return amplitude * cos((self.period * x) - (self.phaseShift/self.period)) + self.verticalShift
    }
}

//: Cosine

class Cosine : GraphableEquation
{
    var period: CGFloat
    var amplitude: CGFloat
    var phaseShift: CGFloat
    var verticalShift: CGFloat
    
    // MARK: - Initializers
    
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
    
    var drawingColor: UIColor = UIColor.black
    var drawingDomain: Range<CGFloat>?
    
    // MARK: - Equation
    
    func compute(at x: CGFloat) -> CGFloat
    {
        return amplitude * cos((self.period * x) - (self.phaseShift/self.period)) + self.verticalShift
    }
}

/*:
 
 #  Graphing Some Functions
 
 Here's an example of graphing a few equations on a graph. Try playing with some of the lines below to see what the graph draws. You can also implement your own equations.
 
 */

func demo()
{
    let graph = GraphView(withSmallerXBound: -15.0, largerXBound: 15.0, andInterval: 0.5)
    /*
     If you're graphing many things at once, use this 
     to prevent constant re-computation and rendering
     as you work.
    */
    graph.autoUpdatesAfterAddingEquation = false 

    let parabola = Exponential(exponent: 2)
    let line = Line(slope: 1.0, offset: 3.0)
    let sine = Sine()
    let cosine = Cosine(period: 1.0, amplitude: 1.0, phaseShift: -1.0, verticalShift: 0.0)
    cosine.drawingColor = UIColor(red: 0.7, green: 0.2, blue: 0.2, alpha: 1.0)
    cosine.drawingDomain = Range(uncheckedBounds: (lower: 0.0, upper: 10.0))

    graph.addEquation(parabola)
    graph.addEquation(cosine)
    graph.addEquation(line)
    
    //: You can add these yourself.
    graph.addEquation(sine)
    
    // Necessary only if `autoUpdatesAfterAddingEquation` is `false`.
    graph.setNeedsDisplay()
    
    PlaygroundPage.current.liveView = graph
}

demo()

