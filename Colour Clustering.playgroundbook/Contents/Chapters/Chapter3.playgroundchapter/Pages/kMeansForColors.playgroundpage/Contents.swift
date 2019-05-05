//#-hidden-code
import PlaygroundSupport
import UIKit

struct Point {
    let x: Int
    let y: Int
}

private func sendMessage(key: String, value: PlaygroundValue) {
    let dict = PlaygroundValue.dictionary([key: value])
    
    guard let remoteView = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else {
        fatalError("Always-on live view not configured in this page's LiveView.swift.")
    }
    
    remoteView.send(dict)
}

private func sendInstruction(_ instruction: String) {
    sendMessage(key: PlaygroundMessageKey.instruction, value: PlaygroundValue.string(instruction))
}

private func reset() {
    sendInstruction(PlaygroundMessageKey.reset)
}

func pickInitialColors(numColors: Int) {
    if numColors <= 0 {
        fatalError("The resulting image needs to consist of at least one colour. How would an image without a colour even look like?")
    }
    let dict = PlaygroundValue.dictionary([
        PlaygroundMessageKey.instruction: PlaygroundValue.string(PlaygroundMessageKey.pickInitialColors),
        PlaygroundMessageKey.numColors: PlaygroundValue.integer(numColors),
    ])
    
    guard let remoteView = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else {
        fatalError("Always-on live view not configured in this page's LiveView.swift.")
    }
    
    remoteView.send(dict)
}

func performKMeansIteration() {
    sendInstruction(PlaygroundMessageKey.doIteration)
}

func setImage(_ image: UIImage) {
    let dict = PlaygroundValue.dictionary([
        PlaygroundMessageKey.image: PlaygroundValue.data(image.jpegData(compressionQuality: 1)!),
        PlaygroundMessageKey.instruction: PlaygroundValue.string(PlaygroundMessageKey.reset),
        ])
    
    guard let remoteView = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else {
        fatalError("Always-on live view not configured in this page's LiveView.swift.")
    }
    
    remoteView.send(dict)
}

reset()

//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, sendMessage(key:value:), sendInstruction(_:), reset())
//#-code-completion(keyword, show, for)
//#-code-completion(literal, show, image, integer)
/*:
 # Using k-Means to cluster colours
 
 Remember that colours can be interpreted as points in 3D-space? Just as we have previously clustered data points on a plane, we can use the same algorithm to cluster colours (a.k.a. data points in 3D space).
 
 Replacing each pixel in the image with the center (i.e. average) colour of its cluster gives us the kind of image we have seen at the start.
 
 * experiment:
 Step through the code on the left to see how the image colours are being clustered. \
Try different images and see which ones are particularly suited for clustering.
 */
setImage(/*#-editable-code */#imageLiteral(resourceName: "Yosemite 1.jpeg")/*#-end-editable-code */)
/*:
 * note:
 As initial cluster centers we will this time automatically choose colours from the image.
 */
pickInitialColors(numColors: /*#-editable-code */8/*#-end-editable-code*/)

for _ in 1 ... /*#-editable-code */15/*#-end-editable-code */ {
    performKMeansIteration()
}
/*:
 * callout(Congratulations 🎉):
 You have learned how the k-Means algorithm works and how you can use it to reduce an image to its primary colours. Cool, eh? \
Continue with the next pages to explore how we can use colour theory to improve the result even further.
 */
