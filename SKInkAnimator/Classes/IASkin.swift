//
//  IASkin.swift
//  Pods
//
//  Created by Rafael Moura on 16/03/17.
//  Copyright © 2023 InkAnimator. All rights reserved.
//

import Foundation
import SpriteKit

class IASkin: NSObject {

    private(set) var name: String
    var texturesForNodes: [UUID : SKTexture]
    var nodesVisibility: [UUID : Bool]
    
    init(xmlElement: AEXMLElement, entityInfo: [UUID : String]) throws {
        
        self.texturesForNodes = [UUID : SKTexture]()
        self.nodesVisibility = [UUID : Bool]()
        
        guard let skinName = xmlElement.attributes[IAXMLConstants.nameAttribute] else {
            throw IAXMLParsingError.invalidAttribute(message: "Expected \"name\" attribute in skin element")
        }
        
        self.name = skinName
        
        for element in xmlElement.children {
            
            guard let uuidString = element.attributes[IAXMLConstants.uuidAttribute], let uuid = UUID(uuidString: uuidString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"uuid\" attribute in bone element into skin element")
            }
            
            guard let visibility = element.attributes[IAXMLConstants.boneVisibilityAttribute], let visible = visibility.toBool() else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"isVisible\" attribute in bone element into skin element")
            }
            
            nodesVisibility[uuid] = visible
        }
        
        for (uuid, textureName) in entityInfo {
            
            if nodesVisibility[uuid] ?? false {
                let texture = SKTexture(imageNamed: "\(skinName)_\(uuid.uuidString)_\(textureName)")
                self.texturesForNodes[uuid] = texture
            }
        }
        
        
        super.init()
    }
    
    func preload() async {

        return await withCheckedContinuation { continuation in

            SKTexture.preload(Array(self.texturesForNodes.values)) {

                continuation.resume()
            }
        }
    }
}
