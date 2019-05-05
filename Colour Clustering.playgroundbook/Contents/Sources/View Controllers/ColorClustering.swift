//
//  ColorClustering.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 21.03.19.
//

import UIKit
import PlaygroundSupport
import SceneKit

extension UIImage {
    func resize(to newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0);
        self.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

func *(size: CGSize, constant: CGFloat) -> CGSize {
    return CGSize(width: size.width * constant, height: size.height * constant)
}

public class ColorClusteringViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    typealias ColorType = RgbColor
    
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var sceneView: SCNView!
    @IBOutlet var debugLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    var originalImage: UIImage!
    var state: ColorClusteringState<ColorType>?
    let autorun = false
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.backgroundColor = UIColor.clear
        
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
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.frame.size.width > view.frame.size.height {
            stackView.axis = .horizontal
        } else {
            stackView.axis = .vertical
        }
    }
    
    private func pickInitialColors(_ numColors: Int) {
        state = ColorClusteringState(image: originalImage, numColors: numColors)
        
        if autorun {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (_) in
                self.doKMeansIteration()
                self.updateScreen()
            }
        }
    }
    
    private func doKMeansIteration() {
        state?.doKMeansRound()
        if autorun {
            Timer.scheduledTimer(withTimeInterval: 3, repeats: false) { (_) in
                self.doKMeansIteration()
                self.updateScreen()
            }
        }
    }
    
    private func reset() {
        imageView.image = originalImage
        state = nil
        sceneView.scene = nil
    }
    
    private func updateScreen() {
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
            let scene = ColorsScene<ColorType>(image: imageBuffer, palette: colorPalette, renderedPoints: 300)
            if deallocationNeeded {
                imageBuffer.deallocate()
            }
            self.sceneView.scene = scene
        }
        
        self.imageView.image = newImageViewImage
    }
    
    func readValuesFromKeyValueStore() {
        if case .some(.data(let imageData)) = PlaygroundKeyValueStore.current["colorClustering.image"] {
            self.originalImage = UIImage(data: imageData)!.resize(to: CGSize(width: 800, height: 600))
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case .dictionary(let dict) = message else {
            fatalError()
        }
        
        if let imageData = dict[PlaygroundMessageKey.image] {
            PlaygroundKeyValueStore.current["colorClustering.image"] = imageData
            readValuesFromKeyValueStore()
        }
        
        if case .some(.string(let instruction)) = dict[PlaygroundMessageKey.instruction] {
            switch instruction {
            case PlaygroundMessageKey.doIteration:
                doKMeansIteration()
            case PlaygroundMessageKey.reset:
                reset()
            case PlaygroundMessageKey.pickInitialColors:
                guard case .some(.integer(let numColors)) = dict[PlaygroundMessageKey.numColors] else {
                    fatalError()
                }
                pickInitialColors(numColors)
            default:
                fatalError()
            }
        }
        
        updateScreen()
    }
}
