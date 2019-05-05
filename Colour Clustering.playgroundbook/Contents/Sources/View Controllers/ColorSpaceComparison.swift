//
//  ColorClustering.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 21.03.19.
//

import UIKit
import PlaygroundSupport
import SceneKit

public class ColorSpaceComparisonViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    @IBOutlet var rgbImageView: UIImageView!
    @IBOutlet var rgbSceneView: SCNView!
    @IBOutlet var labImageView: UIImageView!
    @IBOutlet var labSceneView: SCNView!
    @IBOutlet var debugLabel: UILabel!
    var originalImage: UIImage!
    var rgbState: ColorClusteringState<RgbColor>?
    var labState: ColorClusteringState<LabColor>?
    let autorun = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        rgbSceneView.backgroundColor = UIColor.clear
        labSceneView.backgroundColor = UIColor.clear
        
        originalImage = UIImage(named: defaultImageName)!.resize(to: CGSize(width: 800, height: 600))
        
        reset()
        readValuesFromKeyValueStore()
        updateScreen()
        
        if autorun {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.pickInitialColors(4)
                self.updateScreen()
            }
        }
    }
    
    private func pickInitialColors(_ numColors: Int) {
        rgbState = ColorClusteringState(image: originalImage, numColors: numColors)
        labState = ColorClusteringState(image: originalImage, numColors: numColors)
        
        if autorun {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.doKMeansIteration()
                self.updateScreen()
            }
        }
    }
    
    private func doKMeansIteration() {
        rgbState?.doKMeansRound()
        labState?.doKMeansRound()
        if autorun {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
                self.doKMeansIteration()
                self.updateScreen()
            }
        }
    }
    
    private func reset() {
        rgbImageView.image = originalImage
        labImageView.image = originalImage
        rgbState = nil
        labState = nil
        rgbSceneView.scene = nil
        labSceneView.scene = nil
    }
    
    private func updateScreenSide<ColorType>(state: ColorClusteringState<ColorType>?, sceneView: SCNView, imageView: UIImageView) {
        let imageBuffer: UnsafeBufferPointer<ColorType>
        let deallocationNeeded: Bool
        if let state = state {
            // Simply reuse the buffer the state already has
            imageBuffer = state.originalImageBuffer
            deallocationNeeded = false
        } else {
            // Build up a new buffer
            let imageSize = Size(originalImage.size)

            let originalRgbImageBuffer = UnsafeMutableBufferPointer<RgbColor>.allocate(capacity: imageSize.width * imageSize.height)
            defer { originalRgbImageBuffer.deallocate() }
            deallocationNeeded = true
            originalImage.writeRawIntoBuffer(originalRgbImageBuffer, size: imageSize)
            
            let pipeline = KMeansClassificationPipeline<ColorType>()
            
            let mutableOriginalImageBuffer = UnsafeMutableBufferPointer<ColorType>.allocate(capacity: imageSize.width * imageSize.height)
            pipeline.convertFromRgbBuffer(rgbBuffer: UnsafeBufferPointer<RgbColor>(originalRgbImageBuffer), destination: mutableOriginalImageBuffer)
            

            imageBuffer = UnsafeBufferPointer<ColorType>(mutableOriginalImageBuffer)
        }
        
        
        let colorPalette = state?.colorPalette

        let newImageViewImage = state?.resultImage ?? originalImage
        if let scene = sceneView.scene as? ColorsScene<ColorType> {
            scene.update(forPalette: colorPalette)
        } else {
            let scene = ColorsScene<ColorType>(image: imageBuffer, palette: colorPalette, renderedPoints: 500)
            if deallocationNeeded {
                imageBuffer.deallocate()
            }
            sceneView.scene = scene
        }
        
        imageView.image = newImageViewImage
    }
    
    func updateScreen() {
        updateScreenSide(state: rgbState, sceneView: rgbSceneView, imageView: rgbImageView)
        updateScreenSide(state: labState, sceneView: labSceneView, imageView: labImageView)
    }
    
    func readValuesFromKeyValueStore() {
        if case .some(.data(let imageData)) = PlaygroundKeyValueStore.current["colorSpaceComparison.image"] {
            self.originalImage = UIImage(data: imageData)!.resize(to: CGSize(width: 800, height: 600))
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        DispatchQueue.main.async {
            guard case .dictionary(let dict) = message else {
                fatalError()
            }
            
            if let imageData = dict[PlaygroundMessageKey.image] {
                PlaygroundKeyValueStore.current["colorSpaceComparison.image"] = imageData
                self.readValuesFromKeyValueStore()
            }
            
            if case .some(.string(let instruction)) = dict[PlaygroundMessageKey.instruction] {
                switch instruction {
                case PlaygroundMessageKey.doIteration:
                    self.doKMeansIteration()
                case PlaygroundMessageKey.reset:
                    self.reset()
                case PlaygroundMessageKey.pickInitialColors:
                    guard case .some(.integer(let numColors)) = dict[PlaygroundMessageKey.numColors] else {
                        fatalError()
                    }
                    self.pickInitialColors(numColors)
                default:
                    fatalError()
                }
            }
            
            self.updateScreen()
        }
    }
}
