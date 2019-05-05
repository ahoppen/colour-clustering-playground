//
//  KMeans.swift
//  Book_Sources
//
//  Created by Alex Hoppen on 21.03.19.
//

import UIKit
import PlaygroundSupport
import SpriteKit

struct Cluster {
    var mean: CGPoint
    var color: UIColor
}

extension CGPoint {
    func squaredDistance(to other: CGPoint) -> CGFloat {
        return (self.x - other.x) * (self.x - other.x) +
            (self.y - other.y) * (self.y - other.y)
    }
}

func -(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x - p2.x, y: p1.y - p2.y)
}

func +(p1: CGPoint, p2: CGPoint) -> CGPoint {
    return CGPoint(x: p1.x + p2.x, y: p1.y + p2.y)
}

func /(point: CGPoint, constant: CGFloat) -> CGPoint {
    return CGPoint(x: point.x / constant, y: point.y / constant)
}

private let colors: [UIColor] = [
    .red, .green, .blue, .orange, .purple, .brown, .magenta, .yellow, .cyan, .black, .darkGray
]

public class KMeansViewController: UIViewController, PlaygroundLiveViewMessageHandler, PlaygroundLiveViewSafeAreaContainer {
    
    @IBOutlet var spriteView: SKView!
    @IBOutlet var debugLabel: UILabel!
    private var scene: SKScene!
    private let pointRadius: CGFloat = 10
    private let crossSize: CGFloat = 30
    private var dataSet: [CGPoint]!
    private var classificationClusters: [Cluster]!
    private var adjustedClusters: [Cluster]!
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        spriteView.backgroundColor = .white
        
