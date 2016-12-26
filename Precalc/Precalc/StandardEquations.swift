//
//  StandardEquations.swift
//  Precalc
//
//  Created by Moshe Berman on 12/25/16.
//  Copyright © 2016 Moshe Berman. All rights reserved.
//

import Foundation

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
    
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat) -> [Coordinate]
    {
        var coordinates : [Coordinate] = []
        var x = x1
        
        while x  <= x2
        {
            let y = pow(x, exponent)
            coordinates.append(Coordinate(x: x, y: y))
            x = x + interval
        }
        
        return coordinates
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
    
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat) -> [Coordinate]
    {
        var coordinates : [Coordinate] = []
        
        var x = x1
        
        while x <= x2
        {
            let y = (self.m * x) + self.b
            
            coordinates.append(Coordinate(x: x, y: y))
            
            x = x + interval
        }
        
        return coordinates
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
    
    // MARK: - Equation
    
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat) -> [Coordinate]
    {
        var coordinates : [Coordinate] = []
        
        var x = x1
        
        while x <= x2
        {
            let y : CGFloat
            
            y = amplitude * sin((self.period * x) - (self.phaseShift/self.period)) + self.verticalShift
            
            coordinates.append(Coordinate(x: x, y: y))
            
            x = x + interval
        }
        
        return coordinates
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
    
    // MARK: - Equation
    
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat) -> [Coordinate]
    {
        
        var coordinates : [Coordinate] = []
        
        var x = x1
        
        while x <= x2
        {
            let y : CGFloat
            
            y = amplitude * cos((self.period * x) - (self.phaseShift/self.period)) + self.verticalShift
            
            coordinates.append(Coordinate(x: x, y: y))
            
            x = x + interval
        }
        
        return coordinates
    }
}
