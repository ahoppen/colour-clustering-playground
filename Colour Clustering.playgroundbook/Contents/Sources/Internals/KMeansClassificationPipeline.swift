//
//  MetalThings.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 20.03.19.
//

import UIKit
import Metal
import Dispatch

extension UnsafeBufferPointer {
    func getMetalBuffer(device: MTLDevice) -> MTLBuffer {
        return device.makeBuffer(bytes: self.baseAddress!,
                                 length: self.count * MemoryLayout<Element>.size,
                                 options: MTLResourceOptions())!
    }
}

public class KMeansClassificationPipeline<ColorType: Color> {
    
    public var device: MTLDevice
    private var commandQueue: MTLCommandQueue
    private var library: MTLLibrary!

    enum FunctionName {
        static var rgbToLab: String {
            return "rgbToLab"
        }
        static var labToRgb: String {
            return "labToRgb"
        }
        static var pickColorFromPalette: String {
            if ColorType.self == RgbColor.self {
                return "pickColorFromPalette"
            } else if ColorType.self == LabColor.self {
                return "pickColorFromPaletteLab"
            } else {
                fatalError()
            }
        }
        static var classifyPixels: String {
            if ColorType.self == RgbColor.self {
                return "classifyPixels"
            } else if ColorType.self == LabColor.self {
                return "classifyPixelsLab"
            } else {
                fatalError()
            }
        }
        static var aggregateClusterMeans: String {
            if ColorType.self == RgbColor.self {
                return "aggregateClusterMeans"
            } else if ColorType.self == LabColor.self {
                return "aggregateClusterMeansLab"
            } else {
                fatalError()
            }
        }
    }
    
    init() {
        device = MTLCreateSystemDefaultDevice()!
        commandQueue = device.makeCommandQueue()!
        if let defaultLibrary = device.makeDefaultLibrary() {
            library = defaultLibrary
        } else {
           let metalUrl = Bundle.main.url(forResource: "Transform", withExtension: "metal")!
            let contents = try! String(contentsOf: metalUrl)
            library = try! device.makeLibrary(source: contents, options: nil)
        }
    }
    
