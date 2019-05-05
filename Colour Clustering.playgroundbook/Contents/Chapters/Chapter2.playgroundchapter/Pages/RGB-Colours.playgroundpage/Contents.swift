//#-hidden-code
import PlaygroundSupport
import UIKit

func showColor(red: Int, green: Int, blue: Int) {
    let color = PlaygroundValue.dictionary([
        PlaygroundMessageKey.red: PlaygroundValue.floatingPoint(Double(red) / 100),
        PlaygroundMessageKey.green: PlaygroundValue.floatingPoint(Double(green) / 100),
        PlaygroundMessageKey.blue: PlaygroundValue.floatingPoint(Double(blue) / 100),
        ])
    
    let dict = PlaygroundValue.dictionary([
        PlaygroundMessageKey.color: color
        ])
    
    guard let remoteView = PlaygroundPage.current.liveView as? PlaygroundRemoteLiveViewProxy else {
        fatalError("Always-on live view not configured in this page's LiveView.swift.")
    }
    remoteView.send(dict)
}

//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(literal, show, integer)
/*:
 
 # How are colours represented internally?
 
 Before we learn how to find the dominant colours of an image, we need to take a quick look at how colours are represented internally in the computer.
 
 As you might know, each pixel on your iPad's display consists of a tiny red, blue and green lamp. Your iPad generates all the colours it displays by turning the brightness of each of these lamps up or down.
 The *RGB colour format* stores with which intensity the three lamps of each pixel have to shine to emit the right colour. For example, if the red and green lamp shine with full intensity but blue is turned of, you get yellow.
 
 * experiment:
 Try which channels you need to turn on to receive your favourite colour.
 */
let red = /*#-editable-code */100/*#-end-editable-code*/%
//#-hidden-code
100000
//#-end-hidden-code
let green = /*#-editable-code */100/*#-end-editable-code*/%
//#-hidden-code
100000
//#-end-hidden-code
let blue = /*#-editable-code */0/*#-end-editable-code*/%
//#-hidden-code
100000
//#-end-hidden-code

showColor(red: red, green: green, blue: blue)
/*:
 If we can represent a colour, we can also represent images. For each pixel of an image, we simply store the red, green, and blue intensity.
 */
