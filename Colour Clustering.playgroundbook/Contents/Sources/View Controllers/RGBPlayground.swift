//
//  RGBPlayground.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 20.03.19.
//

import UIKit
import PlaygroundSupport

public class RGBPlaygroundViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    @IBOutlet var colourView: UIView!
    @IBOutlet var debugLabel: UILabel!
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        colourView.layer.cornerRadius = 5
        
        readValuesFromKeyValueStore()
    }
    
    func readValuesFromKeyValueStore() {
        if case .some(.dictionary(let colourComponents)) = PlaygroundKeyValueStore.current["rgbPlayground.color"] {
            if case .some(.floatingPoint(let red)) = colourComponents[PlaygroundMessageKey.red],
                case .some(.floatingPoint(let green)) = colourComponents[PlaygroundMessageKey.green],
                case .some(.floatingPoint(let blue)) = colourComponents[PlaygroundMessageKey.blue] {
                let color = UIColor(red: CGFloat(red), green: CGFloat(green), blue: CGFloat(blue), alpha: 1)
                colourView.backgroundColor = color
            }
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case .dictionary(let dict) = message else {
            fatalError()
        }
        
        if let colorComponents = dict[PlaygroundMessageKey.color] {
            PlaygroundKeyValueStore.current["rgbPlayground.color"] = colorComponents
        }
        
        readValuesFromKeyValueStore()
    }
}
