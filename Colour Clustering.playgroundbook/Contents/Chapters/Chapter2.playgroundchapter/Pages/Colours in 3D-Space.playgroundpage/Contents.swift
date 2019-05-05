//#-hidden-code
import PlaygroundSupport
import UIKit

func inspectImageColors(for image: UIImage) {
    let dict = PlaygroundValue.dictionary([
        PlaygroundMessageKey.image: PlaygroundValue.data(image.jpegData(compressionQuality: 1)!)
        ])
    
    
    guard let remoteView = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else {
        fatalError("Always-on live view not configured in this page's LiveView.swift.")
    }
    remoteView.send(dict)
}

//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(literal, show, image, integer)
/*:
 
 # Colours as points in 3D-space
 
 Now that we have seen how we can represent each colour by three values, we can consider each colour as a point in *3D-space*.
 For this we simply use the colour's red component as its X-coordinate, the green component as its Y-coordinate, and the blue component as its Z-coordinate.
 
 Using this idea, we can visualise the colours of an image by plotting the colour of every pixel in a 3D coordinate system.
 
 * experiment:
 Can you see how the colours in some images form clusters? Later, we will represent each cluster by a single colour.

 —
 
 * Note:
 You can rotate the coordinate system to look at it from different angles.
 */
let image = /*#-editable-code */#imageLiteral(resourceName: "Yosemite 1.jpeg")/*#-end-editable-code*/

inspectImageColors(for: image)

