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
    private var loadedSkins = [String : IASkin]()
    private var loadedAnimations = [String : IAAnimation]()
    private var info = [NSUUID : String]()
    
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
        
        try self.loadEntityInfo()
        try self.setSkin(named: skinName)
    }
    
    //
    // NARK: - Skins stack
    //

    private func loadEntityInfo() throws {
        
        let skinsElement = document.root[IAXMLConstants.skinsElement]
        let entityInfoElement = skinsElement[IAXMLConstants.entityInfoElement]
        
        for boneElement in entityInfoElement.children {
            
            guard let uuidString = boneElement.attributes[IAXMLConstants.uuidAttribute], let uuid = NSUUID(uuidString: uuidString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"uuid\" attribute for bone element into entityInfo element")
            }
            
            let textureElement = boneElement[IAXMLConstants.textureElement]
            guard let textureName = textureElement.attributes[IAXMLConstants.nameAttribute] else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"name\" attribute for bone element into entityInfo element")
            }
            
            self.info[uuid] = textureName
        }
    }
    
    public func setSkin(named skinName: String) throws {
    
        // get skin element into the xml document
        if let preloadedSkin = loadedSkins[skinName] {
            loadTextures(for: preloadedSkin)
            
        }else {
            try self.preload(skinNamed: skinName) {
                
                guard let skin = self.loadedSkins[skinName] else {
                    return
                }
                
                self.loadTextures(for: skin)
            }
        }
    }
    
    private func loadTextures(for skin: IASkin) {
        self.enumerateChildNodes(withName: ".//*", using: { (node, stop) in
            
            // Select just entity children that was maded with InkAnimator
            guard let iaNode = node as? IASpriteNode else {
                return
            }
            
            iaNode.isHidden = !(skin.nodesVisibility[iaNode.uuid] ?? false)
            
            // Sets texture for visible nodes in the skin
            if let texture = skin.texturesForNodes[iaNode.uuid], !iaNode.isHidden {
                iaNode.texture = texture
            }
        })
    }
    
    private func xmlElement(for skinName: String) -> AEXMLElement? {
        
        let skinsElement = self.document.root[IAXMLConstants.skinsElement]
        
        guard let skinElement = skinsElement.children.filter({ (element) -> Bool in
            
            if let nameAttribute = element.attributes[IAXMLConstants.nameAttribute], nameAttribute == skinName {
                return true
            }
            
            return false
            
        }).first else {
            return nil
        }
        
        return skinElement
    }
    
    public func releaseSkin(named skinName: String) {
        loadedSkins.removeValue(forKey: skinName)
    }
    
    //
    // MARK: - Entitty Preload stack
    //
    
    public func preload(skinNamed skinName: String, completion: @escaping ()->()) throws {
        guard let skinElement = self.xmlElement(for: skinName) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Skin named \(skinName) not found.")
        }
        
        let skin = try IASkin(xmlElement: skinElement, entityInfo: self.info)
        
        skin.preload {
            self.loadedSkins[skinName] = skin
            completion()
        }
    }
    
    public func preload(skins names: [String], completion: @escaping ()->()) throws {
        
        var counter = 0
        
        for skinName in names {
            
            try self.preload(skinNamed: skinName, completion: {
                
                counter += 1
                if counter == names.count {
                    completion()
                }
            })
        }
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
    
    //
    // MARK: - Animations stack
    //
    
    public func run(animationNamed animationName: String) {
        
        self.preload(animationNamed: animationName) {
            
            guard let animation = self.loadedAnimations[animationName] else {
                return
            }
            
            self.run(animation, times: 1)
        }
    }
    
    public func run(animationNamed animationName: String, times: Int) {
        
        self.preload(animationNamed: animationName) {
            
            guard let animation = self.loadedAnimations[animationName] else {
                return
            }
            
            self.run(animation, times: times)
        }
    }
    
    public func runForever(animationNamed animationName: String) {
        
        self.preload(animationNamed: animationName) {
            
            guard let animation = self.loadedAnimations[animationName] else {
                return
            }
            
            self.run(animation, times: -1)
        }
    }
    
    private func animation(named animationName: String) -> IAAnimation? {
        
        if let animation = loadedAnimations[animationName] {
            
            return animation
            
        } else {
            
            guard let animationElement = animationXMLElement(for: animationName) else {
                return nil
            }
            
            let animation = try? IAAnimation(xmlElement: animationElement)
            return animation
        }
    }
    
    private func animationXMLElement(for animationName: String) -> AEXMLElement? {
        
        let animationsElement = document.root[IAXMLConstants.animationsElement]
        
        guard let animationElement = animationsElement.children.filter({ (element) -> Bool in
            
            if let nameAttribute = element.attributes[IAXMLConstants.nameAttribute], nameAttribute == animationName {
                return true
            }
            
            return false
            
        }).first else {
            return nil
        }
        
        return animationElement
    }
    
    public func preload(animationNamed animationName: String, completion: @escaping ()->()) {
        
        DispatchQueue.global(qos: .background).async {
        
            guard let animation = self.animation(named: animationName) else {
                completion()
                return
            }
            
            DispatchQueue.main.async {
                self.loadedAnimations[animationName] = animation
                completion()
            }
        }
    }
    
    public func preload(animations names: [String], completion: @escaping ()->()) {
        
        DispatchQueue.global(qos: .background).async {
            
            var counter = 0
            for animationName in names {
                
                guard let animation = self.animation(named: animationName) else {
                    return
                }
                
                self.loadedAnimations[animation.name] = animation
                
                counter += 1
                if counter == names.count {
                    DispatchQueue.main.async {
                        completion()
                    }
                }
            }
        }
    }
    
    public func releaseAnimation(named animationName: String) {

        self.loadedAnimations.removeValue(forKey: animationName)
    }
    
    private func run(_ animation: IAAnimation, times: Int) {

        self.enumerateChildNodes(withName: ".//*",
                                 using: { (node, stop) in
            
            guard let iaNode = node as? IASpriteNode else {
                return
            }
            
            if let action = animation.actions[iaNode.uuid] {

                iaNode.removeAllActions()

                if let startKeyframe = animation.startingKeyframeForBone[iaNode.uuid] {

                    iaNode.configure(with: startKeyframe)
                }
                
                if times < 0 {

                    iaNode.run(SKAction.repeatForever(action))

                } else {

                    iaNode.run(SKAction.repeat(action, count: times))
                }
            }
        })
    }
}
