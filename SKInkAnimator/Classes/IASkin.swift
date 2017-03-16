//
//  IASkin.swift
//  Pods
//
//  Created by Rafael Moura on 16/03/17.
//
//

import Foundation
import AEXML
import SpriteKit

class IASkin: NSObject {

    private(set) var name: String
    var texturesForNodes: [NSUUID : SKTexture]
    var nodesVisibility: [NSUUID : Bool]
    
    init(xmlElement: AEXMLElement, entityInfo: [NSUUID : String]) throws {
        
        self.texturesForNodes = [NSUUID : SKTexture]()
        self.nodesVisibility = [NSUUID : Bool]()
        
        guard let skinName = xmlElement.attributes[IAXMLConstants.nameAttribute] else {
            throw IAXMLParsingError.invalidAttribute(message: "Expected \"name\" attribute in skin element")
        }
        
        self.name = skinName
        
        for element in xmlElement.children {
            
            guard let uuidString = element.attributes[IAXMLConstants.uuidAttribute], let uuid = NSUUID(uuidString: uuidString) else {
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
    
    func preload(_ completion: @escaping ()->()) {
        SKTexture.preload(Array(self.texturesForNodes.values), withCompletionHandler: completion)
    }
    
    static func preload(skins: [IASkin], completion: @escaping ()->()){
        
        var counter = 0
        
        for skin in skins {
            
            skin.preload {
                
                counter += 1
                if counter == skins.count {
                    completion()
                }
            }
        }
    }
}
