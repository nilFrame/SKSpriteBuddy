//
//  ViewController.swift
//  SKInkAnimator
//
//  Created by Rafael Moura on 01/03/20223.
//  Copyright © 2023 InkAnimator. All rights reserved.
//

import UIKit
import SKInkAnimator
import SpriteKit

class ViewController: UIViewController {

    var entity: IAEntity!
    var runningAnimationId: String?
    var scene: SKScene!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scene = SKScene(size: self.view.bounds.size)
        scene.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        scene.view?.showsFPS = true

        Task {
            let entity = try! await IAEntity(withName: "Kani")
            entity.position.y = -100
            entity.xScale = 0.8
            entity.yScale = 0.8

            try! await entity.preload(skins: ["Skin_rabbit",
                                              "Skin_dog",
                                              "Skin_dinosaur",
                                              "Skin_dragon_2"])

            try! await entity.preload(animations: ["Idle",
                                                   "Running"])

            scene.addChild(entity)
            self.entity = entity
        }

        (self.view as! SKView).presentScene(self.scene)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {

        let animationName: String?

        switch self.runningAnimationId {

        case "Idle":
            animationName = "Running"
        case "Running":
            animationName = nil
        default:
            animationName = "Idle"
        }

        if let animationName {

            Task {

                try! await self.entity.runForever(animationNamed: animationName)
            }

        } else {

            self.entity.stopAnimations()
        }

        self.runningAnimationId = animationName
    }
    
    @IBAction func didSelecSkin(_ sender: UISegmentedControl) {

        let selectedSkinName: String?

        switch sender.selectedSegmentIndex {
        case 0:
            selectedSkinName = "Skin_rabbit"
        case 1:
            selectedSkinName = "Skin_dog"
        case 2:
            selectedSkinName = "Skin_dinosaur"
        case 3:
            selectedSkinName = "Skin_dragon_2"
        default:
            selectedSkinName = nil
        }

        guard let selectedSkinName else { return }

        Task {

            try! await entity.setSkin(named: selectedSkinName)
        }
    }
}

