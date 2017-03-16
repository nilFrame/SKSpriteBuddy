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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let scene = SKScene(size: self.view.bounds.size)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        self.entity = try! IAEntity(withName: "entity")
        entity.position.y = -100
        entity.position.x += 30
        scene.addChild(entity)
        
        (self.view as! SKView).presentScene(scene)
        
//        let node0 = SKNode()
//        node0.name = "Node 0"
//        
//        let node1 = SKNode()
//        node1.name = "Node 1"
//        
//        let node2 = SKNode()
//        node2.name = "Node 2"
//        
//        let node3 = SKNode()
//        node3.name = "Node 3"
//        
//        let node4 = SKNode()
//        node4.name = "Node 4"
//        
//        node0.addChild(node1)
//        node0.addChild(node2)
//        node0.addChild(node3)
//        node0.addChild(node4)
//        
//        node0.enumerateChildNodes(withName: "./*") { (node, stop) in
//            print("Enumerating \(node.name!)")
//        }
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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