    func convertFromRgbBuffer(rgbBuffer: UnsafeBufferPointer<RgbColor>, destination: UnsafeMutableBufferPointer<ColorType>) {
        if ColorType.self == RgbColor.self {
            memcpy(destination.baseAddress!, rgbBuffer.baseAddress!, rgbBuffer.count * MemoryLayout<UInt32>.size)
        } else if ColorType.self == LabColor.self {
            let mtlRgbBuffer = rgbBuffer.getMetalBuffer(device: device)
            let mtlOutputBuffer = device.makeBuffer(length: destination.count * MemoryLayout<ColorType>.size, options: MTLResourceOptions())!
            
            let kernelFunction = library.makeFunction(name: FunctionName.rgbToLab)!
            let pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
            
            let commandBuffer = commandQueue.makeCommandBuffer()!
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
            
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setBuffer(mtlRgbBuffer, offset: 0, index: 0)
            commandEncoder.setBuffer(mtlOutputBuffer, offset: 0, index: 1)
            
            let threadsInThreadGroup = MTLSize(width: 128, height: 1, depth: 1)
            let threadGroups = MTLSize(width: rgbBuffer.count / threadsInThreadGroup.width, height: 1, depth: 1)
            
            commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsInThreadGroup)
            commandEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            
            memcpy(destination.baseAddress!, mtlOutputBuffer.contents(), mtlOutputBuffer.length)
        } else {
            fatalError()
        }
    }
    
    func convertToRgbBuffer(from: UnsafeBufferPointer<ColorType>, rgbBuffer: UnsafeMutableBufferPointer<RgbColor>) {
        if ColorType.self == RgbColor.self {
            memcpy(rgbBuffer.baseAddress!, from.baseAddress!, from.count * MemoryLayout<ColorType>.size)
        } else {
            let mtlInputBuffer = from.getMetalBuffer(device: device)
            let mtlOutputBuffer = device.makeBuffer(length: rgbBuffer.count * MemoryLayout<RgbColor>.size, options: MTLResourceOptions())!
            
            let kernelFunction = library.makeFunction(name: FunctionName.labToRgb)!
            let pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
            
            let commandBuffer = commandQueue.makeCommandBuffer()!
            let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
            
            commandEncoder.setComputePipelineState(pipelineState)
            commandEncoder.setBuffer(mtlInputBuffer, offset: 0, index: 0)
            commandEncoder.setBuffer(mtlOutputBuffer, offset: 0, index: 1)
            
            let threadsInThreadGroup = MTLSize(width: 64, height: 1, depth: 1)
            let threadGroups = MTLSize(width: from.count / threadsInThreadGroup.width, height: 1, depth: 1)
            
            commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsInThreadGroup)
            commandEncoder.endEncoding()
            commandBuffer.commit()
            commandBuffer.waitUntilCompleted()
            
            memcpy(rgbBuffer.baseAddress!, mtlOutputBuffer.contents(), mtlOutputBuffer.length)
        }
    }
    
    func classifyPixels(image: MTLBuffer, size: Size, colorPalette: UnsafeBufferPointer<ColorType>) {
        let kernelFunction = library.makeFunction(name: FunctionName.classifyPixels)!
        let pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        
        let colorPaletteMtlBuffer = colorPalette.getMetalBuffer(device: device)
        
        let colorPaletteSize = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 1)
        colorPaletteSize[0] = UInt8(colorPalette.count);
        defer {
            colorPaletteSize.deallocate()
        }
        let colorPaletteSizeMtlBuffer = device.makeBuffer(bytes: colorPaletteSize.baseAddress!, length: 1, options: MTLResourceOptions())!
        
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setBuffer(image, offset: 0, index: 0)
        commandEncoder.setBuffer(colorPaletteMtlBuffer, offset: 0, index: 1)
        commandEncoder.setBuffer(colorPaletteSizeMtlBuffer, offset: 0, index: 2)
        
        let threadsInThreadGroup = MTLSize(width: 128, height: 1, depth: 1)
        let threadGroups = MTLSize(width: size.width * size.height / threadsInThreadGroup.width, height: 1, depth: 1)
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsInThreadGroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    private func readAggregationResultLab(aggregationMtlBuffer: MTLBuffer, numberOfClusters: Int, numThreadGroups: Int) -> [LabColor] {
        let aggregationBuffer = UnsafeBufferPointer<LabColor>(start: aggregationMtlBuffer.contents().assumingMemoryBound(to: LabColor.self),
                                                              count: aggregationMtlBuffer.length / MemoryLayout<LabColor>.size)
        
        // Write the new cluster means to a memory buffer because array doesn't seem to be thread-safe for writing to different offsets
        var newClusterMeansBuffer = UnsafeMutableBufferPointer<(first: Float, second: Float, third: Float)>.allocate(capacity: numberOfClusters)
        defer {
            newClusterMeansBuffer.deallocate()
        }
        
        let queue = DispatchQueue(label: "ClusterAggregation", qos: .userInteractive, attributes: [.concurrent], autoreleaseFrequency: .never, target: nil)
        for cluster in 0..<numberOfClusters {
            queue.async {
                var count: Float = 0
                var firstSum: Float = 0
                var secondSum: Float = 0
                var thirdSum: Float = 0
                
                let clusterOffset = cluster
                
                for threadId in 0..<numThreadGroups {
                    let threadOffset = numberOfClusters * threadId
                    
                    firstSum += aggregationBuffer[threadOffset + clusterOffset].firstComponent
                    secondSum += aggregationBuffer[threadOffset + clusterOffset].secondComponent
                    thirdSum += aggregationBuffer[threadOffset + clusterOffset].thirdComponent
                    count += aggregationBuffer[threadOffset + clusterOffset].dataComponent
                }
                
                if (count == 0) {
                    count = 1
                }
                
                newClusterMeansBuffer[cluster] = (firstSum / Float(count), secondSum / Float(count), thirdSum / Float(count))
            }
        }
        queue.sync(flags: [.barrier]) { () -> Void in
            // Do nothing, simply wait for all items in the queue to finish
        }
        
        var newClusterMeans = [LabColor]()
        for cluster in 0..<numberOfClusters {
            let color = LabColor(firstComponent: newClusterMeansBuffer[cluster].first,
                                 secondComponent: newClusterMeansBuffer[cluster].second,
                                 thirdComponent: newClusterMeansBuffer[cluster].third,
                                 dataComponent: 0)
            
            newClusterMeans.append(color)
        }
        
        return newClusterMeans
    }
    
    private func readAggregationResultRgb(aggregationMtlBuffer: MTLBuffer, numberOfClusters: Int, numThreadGroups: Int) -> [RgbColor] {
        let aggregationBuffer = UnsafeBufferPointer<UInt32>(start: aggregationMtlBuffer.contents().assumingMemoryBound(to: UInt32.self),
                                                            count: aggregationMtlBuffer.length / MemoryLayout<UInt32>.size)
        
        // Write the new cluster means to a memory buffer because array doesn't seem to be thread-safe for writing to different offsets
        var newClusterMeansBuffer = UnsafeMutableBufferPointer<(red: Int, green: Int, blue: Int)>.allocate(capacity: numberOfClusters)
        defer {
            newClusterMeansBuffer.deallocate()
        }
        
        let queue = DispatchQueue(label: "ClusterAggregation", qos: .userInteractive, attributes: [.concurrent], autoreleaseFrequency: .never, target: nil)
        for cluster in 0..<numberOfClusters {
            queue.async {
                var count: Int = 0
                var redSum: Int = 0
                var greenSum: Int = 0
                var blueSum: Int = 0
                
                let clusterOffset = cluster * 4
                
                for threadId in 0..<numThreadGroups {
                    let threadOffset = numberOfClusters * 4 * threadId
                    
                    redSum += Int(aggregationBuffer[threadOffset + clusterOffset + 0])
                    greenSum += Int(aggregationBuffer[threadOffset + clusterOffset + 1])
                    blueSum += Int(aggregationBuffer[threadOffset + clusterOffset + 2])
                    count += Int(aggregationBuffer[threadOffset + clusterOffset + 3])
                }
                
                if (count == 0) {
                    count = 1
                }
                
                newClusterMeansBuffer[cluster] = (redSum / count, greenSum / count, blueSum / count)
            }
        }
        queue.sync(flags: [.barrier]) { () -> Void in
            // Do nothing, simply wait for all items in the queue to finish
        }
        
        var newClusterMeans = [RgbColor]()
        for cluster in 0..<numberOfClusters {
            let color = RgbColor(red: UInt8(newClusterMeansBuffer[cluster].red),
                                 green: UInt8(newClusterMeansBuffer[cluster].green),
                                 blue: UInt8(newClusterMeansBuffer[cluster].blue),
                                 data: 255)
            
            newClusterMeans.append(color)
        }
        
        return newClusterMeans
    }
    
    private func computeNewClusterMeans(classifiedImage: MTLBuffer, size: Size, numberOfClusters: Int) -> [ColorType] {
        let kernelFunction = library.makeFunction(name: FunctionName.aggregateClusterMeans)!
        let pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        
        let threadsPerGroup = 64
        let numThreadGroups = size.width * size.height / threadsPerGroup
        
        let bufferSize = numThreadGroups /* each thread in a thread group aggregates on its own */ *
            4 /* color channels + count channel */ *
            MemoryLayout<ColorType>.size /* size of each value */ *
        numberOfClusters
        let aggregationMtlBuffer = device.makeBuffer(length: bufferSize, options: MTLResourceOptions())!
        
        let numberOfClustersBuffer = UnsafeMutableBufferPointer<UInt8>.allocate(capacity: 1)
        defer {
            numberOfClustersBuffer.deallocate()
        }
        numberOfClustersBuffer[0] = UInt8(numberOfClusters)
        let numberOfClustersMtlBuffer = device.makeBuffer(bytes: numberOfClustersBuffer.baseAddress!,
                                                          length: 1,
                                                          options: MTLResourceOptions())!
        
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setBuffer(classifiedImage, offset: 0, index: 0)
        commandEncoder.setBuffer(aggregationMtlBuffer, offset: 0, index: 1)
        commandEncoder.setBuffer(numberOfClustersMtlBuffer, offset: 0, index: 2)
        
        let threadsInThreadGroup = MTLSize(width: threadsPerGroup, height: 1, depth: 1)
        let threadGroups = MTLSize(width: numThreadGroups, height: 1, depth: 1)
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsInThreadGroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
        
        if ColorType.self == RgbColor.self {
            return readAggregationResultRgb(aggregationMtlBuffer: aggregationMtlBuffer, numberOfClusters: numberOfClusters, numThreadGroups: numThreadGroups) as! [ColorType]
        } else if ColorType.self == LabColor.self {
            return readAggregationResultLab(aggregationMtlBuffer: aggregationMtlBuffer, numberOfClusters: numberOfClusters, numThreadGroups: numThreadGroups) as! [ColorType]
        } else {
            fatalError()
        }
    }
    
    func pickColorFromPalette(image: MTLBuffer, size: Size, colorPalette: UnsafeBufferPointer<ColorType>) {
        let kernelFunction = library.makeFunction(name: FunctionName.pickColorFromPalette)!
        
        let pipelineState = try! device.makeComputePipelineState(function: kernelFunction)
        
        let commandBuffer = commandQueue.makeCommandBuffer()!
        let commandEncoder = commandBuffer.makeComputeCommandEncoder()!
        
        let colorPaletteMtlBuffer = colorPalette.getMetalBuffer(device: device)
        
        commandEncoder.setComputePipelineState(pipelineState)
        commandEncoder.setBuffer(image, offset: 0, index: 0)
        commandEncoder.setBuffer(colorPaletteMtlBuffer, offset: 0, index: 1)
        
        let threadsInThreadGroup = MTLSize(width: 64, height: 1, depth: 1)
        let threadGroups = MTLSize(width: size.width * size.height / threadsInThreadGroup.width, height: 1, depth: 1)
        
        commandEncoder.dispatchThreadgroups(threadGroups, threadsPerThreadgroup: threadsInThreadGroup)
        commandEncoder.endEncoding()
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()
    }
    
    private func writeClusterMeansToBuffer(_ clusterMeans: [ColorType], buffer: UnsafeMutableBufferPointer<ColorType>) {
        for (index, color) in clusterMeans.enumerated() {
            buffer[index] = color
        }
    }
    
    func readColorPalette(from imageBuffer: UnsafeBufferPointer<ColorType>, into colorPalette: UnsafeMutableBufferPointer<ColorType>) {
        var strideSteps = colorPalette.count - 1
        if strideSteps == 0 {
            strideSteps = 1
        }
        let initStride = (imageBuffer.count - 1) / strideSteps
        
        // Pick initial cluster from even parts of the image, hoping they are
        // somewhat different
        for i in 0..<colorPalette.count {
            colorPalette[i] = imageBuffer[i * initStride]
        }
    }
    
    func convertMetalBufferToUIImage(_ mtlImageBuffer: MTLBuffer, imageSize: Size) -> UIImage {
        let outputBuffer = UnsafeBufferPointer<ColorType>(start: mtlImageBuffer.contents().assumingMemoryBound(to: ColorType.self),
                                                          count: mtlImageBuffer.length / MemoryLayout<ColorType>.size)
        
        let outputRgbBuffer = UnsafeMutableBufferPointer<RgbColor>.allocate(capacity: outputBuffer.count)
        defer { outputRgbBuffer.deallocate() }
        convertToRgbBuffer(from: outputBuffer, rgbBuffer: outputRgbBuffer)
        
        let cgImageDataProvider = CGDataProvider(data: Data(buffer: outputRgbBuffer) as CFData)!
        
        let cgImage = CGImage(width: imageSize.width,
                              height: imageSize.height,
                              bitsPerComponent: 8,
                              bitsPerPixel: 32,
                              bytesPerRow: 4 * imageSize.width,
                              space: CGColorSpace(name: CGColorSpace.sRGB)!,
                              bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue),
                              provider: cgImageDataProvider,
                              decode: nil,
                              shouldInterpolate: false,
                              intent: CGColorRenderingIntent.defaultIntent)!
        
        return UIImage(cgImage: cgImage)
    }
    
    func convertColorPaletteBufferToPalette(_ colorPaletteBuffer: UnsafeBufferPointer<ColorType>) -> ColorPalette<ColorType> {
        var colors = [ColorType]()
        
        for i in 0..<colorPaletteBuffer.count {
            colors.append(colorPaletteBuffer[i])
        }
        
        return ColorPalette(colors)
    }
    
    func runKMeansIteration(mtlImageBuffer: MTLBuffer, imageSize: Size, colorPalette: UnsafeMutableBufferPointer<ColorType>) {
        classifyPixels(image: mtlImageBuffer, size: imageSize, colorPalette: UnsafeBufferPointer<ColorType>(colorPalette))
        let newClusterMeans = computeNewClusterMeans(classifiedImage: mtlImageBuffer, size: imageSize, numberOfClusters: colorPalette.count)
        writeClusterMeansToBuffer(newClusterMeans, buffer: colorPalette)
        
    }
    
    func runKMeans(imageBuffer: UnsafeMutableBufferPointer<ColorType>, imageSize: Size, numColors clusters: Int, rounds: Int) -> (UIImage, ColorPalette<ColorType>) {
        let colorPalette = UnsafeMutableBufferPointer<ColorType>.allocate(capacity: clusters)
        defer { colorPalette.deallocate() }
        
        readColorPalette(from: UnsafeBufferPointer<ColorType>(imageBuffer), into: colorPalette)
        
        let mtlImageBuffer = UnsafeBufferPointer<ColorType>(imageBuffer).getMetalBuffer(device: device)
        
        
        for _ in 0..<rounds {
            runKMeansIteration(mtlImageBuffer: mtlImageBuffer, imageSize: imageSize, colorPalette: colorPalette)
        }

        pickColorFromPalette(image: mtlImageBuffer,
                             size: imageSize,
                             colorPalette: UnsafeBufferPointer<ColorType>(colorPalette))
        
        let resultImage = convertMetalBufferToUIImage(mtlImageBuffer, imageSize: imageSize)
        let resultColorPalette = convertColorPaletteBufferToPalette(UnsafeBufferPointer<ColorType>(colorPalette))
        
        
        return (resultImage, resultColorPalette)
    }

}
