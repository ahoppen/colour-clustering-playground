//
//  See LICENSE folder for this template’s licensing information.
//
//  Abstract:
//  Instantiates a live view and passes it to the PlaygroundSupport framework.
//

import UIKit
import PlaygroundSupport

let storyboard = UIStoryboard(name: "LiveView", bundle: nil)

PlaygroundPage.current.liveView = storyboard.instantiateViewController(withIdentifier: "InitialPage") as! InitialPageViewController
