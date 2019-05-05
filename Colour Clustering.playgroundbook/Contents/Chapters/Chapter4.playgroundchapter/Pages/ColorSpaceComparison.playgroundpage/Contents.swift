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
 # Using L\*a\*b\* for clustering
 
 Now that we've seen that, according to colour theory, L\*a\*b\* is better for determining similarity between colours, let't see if we get better results if we use this colour space for the clustering algorithm we have seen before.
 
 * experiment:
 Step through the code to see how k-Means algorithm converges in the RGB and L\*a\*b\* colour space. Do you agree with colour theory that L\*a\*b\* gives better results or would you stick to clustering using RGB?
 */
setImage(/*#-editable-code */#imageLiteral(resourceName: "Yosemite 1.jpeg")/*#-end-editable-code */)

pickInitialColors(numColors: /*#-editable-code */8/*#-end-editable-code */)

for _ in 1 ... /*#-editable-code */15/*#-end-editable-code */ {
    performKMeansIteration()
}
