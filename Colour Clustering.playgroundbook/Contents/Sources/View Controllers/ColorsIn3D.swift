//
//  ColorsIn3D.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 20.03.19.
//

import UIKit
import SceneKit
import PlaygroundSupport

public class ColorsIn3DViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var plotSceneView: SCNView!
    @IBOutlet var debugLabel: UILabel!
    @IBOutlet var stackView: UIStackView!
    
    var image = UIImage(named: defaultImageName)!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        plotSceneView.backgroundColor = UIColor.clear
        
        readValuesFromKeyValueStore()
        update()
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if view.frame.size.width > view.frame.size.height {
            stackView.axis = .horizontal
        } else {
            stackView.axis = .vertical
        }
    }
    
    private func update() {
        self.imageView.image = image
        
        let imageSize = Size(width: Int(imageView.frame.size.width * 2),
                             height: Int(imageView.frame.size.height * 2))
        
        let imageBuffer = UnsafeMutableBufferPointer<RgbColor>.allocate(capacity: imageSize.width * imageSize.height)
        defer { imageBuffer.deallocate() }
        image.writeRawIntoBuffer(imageBuffer, size: imageSize)
        
        let scene = ColorsScene<RgbColor>(image: UnsafeBufferPointer<RgbColor>(imageBuffer), palette: nil, renderedPoints: 1000)
        self.plotSceneView.scene = scene
    }
    
    func readValuesFromKeyValueStore() {
        if case .some(.data(let imageData)) = PlaygroundKeyValueStore.current["colorsIn2D.image"] {
            self.image = UIImage(data: imageData)!
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case .dictionary(let dict) = message else {
            fatalError()
        }
        
        if let imageData = dict[PlaygroundMessageKey.image] {
            PlaygroundKeyValueStore.current["colorsIn2D.image"] = imageData
        }
        
        readValuesFromKeyValueStore()
        update()
    }
}
