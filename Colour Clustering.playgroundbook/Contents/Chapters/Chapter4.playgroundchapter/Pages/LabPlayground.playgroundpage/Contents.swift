//#-hidden-code
import PlaygroundSupport
import UIKit

func showColor(l: Double, a: Double, b: Double) {
    let color = PlaygroundValue.dictionary([
        PlaygroundMessageKey.l: PlaygroundValue.floatingPoint(l),
        PlaygroundMessageKey.a: PlaygroundValue.floatingPoint(a),
        PlaygroundMessageKey.b: PlaygroundValue.floatingPoint(b),
        ])
    
    let dict = PlaygroundValue.dictionary([
        PlaygroundMessageKey.labColor: color
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
 
 # The L\*a\*b\* colour space
 
 While the RGB colour space is great for representing colours that shall be displayed on a screen, the distance between two colours in the RGB colour space does not exactly correspond to our perception of colours – two colours that are close in the RGB-space might look more different to us than two colours that are further apart. That is because the human eye is, for example, better at distinguishing different shades of green than different shades of red.
 
 A better colour space to measure similarity between colours is the CIE-L\*a\*b\* colour space. Instead of mixing colours from their red, green, and blue component, it represents colours by the following characteristics:
 * Lightness (L*): Determines how bright the colour is. `0` will decrease the lightness to black and `100` will give you full lightness.
 * Green-Red (a*): Determines if the colour is more green or more red (magenta). `-100` will give you a very green colour, `100` will give you a red colour. Values in between correspond to mixtures of red and green.
 * Blue-Yellow (b*): Just like Green-Red this component specifies whether the colour is rather blue or yellow. Once again, you can assume that values range from `-100` to `100`.
 
 * experiment:
 Try representing your favourite colour in the L\*a\*b\* colour space by adjusting the values below.
 */
let lightness = /*#-editable-code */50/*#-end-editable-code*/
//#-hidden-code
as Double
//#-end-hidden-code
let greenRed = /*#-editable-code */-60/*#-end-editable-code*/
//#-hidden-code
as Double
//#-end-hidden-code
let blueYellow = /*#-editable-code */20/*#-end-editable-code*/
//#-hidden-code
as Double
//#-end-hidden-code

showColor(l: lightness,
          a: greenRed,
          b: blueYellow)
/*:
 * note:
 The a\* and b\* values are technically not restricted to a certain range. It's just that at some point you iPad is not able to display the colours anymore or the human eye is no longer able to see them. But that's a topic for another Playground.
 */
