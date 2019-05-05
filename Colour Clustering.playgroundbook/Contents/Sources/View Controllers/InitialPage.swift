//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  An auxiliary source file which is part of the book-level auxiliary sources.
//  Provides the implementation of the "always-on" live view.
//

import UIKit
import PlaygroundSupport
import SceneKit
import Dispatch

public class InitialPageViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    typealias ColorType = LabColor

    var rounds: Int = 15
    var colors: Int = 8
    var image = UIImage(named: defaultImageName)!
    
    @IBOutlet var originalImageView: UIImageView!
    @IBOutlet var processedImageView: UIImageView!
    @IBOutlet var debugLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    
    public override func viewDidLoad() {
        image = UIImage(data: image.jpegData(compressionQuality: 10)!)!
        super.viewDidLoad()
        
        readValuesFromKeyValueStore()
        
        updateProcessedImage()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.frame.size.width > view.frame.size.height {
            stackView.axis = .horizontal
        } else {
            stackView.axis = .vertical
        }
    }
    
    @IBAction func updateProcessedImage() {
        originalImageView.image = image
        
        let imageSize = Size(width: 1000, height: 800)
        
        let imageRgbBuffer = UnsafeMutableBufferPointer<RgbColor>.allocate(capacity: imageSize.width * imageSize.height)
        defer { imageRgbBuffer.deallocate() }
        self.image.writeRawIntoBuffer(imageRgbBuffer, size: imageSize)
        
        let metalPipeline = KMeansClassificationPipeline<ColorType>()
        
        let imageBuffer = UnsafeMutableBufferPointer<ColorType>.allocate(capacity: imageRgbBuffer.count)
        defer { imageBuffer.deallocate() }
        metalPipeline.convertFromRgbBuffer(rgbBuffer: UnsafeBufferPointer<RgbColor>(imageRgbBuffer), destination: imageBuffer)
        
        let (processedImage, _) = metalPipeline.runKMeans(imageBuffer: imageBuffer, imageSize: imageSize, numColors: self.colors, rounds: self.rounds)
        
        self.processedImageView.image = processedImage
    }
    
    func readValuesFromKeyValueStore() {
        if case .some(.integer(let numColors)) = PlaygroundKeyValueStore.current["initialPage.numColors"] {
            colors = numColors
        }
        
        if case .some(.data(let imageData)) = PlaygroundKeyValueStore.current["initialPage.image"] {
            self.image = UIImage(data: imageData)!
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case .dictionary(let dict) = message else {
            fatalError()
        }
        
        if let numColors = dict[PlaygroundMessageKey.numColors] {
            PlaygroundKeyValueStore.current["initialPage.numColors"] = numColors
        }
        
        if let imageData = dict[PlaygroundMessageKey.image] {
            PlaygroundKeyValueStore.current["initialPage.image"] = imageData
        }
        
        readValuesFromKeyValueStore()
        updateProcessedImage()
    }
}
