//
//  IASpriteNode.swift
//  Pods
//
//  Created by Rafael Moura on 15/03/17.
//  Copyright © 2023 Nilframe. All rights reserved.
//

import Foundation
import SpriteKit

class IASpriteNode: SKSpriteNode {

    private(set) var uuid: UUID
    private(set) var documentName: String
    private var xmlElementByUUID: [UUID: AEXMLElement] = [:]
    
    init(xmlElement: AEXMLElement) throws {
        
        guard xmlElement.name == IAXMLConstants.xmlElement else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected a \"bone\" element")
        }
        
        guard let uuidString = xmlElement.attributes[IAXMLConstants.uuidAttribute],
            let uuid = UUID(uuidString: uuidString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"uuid\" attribute in bone xml element")
        }
        
        guard let documentName = xmlElement.attributes[IAXMLConstants.documentNameAttribute] else {
            throw IAXMLParsingError.invalidAttribute(message: "Expected \"documentName\" attribute")
        }

        self.uuid = uuid
        self.documentName = documentName

        super.init(texture: nil, color: .clear, size: CGSize.zero)

        self.configure(with: xmlElement)

        for childElement in xmlElement[IAXMLConstants.childrenElement].children {

            let child = try IASpriteNode(xmlElement: childElement)
            self.xmlElementByUUID[child.uuid] = childElement
            
            self.addChild(child)
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with keyframe: Keyframe) {

        self.xScale = keyframe.scale.x
        self.yScale = keyframe.scale.y
        self.position = keyframe.position
        self.zRotation = keyframe.rotation
        self.color = keyframe.color
        self.colorBlendFactor = keyframe.colorBlendFactor
        self.alpha = keyframe.alpha
    }

    func configure(with xmlElement: AEXMLElement) {

        let name = xmlElement.attributes[IAXMLConstants.nameAttribute]
        let position = CGPoint(xmlElement: xmlElement[IAXMLConstants.positionElement]) ?? .zero
        let zPosition = CGFloat(xmlElement: xmlElement[IAXMLConstants.zPositionElement]) ?? .zero
        let anchorPoint = CGPoint(xmlElement: xmlElement[IAXMLConstants.anchorPointElement]) ?? .zero
        let size = CGSize(xmlElement: xmlElement[IAXMLConstants.sizeElement]) ?? .zero
        let rotation = CGFloat(xmlElement: xmlElement[IAXMLConstants.rotationElement]) ?? .zero

        let alphaAttributeString = xmlElement.attributes[IAXMLConstants.alphaAttribute]
        let colorBlendFactorAttributeString = xmlElement.attributes[IAXMLConstants.colorBlendFactorAttribute]

        let colorElement = xmlElement[IAXMLConstants.colorElement]

        if let blendModeString = xmlElement.attributes[IAXMLConstants.blendModeAttribute],
           let blendModeInt = Int(blendModeString),
           let blendMode = SKBlendMode(rawValue: blendModeInt) {

            self.blendMode = blendMode

        } else {

            self.blendMode = .alpha
        }

        self.name = name
        self.position = position
        self.zPosition = zPosition
        self.anchorPoint = anchorPoint
        self.size = size
        self.zRotation = rotation
        self.alpha = alphaAttributeString?.toCGFloat() ?? 1.0
        self.color = UIColor(xmlElement: colorElement)
        self.colorBlendFactor = colorBlendFactorAttributeString?.toCGFloat() ?? 0.0

        self.children.forEach { child in

            if let iaNode = child as? IASpriteNode,
               let xmlElement = self.xmlElementByUUID[iaNode.uuid] {

                iaNode.configure(with: xmlElement)
            }
        }
    }
}
