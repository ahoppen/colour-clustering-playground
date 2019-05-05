//
//  RGBPlayground.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 20.03.19.
//

import UIKit
import PlaygroundSupport

public class LabPlaygroundViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    @IBOutlet var colourView: UIView!
    @IBOutlet var debugLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        colourView.layer.cornerRadius = 5
        
        readValuesFromKeyValueStore()
    }
    
    
    func readValuesFromKeyValueStore() {
        if case .some(.dictionary(let colourComponents)) = PlaygroundKeyValueStore.current["labPlayground.color"] {
            if case .some(.floatingPoint(let l)) = colourComponents[PlaygroundMessageKey.l],
                case .some(.floatingPoint(let a)) = colourComponents[PlaygroundMessageKey.a],
                case .some(.floatingPoint(let b)) = colourComponents[PlaygroundMessageKey.b] {
                
                let color = ColorConversion.labToRgb(l: Float(l), a: Float(a), b: Float(b))
                
                colourView.backgroundColor = UIColor(red: CGFloat(color.red), green: CGFloat(color.green), blue: CGFloat(color.blue), alpha: 1)
            }
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case .dictionary(let dict) = message else {
            fatalError()
        }
        
        if let colorComponents = dict[PlaygroundMessageKey.labColor] {
            PlaygroundKeyValueStore.current["labPlayground.color"] = colorComponents
        }
        
        readValuesFromKeyValueStore()
    }
}
