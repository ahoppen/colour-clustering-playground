//
//  ColorClusteringState.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 21.03.19.
//

import UIKit
import Metal

public class ColorClusteringState<ColorType: Color> {
    let pipeline = KMeansClassificationPipeline<ColorType>()
    private let colorPaletteBuffer: UnsafeMutableBufferPointer<ColorType>
    public let originalImageBuffer: UnsafeBufferPointer<ColorType>
    private let workingImageMtlBuffer: MTLBuffer
    private let imageSize: Size
    
    public var resultImage: UIImage {
        let mtlBuffer = pipeline.device.makeBuffer(bytes: workingImageMtlBuffer.contents(), length: workingImageMtlBuffer.length, options: MTLResourceOptions())!
        
        pipeline.pickColorFromPalette(image: mtlBuffer, size: imageSize, colorPalette: UnsafeBufferPointer<ColorType>(colorPaletteBuffer))
        
        let result =  pipeline.convertMetalBufferToUIImage(mtlBuffer, imageSize: imageSize)
        return result
    }
    
    public var colorPalette: ColorPalette<ColorType> {
        return pipeline.convertColorPaletteBufferToPalette(UnsafeBufferPointer<ColorType>(colorPaletteBuffer))
    }
    
    public init(image: UIImage, numColors clusters: Int) {
        imageSize = Size(image.size)
        
        let originalRgbImageBuffer = UnsafeMutableBufferPointer<RgbColor>.allocate(capacity: imageSize.width * imageSize.height)
        defer { originalRgbImageBuffer.deallocate() }
        image.writeRawIntoBuffer(originalRgbImageBuffer, size: imageSize)
        
        let mutableOriginalImageBuffer = UnsafeMutableBufferPointer<ColorType>.allocate(capacity: imageSize.width * imageSize.height)
        pipeline.convertFromRgbBuffer(rgbBuffer: UnsafeBufferPointer<RgbColor>(originalRgbImageBuffer), destination: mutableOriginalImageBuffer)
        
        originalImageBuffer = UnsafeBufferPointer<ColorType>(mutableOriginalImageBuffer)
        
        workingImageMtlBuffer = originalImageBuffer.getMetalBuffer(device: pipeline.device)
        
        colorPaletteBuffer = UnsafeMutableBufferPointer<ColorType>.allocate(capacity: clusters)
        pipeline.readColorPalette(from: originalImageBuffer, into: colorPaletteBuffer)
        
        pipeline.classifyPixels(image: workingImageMtlBuffer, size: imageSize, colorPalette: UnsafeBufferPointer<ColorType>(colorPaletteBuffer))
    }
    
    deinit {
        colorPaletteBuffer.deallocate()
        originalImageBuffer.deallocate()
    }
    
    public func doKMeansRound() {
        pipeline.runKMeansIteration(mtlImageBuffer: workingImageMtlBuffer, imageSize: imageSize, colorPalette: colorPaletteBuffer)
    }
}
