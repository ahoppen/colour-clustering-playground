//#-hidden-code
import PlaygroundSupport
import UIKit

func reduceImage(_ image: UIImage, toColors colors: Int) {
    if colors > UInt8.max {
        fatalError("Only up to 255 different colours are supported. You wanted to reduce the number of colours anyway, didn't you?")
    }
    let dict = PlaygroundValue.dictionary([
        PlaygroundMessageKey.numColors: PlaygroundValue.integer(colors),
        PlaygroundMessageKey.image: PlaygroundValue.data(image.jpegData(compressionQuality: 10)!)
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
 
 # How many different colours do you need to represent an image?
 
 It might suprise you, but for many images only 8 colours are sufficient so that humans can recognise what they are representing – provided that the colours are choosen wisely.
 
 In this playground you will learn how to determine the dominant colours of an image using the *k-Means-Algorithm* and generate an image representation with as few colours as possible – just like the one you see on the right.
 
 * experiment:
 Pick different images and see how many different colours you need to represent them.
 */
let image = /*#-editable-code */#imageLiteral(resourceName: "Yosemite 1.jpeg")/*#-end-editable-code*/
let colors = /*#-editable-code */8/*#-end-editable-code*/

reduceImage(image, toColors: colors)
