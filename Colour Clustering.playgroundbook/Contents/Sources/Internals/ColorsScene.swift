//
//  ColorsScene.swift
//  WWDC19Proj
//
//  Created by Alex Hoppen on 19.03.19.
//  Copyright © 2019 Alex Hoppen. All rights reserved.
//

import SceneKit

public class ColorsScene<ColorType: Color>: SCNScene {
    var pointNodes: [(color: ColorType, node: SCNNode)] = []
    
    init(image: UnsafeBufferPointer<ColorType>, palette: ColorPalette<ColorType>?, renderedPoints: Int) {
        super.init()
        
        let scaleFactor: CGFloat = 6
        let renderOffset: CGFloat = -scaleFactor/2
        let radius: CGFloat = 0.05
        
        for i in stride(from: 0, to: image.count, by: image.count / renderedPoints) {
            let color = image[i]
            
            let sphereGeometry = SCNSphere(radius: radius)
            let renderedColor: ColorType
            if let palette = palette {
                renderedColor = palette.findClosestColor(to: color)
            } else {
                renderedColor = color
            }
            
            let renderedUIColor = renderedColor.uicolor
            sphereGeometry.firstMaterial?.diffuse.contents = renderedUIColor
            let sphereNode = SCNNode(geometry: sphereGeometry)
            let normalizedComponents = color.normalizedComponents
            sphereNode.position = SCNVector3(normalizedComponents.0 * scaleFactor + renderOffset,
                                             normalizedComponents.1 * scaleFactor + renderOffset,
                                             normalizedComponents.2 * scaleFactor + renderOffset)
            rootNode.addChildNode(sphereNode)
            pointNodes.append((color, sphereNode))
        }
        
        let axisGeometry = SCNCylinder(radius: 0.03, height: scaleFactor)
        axisGeometry.firstMaterial?.diffuse.contents = UIColor(white: 0, alpha: 1)
        
        let xAxis = SCNNode(geometry: axisGeometry)
        xAxis.position = SCNVector3(renderOffset, renderOffset, 0)
        xAxis.rotation = SCNVector4(1, 0, 0, Double.pi / 2)
        rootNode.addChildNode(xAxis)
        
        let yAxis = SCNNode(geometry: axisGeometry)
        yAxis.position = SCNVector3(renderOffset, 0, renderOffset)
        rootNode.addChildNode(yAxis)
        
        let zAxis = SCNNode(geometry: axisGeometry)
        zAxis.position = SCNVector3(0, renderOffset, renderOffset)
        zAxis.rotation = SCNVector4(0, 0, 1, Double.pi / 2)
        rootNode.addChildNode(zAxis)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initCamera() {
        let camera = SCNCamera()
        
        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(x: 0, y: 0, z: 10)
        
//        let centerBox = SCNBox(width: 1.0, height: 1.0, length: 1.0, chamferRadius: 0.0)
//        let centerNode = SCNNode(geometry: centerBox)
//
//        let constraint = SCNLookAtConstraint(target: centerNode)
//        constraint.isGimbalLockEnabled = true
//        cameraNode.constraints = [constraint]
        
        rootNode.addChildNode(cameraNode)
        
    }
    
    public func update(forPalette palette: ColorPalette<ColorType>?) {
        for (color, node) in pointNodes {
            let renderedColor: ColorType
            if let palette = palette {
                renderedColor = palette.findClosestColor(to: color)
            } else {
                renderedColor = color
            }
            
            let renderedUIColor = renderedColor.uicolor
            node.geometry?.firstMaterial?.diffuse.contents = renderedUIColor
        }
    }
}
