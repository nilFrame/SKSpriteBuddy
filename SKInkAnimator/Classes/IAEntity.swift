//
//  IAEntity.swift
//  Pods
//
//  Created by Rafael Moura on 15/03/17.
//  Copyright © 2023 InkAnimator. All rights reserved.
//

import Foundation
import SpriteKit

public enum EntityParsingError: Error {
    case invalidEntityName
}

enum AnimationRunCount {

    case times(Int)
    case forever
}

public class IAEntity: SKNode {

    var size: CGSize
    private var document: AEXMLDocument
    private var loadedSkins = [String : IASkin]()
    private var loadedAnimations: [String : IAAnimation] = [:]
    private var info: [UUID : String] = [:]
    private var xmlElementByUUID: [UUID: AEXMLElement] = [:]
    
    //
    // MARK: - Initializers
    //
    
    public convenience init(withName name: String) async throws {
        
        let document = try IAEntity.document(with: name)
        let skinsElement = document.root[IAXMLConstants.skinsElement]
        let defaultSkinElement = skinsElement[IAXMLConstants.skinElement]

        guard let defaultSkinName = defaultSkinElement.attributes[IAXMLConstants.nameAttribute] else {
            throw IAXMLParsingError.invalidAttribute(message: "Expecting \"name\" attribute in the skin element.")
        }
        
        try await self.init(xmlDocument: document, andSkin: defaultSkinName)
        
        self.name = name
    }
    
    public convenience init(withName name: String, andSkin skinName: String) async throws {
        
        let document = try IAEntity.document(with: name)
        
        try await self.init(xmlDocument: document, andSkin: skinName)
        
        self.name = name
    }
    
    private init(xmlDocument document: AEXMLDocument, andSkin skinName: String) async throws {
        
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
            self.xmlElementByUUID[node.uuid] = childElement
            self.addChild(node)
        }
        
