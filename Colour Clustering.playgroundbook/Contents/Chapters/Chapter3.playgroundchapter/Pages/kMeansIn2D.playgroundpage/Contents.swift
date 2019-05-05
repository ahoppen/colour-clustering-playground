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

func loadDataSet(_ dataSet: DataSet) {
    sendMessage(key: PlaygroundMessageKey.dataSet, value: PlaygroundValue.integer(dataSet.rawValue))
}

func setInitialClusterMeans(_ points: [Point]) {
    if points.isEmpty {
        fatalError("You need to specify at least one cluster.")
    }
    if points.count > 10 {
        fatalError("Only up to 10 different clusters are supported")
    }
    let serializedPoints = points.map({
        return PlaygroundValue.dictionary([
            PlaygroundMessageKey.x: PlaygroundValue.integer($0.x),
            PlaygroundMessageKey.y: PlaygroundValue.integer($0.y),
        ])
    })

    sendMessage(key: PlaygroundMessageKey.initClusterMeans, value: PlaygroundValue.array(serializedPoints))
}

func updateClusterCenters() {
    sendInstruction(PlaygroundMessageKey.adjustMeans)
}

func classifyDataPoints() {
    sendInstruction(PlaygroundMessageKey.adjustClassifications)
}

private func reset() {
    sendInstruction(PlaygroundMessageKey.reset)
}

enum DataSet: Int {
    case first = 0
    case second = 1
    case third = 2
}

reset()

//#-end-hidden-code
//#-code-completion(everything, hide)
//#-code-completion(currentmodule, show)
//#-code-completion(identifier, hide, sendMessage(key:value:), sendInstruction(_:), reset())
//#-code-completion(keyword, show, for)
/*:
 # The k-Means algorithm
 
 The k-Means algorithm is an iterative algorithm that finds clusters within a data set. The basic idea is a two-step process that is repeated until convergence:
 1. Assign each data point in the data set to the cluster whose center is closest to it
 2. Recompute the cluster centers as the center (arithmetic mean) of all data points that have been assigned to it
 
 In the beginning the cluster centers can be chosen arbitrarily. Usually, the algorithm converges to the correct clusters fairly fast if the initial cluster centers are spread far enough apart.
 
 * Experiment:
 Step through the code below to see how the algorithm finds the differnt clusters in the different data sets.\
Try adding more points to the `initialClusterCenters` array to get finer granularity for the clusters. Does adding more clusters always help? \
Try how many iterations are needed until the cluster centers converge to a fixed point.
 
 —
 
 * Note:
 To step through the code, touch the stopwatch to the left of “Run My Code” and then press “Step Through My Code”.
 */
loadDataSet(.second)

let initialClusterCenters = [
    Point(x: 0, y: 0),
    Point(x: 0, y: 100),
    Point(x: 100, y: 0),
    Point(x: 100, y: 100),
]

setInitialClusterMeans(initialClusterCenters)

for _ in 1 ... 10 {
    classifyDataPoints()
    updateClusterCenters()
}
