//
//  IASpriteNode.swift
//  Pods
//
//  Created by Rafael Moura on 15/03/17.
//
//

import Foundation
import SpriteKit
import AEXML

public class IASpriteNode: SKSpriteNode {

    private(set) var uuid: NSUUID
    private(set) var documentName: String
    
    public init(xmlElement: AEXMLElement) throws {
        
        guard xmlElement.name == IAXMLConstants.xmlElement else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected a \"bone\" element")
        }
        
        guard let uuidString = xmlElement.attributes[IAXMLConstants.uuidAttribute],
            let uuid = NSUUID(uuidString: uuidString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"uuid\" attribute in bone xml element")
        }
        
        guard let name = xmlElement.attributes[IAXMLConstants.nameAttribute] else {
            throw IAXMLParsingError.invalidAttribute(message: "Expected \"name\" attribute")
        }
        
        guard let blendModeString = xmlElement.attributes[IAXMLConstants.blendModeAttribute],
            let blendModeInt = Int(blendModeString), let blendMode = SKBlendMode(rawValue: blendModeInt) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"blendMode\" attribute in bone xml element")
        }
        
        guard let alphaString = xmlElement.attributes[IAXMLConstants.alphaAttribute],
            let alpha = Float(alphaString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"alpha\" attribute in bone xml element")
        }
        
        guard let position = CGPoint(xmlElement: xmlElement[IAXMLConstants.positionElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"position\" element")
        }
        
        guard let zPosition = CGFloat(xmlElement: xmlElement[IAXMLConstants.zPositionElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"zPosition\" element")
        }
        
        guard let anchorPoint = CGPoint(xmlElement: xmlElement[IAXMLConstants.anchorPointElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"anchorPoint\" element")
        }
        
        guard let size = CGSize(xmlElement: xmlElement[IAXMLConstants.sizeElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"size\" element")
        }
        
        guard let rotation = CGFloat(xmlElement: xmlElement[IAXMLConstants.rotationElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"rotation\" element")
        }
        
        guard let documentName = xmlElement.attributes[IAXMLConstants.documentNameAttribute] else {
            throw IAXMLParsingError.invalidAttribute(message: "Expected \"documentName\" attribute")
        }
        
        self.uuid = uuid
        self.documentName = documentName
        
        super.init(texture: nil, color: .clear, size: CGSize.zero)
        
        self.name = name
        self.blendMode = SKBlendMode(rawValue: blendModeInt)!
        self.alpha = CGFloat(alpha)
        self.position = position
        self.zPosition = zPosition
        self.anchorPoint = anchorPoint
        self.size = size
        self.zRotation = rotation
        
        for childElement in xmlElement[IAXMLConstants.childrenElement].children {
            self.addChild(try IASpriteNode(xmlElement: childElement))
        }
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
