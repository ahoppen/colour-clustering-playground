//
//  Color.swift
//  WWDC19Proj
//
//  Created by Alex Hoppen on 19.03.19.
//  Copyright © 2019 Alex Hoppen. All rights reserved.
//

import UIKit

public protocol Color {
    associatedtype ComponentType: Numeric, Comparable
    
    var firstComponent: ComponentType { get }
    var secondComponent: ComponentType { get }
    var thirdComponent: ComponentType { get }
    var dataComponent: ComponentType { get }
    
    var normalizedComponents: (CGFloat, CGFloat, CGFloat) { get }
    
    var rgb: (red: UInt8, green: UInt8, blue: UInt8) { get }
    
    var uicolor: UIColor { get }
    
    init(_: UIColor)
    init(firstComponent: ComponentType, secondComponent: ComponentType, thirdComponent: ComponentType, dataComponent: ComponentType)
    init(red: UInt8, green: UInt8, blue: UInt8, data: UInt8)
    
    func distance(to: Self) -> Float
}

public extension Color {
    public init(_ uicolor: UIColor) {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        uicolor.getRed(&red, green: &green, blue: &blue, alpha: nil)
        
        self.init(red: UInt8(red * 255),
                  green: UInt8(green * 255),
                  blue: UInt8(blue * 255),
                  data: 0)
    }
    
    public var uicolor: UIColor  {
        let (red, green, blue) = rgb
        return UIColor(red: CGFloat(red) / 255,
                       green: CGFloat(green) / 255,
                       blue: CGFloat(blue) / 255,
                       alpha: 1)
    }
}

public extension Color where ComponentType == UInt8 {
    public func distance(to other: Self) -> Float {
        return Float(squaredEucledianDistance(
            Int(self.firstComponent) - Int(other.firstComponent),
            Int(self.secondComponent) - Int(other.secondComponent),
            Int(self.thirdComponent) - Int(other.thirdComponent)
        ))
    }
}

public extension Color where ComponentType == Float {
    public func distance(to other: Self) -> Float {
        return squaredEucledianDistance(
            self.firstComponent - other.firstComponent,
            self.secondComponent - other.secondComponent,
            self.thirdComponent - other.thirdComponent
        )
    }
}

public struct RgbColor: Color {
    
    let red: UInt8
    let green: UInt8
    let blue: UInt8
    let data: UInt8
    
    public var firstComponent: UInt8 { return red }
    public var secondComponent: UInt8 { return green }
    public var thirdComponent: UInt8 { return blue }
    public var dataComponent: UInt8 { return data }
    
    public var normalizedComponents: (CGFloat, CGFloat, CGFloat) {
        return (
            CGFloat(firstComponent) / 255,
            CGFloat(secondComponent) / 255,
            CGFloat(thirdComponent) / 255
        )
    }
    
    public var rgb: (red: UInt8, green: UInt8, blue: UInt8) {
        return (red, green, blue)
    }
    
    public init(firstComponent: UInt8, secondComponent: UInt8, thirdComponent: UInt8, dataComponent: UInt8) {
        self.init(red: firstComponent, green: secondComponent, blue: thirdComponent, data: dataComponent)
    }
    
    public init(red: UInt8, green: UInt8, blue: UInt8, data: UInt8) {
        self.red = red
        self.green = green
        self.blue = blue
        self.data = data
    }
}

public enum ColorConversion {
    private static let referenceX: Float = 95.05
    private static let referenceY: Float = 100
    private static let referenceZ: Float = 108.9
    
    private static func rgbComponentNormalization(_ value: Float) -> Float {
        if (value > 0.04045) {
            return 100 * ((value + 0.055) / 1.055) ** 2.4
        } else {
            return value / 12.92 * 100
        }
    }
    
    private static func reverseRgbComponentNormalization(_ value: Float) -> Float {
        if (value > 0.0031308) {
            return 1.055 * ( value ** ( 1 / 2.4 ) ) - 0.055
        } else {
            return 12.92 * value
        }
    }
    
    public static func rgbToXYZ(red: Float, green: Float, blue: Float) -> (x: Float, y: Float, z: Float) {
        let normalizedRed = rgbComponentNormalization(red)
        let normalizedBlue = rgbComponentNormalization(blue)
        let normalizedGreen = rgbComponentNormalization(green)
        
        let x = normalizedRed * 0.4124 + normalizedGreen * 0.3576 + normalizedBlue * 0.1805
        let y = normalizedRed * 0.2126 + normalizedGreen * 0.7152 + normalizedBlue * 0.0722
        let z = normalizedRed * 0.0193 + normalizedGreen * 0.1192 + normalizedBlue * 0.9505
        
        return (x, y, z)
    }
    
    private static func normalizeXYZComopnent(value: Float) -> Float {
        if (value > 0.008856) {
            return value ** ( 1/3 )
        } else {
            return ( 7.787 * value ) + ( 16 / 116 )
        }
    }
    
