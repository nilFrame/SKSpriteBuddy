//
//  IAEntity.swift
//  Pods
//
//  Created by Rafael Moura on 15/03/17.
//
//

import Foundation
import SpriteKit
import AEXML

public enum EntityParsingError: Error {
    case invalidEntityName
}

public class IAEntity: SKNode {

    var size: CGSize
    private var document: AEXMLDocument
    
    //
    // MARK: - Initializers
    //
    
    public convenience init(withName name: String) throws {
        
        let document = try IAEntity.document(with: name)
        let skinsElement = document.root[IAXMLConstants.skinsElement]
        let defaultSkinElement = skinsElement[IAXMLConstants.skinElement]

        guard let defaultSkinName = defaultSkinElement.attributes[IAXMLConstants.nameAttribute] else {
            throw IAXMLParsingError.invalidAttribute(message: "Expecting \"name\" attribute in the skin element.")
        }
        
        try self.init(xmlDocument: document, andSkin: defaultSkinName)
        
        self.name = name
    }
    
    public convenience init(withName name: String, andSkin skinName: String) throws {
        
        let document = try IAEntity.document(with: name)
        let mainElement = document.root[IAXMLConstants.xmlElement]
        
        try self.init(xmlDocument: document, andSkin: skinName)
        
        self.name = name
    }
    
    private init(xmlDocument document: AEXMLDocument, andSkin skinName: String) throws {
        
        let entityElement = document.root[IAXMLConstants.entityElement]
        let mainBoneElement = entityElement[IAXMLConstants.xmlElement]
        
        guard let size = CGSize(xmlElement: mainBoneElement[IAXMLConstants.sizeElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"size\" element")
        }
        
        self.size = size
        self.document = document
        
        super.init()
        
        let childNodes = mainBoneElement[IAXMLConstants.childrenElement]
       
        for childElement in childNodes.children {
            let node = try IASpriteNode(xmlElement: childElement)
            self.addChild(node)
        }
        
        try self.setSkin(named: skinName)
    }
    
    //
    // NARK: - Skins stack
    //

    public func setSkin(named name: String) throws {
        
        let skinsElement = self.document.root[IAXMLConstants.skinsElement]
        
        // get skin element into the xml document
        guard let skin = skinsElement.children.filter({ (element) -> Bool in
            
            if let nameAttribute = element.attributes[IAXMLConstants.nameAttribute], nameAttribute == name {
                return true
            }
            
            return false
            
        }).first else {
            return
        }
        
        var skinTextures = [NSUUID : SKTexture]()
        
        // Read the xml document and load textures for visible nodes
        for boneInfo in skin.children {
            
            guard let uuidString = boneInfo.attributes[IAXMLConstants.uuidAttribute], let boneUUID = NSUUID(uuidString: uuidString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"uuid\" attribute")
            }
            
            guard let visibilityString = boneInfo.attributes[IAXMLConstants.boneVisibilityAttribute], let visible = visibilityString.toBool() else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"isVisible\" attribute")
            }
            
            if visible {
                let texture = SKTexture(imageNamed: "\(name)_\(uuidString)_Texture")
                skinTextures[boneUUID] = texture
            }
        }
        
        // Load textures in a background task
        SKTexture.preload(Array(skinTextures.values)) {
            
            // walk through nodes and set the skin textures
            self.enumerateChildNodes(withName: ".//*", using: { (node, stop) in
                
                // Select just entity children that was maded with InkAnimator
                guard let iaNode = node as? IASpriteNode else {
                    return
                }
                
                // Sets texture for visible nodes in the skin and hide the invisible ones
                if let texture = skinTextures[iaNode.uuid] {
                    iaNode.isHidden = false
                    iaNode.texture = texture
                    
                }else {
                    iaNode.isHidden = true
                }
            })
        }
    }
    
    private func setNode(_ node: IASpriteNode, visible: Bool) {
        
    }
    
    private func loadSkin(with xmlElement: AEXMLElement) {
        
    }
    
    //
    // MARK: - Texture Preload stack
    //
    
    public func preload(_ completion: ()->()) {
        
    }
    
    public func preload(skinNamed skinName: String, completion: ()->()) {
        
    }
    
    //
    // MARK: - XML Document stack
    //
    
    private static func document(with entityName: String) throws -> AEXMLDocument {
        
        guard let documentURL = Bundle.main.url(forResource: entityName, withExtension: ".xml") else {
            throw EntityParsingError.invalidEntityName
        }
        
        let xmlData = try Data(contentsOf: documentURL)
        
        return try AEXMLDocument(xml: xmlData)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
