//
//  PanoramaController.swift
//  Guidebook
//
//  Created by Steven Ha on 9/1/17.
//  Copyright © 2017 Steven Ha. All rights reserved.
//

import UIKit
import SceneKit
import CoreMotion


class PanoramaController: UIViewController {
    
     // Pragma MARK - link
    
    // http://iosdeveloperzone.com/2016/05/02/using-scenekit-and-coremotion-in-swift/
    
    let sceneView: SCNView = {
        let view = SCNView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let cameraNode: SCNNode = {
        let node = SCNNode()
        
        return node
    }()
    
    let motionManager: CMMotionManager = {
        let manager = CMMotionManager()
        
        return manager
    }()
    
    var panoramaTitle: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(sceneView)
        setupConstraints()
        
        // Load assets
        /*guard let imagePath = Bundle.main.path(forResource: panoramaTitle!, ofType: "jpg") else {
            fatalError("Failed to find path for panaromic file.")
        }*/
        
        
        guard let image = UIImage(named: panoramaTitle!) else {
            fatalError("Failed to load panoramic image")
        }
        
        // Set the scenepush
        let scene = SCNScene()
        sceneView.scene = scene
        sceneView.showsStatistics = true
        sceneView.allowsCameraControl = true
        
        //Create node, containing a sphere, using the panoramic image as a texture
        let sphere = SCNSphere(radius: 20.0)
        sphere.firstMaterial!.isDoubleSided = true
        sphere.firstMaterial!.diffuse.contents = image
        let sphereNode = SCNNode(geometry: sphere)
        sphereNode.position = SCNVector3Make(0,0,0)
        scene.rootNode.addChildNode(sphereNode)
        
        
        // Camera, ...
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3Make(0, 0, 0)
        scene.rootNode.addChildNode(cameraNode)
        
        /*
        guard motionManager.isDeviceMotionAvailable else {
            fatalError("Device motion is not available")
        }
        
        // Action
        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdatesToQueue(OperationQueue.mainQueue) {
            [weak self](data: CMDeviceMotion?, error: NSError?) in
            
            guard let data = data else { return }
            
            let attitude: CMAttitude = data.attitude
            self?.cameraNode.eulerAngles = SCNVector3Make(Float(attitude.roll - M_PI/2.0), Float(attitude.yaw), Float(attitude.pitch))
        } as! CMDeviceMotionHandler as! CMDeviceMotionHandler as! CMDeviceMotionHandler
        */
        
    }
    
    func setupConstraints() {
        sceneView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        sceneView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        sceneView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        sceneView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
