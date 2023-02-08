//
//  ViewController.swift
//  SKInkAnimator
//
//  Created by rafael.vrmoura@gmail.com on 03/15/2017.
//  Copyright (c) 2017 rafael.vrmoura@gmail.com. All rights reserved.
//

import UIKit
import SKInkAnimator
import SpriteKit

class ViewController: UIViewController {

    var entity: IAEntity!
    var runningAnimationId: String?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SKScene(size: self.view.bounds.size)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.entity = try! IAEntity(withName: "entity")
        entity.position.y = -100
        scene.addChild(entity)

        entity.preload(animations: ["Idle", "Running"]) {

            (self.view as! SKView).presentScene(scene)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let animationName: String
        switch self.runningAnimationId {

        case "Running":
            animationName = "Idle"
        case "Idle":
            animationName = "Running"
        default:
            animationName = "Idle"
        }

        self.entity.runForever(animationNamed: animationName)
        self.runningAnimationId = animationName
    }
    
    @IBAction func didSelecSkin(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            try! entity.setSkin(named: "Skin_rabbit")
        case 1:
            try! entity.setSkin(named: "Skin_dog")
        case 2:
            try! entity.setSkin(named: "Skin_dinosaur")
        case 3:
            try! entity.setSkin(named: "Skin_dragon_2")
        default:
            break
        }
        
    }
}

