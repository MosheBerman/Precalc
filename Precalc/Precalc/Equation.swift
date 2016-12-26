//
//  Equation.swift
//  Precalc
//
//  Created by Moshe Berman on 12/25/16.
//  Copyright © 2016 Moshe Berman. All rights reserved.
//

import CoreGraphics

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
    func compute(withInterval interval: CGFloat, between x1: CGFloat, and x2: CGFloat) -> [Coordinate]
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
}

