//
//  Utils.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 20.03.19.
//

import UIKit

let defaultImageName = "Yosemite 1.jpeg"

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

func ** (_ base: Double, _ exp: Double) -> Double {
    return pow(base, exp)
}

func ** (_ base: Float, _ exp: Float) -> Float {
    return pow(base, exp)
}

extension UIImage {
    @discardableResult
    func writeRawIntoBuffer(_ buffer: UnsafeMutableBufferPointer<RgbColor>, size: Size) -> CGContext {
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerRow = 4 * size.width
        let bitsPerComponent = 8
        let context = CGContext(data: buffer.baseAddress,
                                width: size.width,
                                height: size.height,
                                bitsPerComponent: bitsPerComponent,
                                bytesPerRow: bytesPerRow,
                                space: colorSpace,
                                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue)!
        
        // Draw the image into the memory buffer
        context.draw(self.cgImage!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        context.makeImage()
        
        return context
    }
}

func squaredEucledianDistance(_ components: Int...) -> Int {
    var squaredSum: Int = 0
    for component in components {
        squaredSum += component * component
    }
    return squaredSum
}

func squaredEucledianDistance(_ components: Float...) -> Float {
    var squaredSum: Float = 0
    for component in components {
        squaredSum += component * component
    }
    return squaredSum
}

struct Size {
    let width: Int
    let height: Int
    
    init(_ cgsize: CGSize) {
        width = Int(cgsize.width)
        height = Int(cgsize.height)
    }
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}