        try self.loadEntityInfo()
        try await self.setSkin(named: skinName)
    }
    
    //
    // MARK: - Skins stack
    //
    
    public func setSkin(named skinName: String) async throws {

        if let preloadedSkin = loadedSkins[skinName] {

            self.loadTextures(for: preloadedSkin)
            
        } else {

            let skin = try await self.preload(skinNamed: skinName)
            self.loadTextures(for: skin)
        }
    }

    public func releaseSkin(named skinName: String) {
        self.loadedSkins.removeValue(forKey: skinName)
    }
    
    //
    // MARK: - Entitty Preload stack
    //
    
    public func preload(skins names: [String]) async throws {

        return await withThrowingTaskGroup(of: IASkin.self) { group in

            for skinName in names {

                group.addTask {

                    try await self.preload(skinNamed: skinName)
                }
            }
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //
    // MARK: - Animations stack
    //

    public func stopAnimations() {

        self.removeAllActions()

        self.enumerateChildNodes(withName: ".//*") { (node, stop) in

            node.removeAllActions()

            if let iaNode = node as? IASpriteNode,
               let xmlElement = self.xmlElementByUUID[iaNode.uuid] {

                iaNode.configure(with: xmlElement)
            }
        }
    }

    public func run(animationNamed animationName: String) async throws {

        try await self.run(animationNamed: animationName, times: 1)
    }

    public func run(animationNamed animationName: String,  times: Int) async throws {

        if let loadedAnimation = self.loadedAnimations[animationName] {

            self.run(loadedAnimation, .times(times))

        } else {

            async let animation = try self.preloadAnimation(named: animationName)
            try await self.run(animation, .times(times))
        }
    }
    
    public func runForever(animationNamed animationName: String) async throws {
        
        if let loadedAnimation = self.loadedAnimations[animationName] {

            self.run(loadedAnimation, .forever)

        } else {

            async let animation = try self.preloadAnimation(named: animationName)
            try await self.run(animation, .forever)
        }
    }
    
    public func preload(animations names: [String]) async throws {

        return await withThrowingTaskGroup(of: IAAnimation.self) { group in

            for animationName in names {

                group.addTask {

                    try await self.preloadAnimation(named: animationName)
                }
            }
        }
    }
    
    public func releaseAnimation(named animationName: String) {

        self.loadedAnimations.removeValue(forKey: animationName)
    }
}

// MARK: - Private
extension IAEntity {

    //
    // MARK: - Load textures
    //
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

    private func loadEntityInfo() throws {

        let skinsElement = document.root[IAXMLConstants.skinsElement]
        let entityInfoElement = skinsElement[IAXMLConstants.entityInfoElement]

        for boneElement in entityInfoElement.children {

            guard let uuidString = boneElement.attributes[IAXMLConstants.uuidAttribute], let uuid = UUID(uuidString: uuidString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"uuid\" attribute for bone element into entityInfo element")
            }

            let textureElement = boneElement[IAXMLConstants.textureElement]
            guard let textureName = textureElement.attributes[IAXMLConstants.nameAttribute] else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"name\" attribute for bone element into entityInfo element")
            }

            self.info[uuid] = textureName
        }
    }

    @discardableResult
    private func preload(skinNamed skinName: String) async throws -> IASkin {

        guard let skinElement = self.skinXMLElement(named: skinName) else {

            throw IAXMLParsingError.invalidXMLElement(message: "Skin named \(skinName) not found.")
        }

        let skin = try IASkin(xmlElement: skinElement, entityInfo: self.info)

        await skin.preload()
        self.loadedSkins[skinName] = skin

        return skin
    }

    //
    // MARK: - Document
    //
    private static func document(with entityName: String) throws -> AEXMLDocument {

        guard let documentURL = Bundle.main.url(forResource: entityName, withExtension: ".xml") else {
            throw EntityParsingError.invalidEntityName
        }

        let xmlData = try Data(contentsOf: documentURL)

        return try AEXMLDocument(xmlData: xmlData)
    }

    private func skinXMLElement(named skinName: String) -> AEXMLElement? {

        let skinsElement = self.document.root[IAXMLConstants.skinsElement]

        return skinsElement.children.first {

            let nameAttribute = $0.attributes[IAXMLConstants.nameAttribute]
            return nameAttribute == skinName
        }
    }

    //
    // MARK: - Actions
    //

    @discardableResult
    private func preloadAnimation(named animationName: String) async throws -> IAAnimation {

        async let animation = try self.animation(named: animationName)
        try await self.loadedAnimations[animationName] = animation
        return try await animation
    }

    private func run(_ animation: IAAnimation, _ times: AnimationRunCount) {

        self.enumerateChildNodes(withName: ".//*",
                                 using: { (node, stop) in

            node.removeAllActions()

            guard let iaNode = node as? IASpriteNode else {
                return
            }

            if let action = animation.actions[iaNode.uuid] {


                if let startKeyframe = animation.startingKeyframeForBone[iaNode.uuid] {

                    iaNode.configure(with: startKeyframe)
                }

                switch times {

                case .times(let times):

                    iaNode.run(SKAction.repeat(action, count: times))

                case .forever:

                    iaNode.run(SKAction.repeatForever(action))
                }
            }
        })
    }

    private func animation(named animationName: String) async throws -> IAAnimation {

        if let animation = loadedAnimations[animationName] {

            return animation

        } else {

            guard let animationElement = self.animationXMLElement(for: animationName) else {

                throw IAXMLParsingError.invalidXMLElement(message: "Animation named \(animationName) not found.")
            }

            return try await withUnsafeThrowingContinuation { continuation in

                Task.detached(priority: .background) {

                    let animation = try IAAnimation(xmlElement: animationElement)
                    continuation.resume(with: .success(animation))
                }
            }
        }
    }

    private func animationXMLElement(for animationName: String) -> AEXMLElement? {

        let animationsElement = document.root[IAXMLConstants.animationsElement]

        return animationsElement.children.first {

            let nameAttribute = $0.attributes[IAXMLConstants.nameAttribute]
            return nameAttribute == animationName
        }
    }
}
