//
//  ColorPalette.swift
//  WWDC19Proj
//
//  Created by Alex Hoppen on 19.03.19.
//  Copyright © 2019 Alex Hoppen. All rights reserved.
//

import UIKit

public struct ColorPalette<ColorType: Color>: ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = UIColor
    
    let colors: [ColorType]
    
    init(_ colors: [ColorType]) {
        self.colors = colors
    }
    
    init(_ colors: [UIColor]) {
        self.init(colors.map(ColorType.init))
    }
    
    public init(arrayLiteral elements: UIColor...) {
        self.init(elements)
    }
    
    func findClosestColor(to: ColorType) -> ColorType {
        let closestIndex = findClosestColorIndex(to: to)
        return colors[closestIndex]
    }
    
    func findClosestColorIndex(to: ColorType) -> Int {
        var currentDistance: Float = Float.infinity
        var currentIndex: Int = 0
        for (index, color) in colors.enumerated() {
            let distance = color.distance(to: to)
            if distance < currentDistance {
                currentDistance = distance
                currentIndex = index
            }
        }
        return currentIndex
    }
}
