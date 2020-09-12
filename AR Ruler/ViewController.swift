//
//  ViewController.swift
//  AR Ruler
//
//  Created by Nishant Taneja on 12/09/20.
//  Copyright © 2020 Nishant Taneja. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {
    //MARK:- IBOutlet
    @IBOutlet var sceneView: ARSCNView!
    
    //MARK:- Initialise
    private var dotNodes = [SCNNode]()
    private var textNode = SCNNode()
    
    //MARK:- Override View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // SceneView Delegate|Options
        sceneView.delegate = self
        sceneView.debugOptions = [ARSCNDebugOptions.showFeaturePoints]
        sceneView.showsStatistics = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // SceneView Configuration|SessionBegin
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Pause the view's session
        sceneView.session.pause()
    }
    
    //MARK:- Touch Detection
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dotNodes.count >= 2 {
            for node in dotNodes {node.removeFromParentNode()}
            dotNodes = [SCNNode]()
        }
        if let firstTouchLocation = touches.first?.location(in: sceneView) {
            if let firstHitResult = sceneView.hitTest(firstTouchLocation, types: .featurePoint).first {
                let locationInReal = firstHitResult.worldTransform.columns.3
                addDot(at: locationInReal)
            }
        }
    }
    
    //MARK:- Methods
    /// This method creates a small sphere node and adds it to the SceneView's root node.
    private func addDot(at location: simd_float4) {
        // Create Node and add to Scene
        let geometry = SCNSphere(radius: 0.005)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        geometry.materials = [material]
        let node = SCNNode(geometry: geometry)
        node.position = SCNVector3(location.x, location.y, location.z)
        sceneView.scene.rootNode.addChildNode(node)
        // Append Node to List
        dotNodes.append(node)
        if dotNodes.count >= 2 {calculateDistance()}
    }
    /// This method calculates distance between first and second dot.
    private func calculateDistance() {
        let firstNodePosition = dotNodes[0].position
        let secondNodePosition = dotNodes[1].position
        let distance = sqrt(pow(secondNodePosition.x - firstNodePosition.x, 2) + pow(secondNodePosition.y - firstNodePosition.y, 2) + pow(secondNodePosition.z - firstNodePosition.z, 2))
        let text = String(format: "%.1f", distance)
        let position = SCNVector3(secondNodePosition.x, secondNodePosition.y + 0.01, secondNodePosition.z)
        display(text, at: position)
    }
    /// This method displays a text at given position.
    private func display(_ text: String, at position: SCNVector3) {
        // Remove old textNode
        textNode.removeFromParentNode()
        // Create new textNode and Display
        let geometry = SCNText(string: text, extrusionDepth: 1.0)
        let material = SCNMaterial()
        material.diffuse.contents = UIColor.red
        geometry.materials = [material]
        let textNode = SCNNode(geometry: geometry)
        textNode.position = position
        textNode.scale = SCNVector3(0.005, 0.005, 0.005)
        sceneView.scene.rootNode.addChildNode(textNode)
    }
}