        reset()
        readValuesFromKeyValueStore()
        updateScene()
        
//        setupTouchRecogniser()
    }
    
    @objc private func adjustClusters() {
        var aggregationData = [(pointsSum: CGPoint, count: Int)](repeating: (CGPoint.zero, 0), count: classificationClusters.count)
        
        for point in dataSet {
            let clusterIndex = getClassificationClusterIndex(for: point, clusters: classificationClusters)
            aggregationData[clusterIndex].pointsSum = aggregationData[clusterIndex].pointsSum + point
            aggregationData[clusterIndex].count += 1
        }
        
        for (offset: index, element: (pointsSum: pointsSum, count: count)) in aggregationData.enumerated() {
            adjustedClusters[index].mean = pointsSum / CGFloat(count)
        }
        
        updateScene()
    }
    
    @objc private func adjustClassifications() {
        classificationClusters = adjustedClusters
        
        updateScene()
    }
    
    private func setupTouchRecogniser() {
        let gestureRecogniser = UITapGestureRecognizer(target: self, action: #selector(self.onTouch(recognizer:)))
        spriteView.addGestureRecognizer(gestureRecogniser)
    }
    
    @objc private func onTouch(recognizer: UITapGestureRecognizer) {
        let location = recognizer.location(in: spriteView)
        let x = (location.x / spriteView.frame.size.width - 0.1) / 0.8
        let y = 1 - (location.y / spriteView.frame.size.height - 0.1) / 0.8
        print("CGPoint(x: \(x), y: \(y)),")
        
        let circle = SKShapeNode(circleOfRadius: pointRadius)
        circle.position = translate(point: CGPoint(x: x, y: y), in: scene.size)
        circle.fillColor = .orange
        scene.addChild(circle)
    }
    
    private func translate(point: CGPoint, in rect: CGSize) -> CGPoint {
        return CGPoint(x: (point.x * 0.8 + 0.1) * rect.width,
                       y: (point.y * 0.8 + 0.1) * rect.height)
    }
    
    private func getClassificationClusterIndex(for point: CGPoint, clusters: [Cluster]) -> Int {
        var bestDistance = CGFloat.infinity
        var chosenClusterIndex: Int = 0
        for (index, cluster) in clusters.enumerated() {
            let distance = cluster.mean.squaredDistance(to: point)
            if distance < bestDistance {
                chosenClusterIndex = index
                bestDistance = distance
            }
        }
        return chosenClusterIndex
    }
    
    private func getClassificationCluster(for point: CGPoint, clusters: [Cluster]) -> Cluster {
        let clusterIndex = getClassificationClusterIndex(for: point, clusters: clusters)
        return clusters[clusterIndex]
    }
    
    func updateScene() {
        scene = SKScene(size: CGSize(width: 1000, height: 1000))
        scene.backgroundColor = .clear
        scene.scaleMode = .aspectFit
        
        for point in dataSet {
            let circle = SKShapeNode(circleOfRadius: pointRadius)
            circle.position = translate(point: point, in: scene.size)
            let cluster = getClassificationCluster(for: point, clusters: classificationClusters)
            circle.fillColor = cluster.color
            scene.addChild(circle)
        }
        
        let crossPath = CGMutablePath()
        crossPath.move(to: CGPoint(x: 0, y: 0))
        crossPath.addLine(to: CGPoint(x: crossSize, y: crossSize))
        crossPath.move(to: CGPoint(x: 0, y: crossSize))
        crossPath.addLine(to: CGPoint(x: crossSize, y: 0))
        
        for cluster in adjustedClusters {
            let cross = SKShapeNode()
            cross.path = crossPath
            cross.strokeColor = cluster.color
            cross.lineWidth = 5
            cross.position = translate(point: cluster.mean, in: scene.size) - CGPoint(x: crossSize / 2, y: crossSize / 2)
            scene.addChild(cross)
        }
        
//        let coordinateSystemPath = CGMutablePath()
//        coordinateSystemPath.move(to: translate(point: CGPoint(x: 0, y: 0), in: scene.size))
//        coordinateSystemPath.addLine(to: translate(point: CGPoint(x: 1, y: 0), in: scene.size))
//        coordinateSystemPath.move(to: translate(point: CGPoint(x: 0, y: 0), in: scene.size))
//        coordinateSystemPath.addLine(to: translate(point: CGPoint(x: 0, y: 1), in: scene.size))
//        
//        let coordianteSystem = SKShapeNode()
//        coordianteSystem.path = coordinateSystemPath
//        coordianteSystem.strokeColor = .black
//        scene.addChild(coordianteSystem)
        
        spriteView.presentScene(scene)
        spriteView.backgroundColor = .clear
    }
    
    private func reset() {
        dataSet = []
        classificationClusters = [
            Cluster(mean: CGPoint(x: -1, y: -1), color: .black)
        ]
        adjustedClusters = classificationClusters
    }
    
    func readValuesFromKeyValueStore() {
        if case .some(.array(let serializedPoints)) = PlaygroundKeyValueStore.current["kMeans.initClusterMeans"] {
            let clusterMeans = serializedPoints.map({ (value) -> CGPoint in
                guard case .dictionary(let dict) = value else {
                    fatalError()
                }
                guard case .some(.integer(let x)) = dict[PlaygroundMessageKey.x],
                    case .some(.integer(let y)) = dict[PlaygroundMessageKey.y] else {
                        fatalError()
                }
                
                return CGPoint(x: CGFloat(x) / 100, y: CGFloat(y) / 100)
            })
            
            let clusters = clusterMeans.enumerated().map { (offset, mean) -> Cluster in
                return Cluster(mean: mean, color: colors[offset])
            }
            
            self.adjustedClusters = clusters
        }
        
        if case .some(.integer(let dataSetIndex)) = PlaygroundKeyValueStore.current["kMeans.dataSetIndex"] {
            self.dataSet = dataSets[dataSetIndex]
        }
    }
    
    public func receive(_ message: PlaygroundValue) {
        guard case .dictionary(let dict) = message else {
            fatalError()
        }
        
        if let clusterMeans = dict[PlaygroundMessageKey.initClusterMeans] {
            PlaygroundKeyValueStore.current["kMeans.initClusterMeans"] = clusterMeans
            readValuesFromKeyValueStore()
        }
        
        if let dataSetIndex = dict[PlaygroundMessageKey.dataSet] {
            PlaygroundKeyValueStore.current["kMeans.dataSetIndex"] = dataSetIndex
            readValuesFromKeyValueStore()
        }
        
        if case .some(.string(let instruction)) = dict[PlaygroundMessageKey.instruction] {
            switch instruction {
            case PlaygroundMessageKey.adjustMeans:
                adjustClusters()
            case PlaygroundMessageKey.adjustClassifications:
                adjustClassifications()
            case PlaygroundMessageKey.reset:
                reset()
            default:
                fatalError()
            }
        }
        
        updateScene()
    }
}