    private static func denormalizeXYZComponent(_ value: Float) -> Float {
        if (value  ** 3  > 0.008856) {
            return value ** 3
        } else {
            return (value - 16 / 116) / 7.787
        }
    }
    
    public static func xyzToLab(x: Float, y: Float, z: Float) -> (l: Float, a: Float, b: Float) {
        let normalizedX = x / referenceX
        let normalizedY = y / referenceY
        let normalizedZ = z / referenceZ
        
        let newX = normalizeXYZComopnent(value: normalizedX)
        let newY = normalizeXYZComopnent(value: normalizedY)
        let newZ = normalizeXYZComopnent(value: normalizedZ)
    
        let l = ( 116 * newY ) - 16
        let a = 500 * ( newX - newY )
        let b = 200 * ( newY - newZ )
        return (l, a, b)
        
//        let ka = (175.0 / 198.04) * (referenceY + referenceX)
//        let kb = (70.0 / 218.11) * (referenceY + referenceZ)
//
//        let sqrtY = sqrt(y / referenceY)
//        let l = 100.0 * sqrt(y / referenceY)
//        let a = ka * (((x / referenceX) - (y / referenceY)) / sqrtY)
//        let b = kb * (((y / referenceY) - (z / referenceZ)) / sqrtY)
//
//        return (l, a, b)
    }
    
    public static func rgbToLab(red: Float, green: Float, blue: Float) -> (l: Float, a: Float, b: Float) {
        let (x, y, z) = rgbToXYZ(red: red, green: green, blue: blue)
        return xyzToLab(x:x, y:y, z:z)
    }
    
    public static func labToXyz(l: Float, a: Float, b: Float) -> (x: Float, y: Float, z: Float) {
        var y = (l + 16) / 116
        var x = a / 500 + y
        var z = y - b / 200
        
        x = denormalizeXYZComponent(x) * referenceX
        y = denormalizeXYZComponent(y) * referenceY
        z = denormalizeXYZComponent(z) * referenceZ
        
        return (x, y, z)
        
//        let ka = (175.0 / 198.04) * (referenceY + referenceX)
//        let kb = (70.0 / 218.11) * (referenceY + referenceZ)
//
//        let y = ((l / referenceY ) ** 2 ) * 100.0
//        let sqrtY = sqrt(y / referenceY)
//        let x = (a / ka * sqrtY + (y / referenceY)) * referenceX
//        let z = -(b / kb * sqrtY - (y / referenceY)) * referenceZ
//
//        return (x, y, z)
    }
    
    public static func xyzToRgb(x: Float, y: Float, z: Float) -> (red: Float, green: Float, blue: Float) {
        let normalizedX = x / 100
        let normalizedY = y / 100
        let normalizedZ = z / 100
        
        var red = normalizedX *  3.2406 + normalizedY * -1.5372 + normalizedZ * -0.4986
        var green = normalizedX * -0.9689 + normalizedY *  1.8758 + normalizedZ *  0.0415
        var blue = normalizedX *  0.0557 + normalizedY * -0.2040 + normalizedZ *  1.0570
        
        red = reverseRgbComponentNormalization(red)
        green = reverseRgbComponentNormalization(green)
        blue = reverseRgbComponentNormalization(blue)
        
        return (red, green, blue)
    }
    
    public static func labToRgb(l: Float, a: Float, b: Float) -> (red: Float, green: Float, blue: Float) {
        let (x, y, z) = labToXyz(l: l, a: a, b: b)
        return xyzToRgb(x:x, y:y, z:z)
    }
}

public struct LabColor: Color {
    let l: Float
    let a: Float
    let b: Float
    let data: Float
    
    public var firstComponent: Float {
        return l
    }
    public var secondComponent: Float {
        return a
    }
    public var thirdComponent: Float {
        return b
    }
    public var dataComponent: Float {
        return data
    }
    
    public var normalizedComponents: (CGFloat, CGFloat, CGFloat) {
        return (
            CGFloat(firstComponent) / 100,
            (CGFloat(secondComponent) + 128) / 256,
            (CGFloat(thirdComponent) + 128) / 256
        )
    }
    
    public var rgb: (red: UInt8, green: UInt8, blue: UInt8) {
        let (red, green, blue) = ColorConversion.labToRgb(l: l, a: a, b: b)
        return (UInt8(red * 255), UInt8(green * 255), UInt8(blue * 255))
    }
    
    public init(firstComponent: Float, secondComponent: Float, thirdComponent: Float, dataComponent: Float) {
        l = firstComponent
        a = secondComponent
        b = thirdComponent
        data = dataComponent
    }
    
    public init(red: UInt8, green: UInt8, blue: UInt8, data: UInt8) {
        let (l, a, b) = ColorConversion.rgbToLab(red: Float(red) / 255,
                                                 green: Float(green) / 255,
                                                 blue: Float(blue) / 255)
        self.l = l
        self.a = a
        self.b = b
        self.data = Float(data)
    }
}
