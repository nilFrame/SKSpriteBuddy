//
//  SKSpriteNode+XMLParsing.swift
//  Pods
//
//  Created by Rafael Moura on 15/03/17.
//
//

import Foundation
import SpriteKit
import AEXML

//public enum XMLParsingError : Error {
//    case invalidXMLElement
//    case invalidUUID
//    case invalidName
//    case invalidDocumentName
//    case invalidBlendMode
//    case invalidAlpha
//    
//    case invalidPosition
//    case invalidZPosition
//    case invalidAnchorPoint
//    case invalidSize
//    case invalidRotation
//}
//
//public struct IAXMLConstants {
//    static let xmlElement = "bone"
//    static let uuidAttribute = "uuid"
//    static let nameAttribute = "name"
//    static let blendModeAttribute = "blendMode"
//    static let alphaAttribute = "alpha"
//    
//    static let positionElement = "position"
//    static let zPositionElement = "zPosition"
//    static let anchorPointElement = "anchorPoint"
//    static let sizeElement = "size"
//    static let rotationElement = "rotation"
//    static let childrenElement = "children"
//}

public extension SKSpriteNode {
    
    
//    convenience init(xmlElement: AEXMLElement) throws {
//        
//        guard xmlElement.name == IAXMLConstants.xmlElement else {
//            throw XMLParsingError.invalidXMLElement
//        }
//        
//        guard let uuidString = xmlElement.attributes[IAXMLConstants.uuidAttribute],
//            let uuid = NSUUID(uuidString: uuidString) else {
//                throw XMLParsingError.invalidUUID
//        }
//        
//        guard let name = xmlElement.attributes[IAXMLConstants.nameAttribute] else {
//            throw XMLParsingError.invalidName
//        }
//        
//        guard let blendModeString = xmlElement.attributes[IAXMLConstants.blendModeAttribute],
//            let blendModeInt = Int(blendModeString), let blendMode = SKBlendMode(rawValue: blendModeInt) else {
//                throw XMLParsingError.invalidBlendMode
//        }
//        
//        guard let alphaString = xmlElement.attributes[IAXMLConstants.alphaAttribute],
//            let alpha = Float(alphaString) else {
//                throw XMLParsingError.invalidAlpha
//        }
//        
//        guard let position = CGPoint(xmlElement: xmlElement[IAXMLConstants.positionElement]) else {
//            throw XMLParsingError.invalidPosition
//        }
//        
//        guard let zPosition = CGFloat(xmlElement: xmlElement[IAXMLConstants.zPositionElement]) else {
//            throw XMLParsingError.invalidZPosition
//        }
//        
//        guard let anchorPoint = CGPoint(xmlElement: xmlElement[IAXMLConstants.anchorPointElement]) else {
//            throw XMLParsingError.invalidAnchorPoint
//        }
//        
//        guard let size = CGSize(xmlElement: xmlElement[IAXMLConstants.sizeElement]) else {
//            throw XMLParsingError.invalidSize
//        }
//        
//        guard let rotation = CGFloat(xmlElement: xmlElement[IAXMLConstants.rotationElement]) else {
//            throw XMLParsingError.invalidRotation
//        }
//        
//        self.init(texture: nil, size: CGSize.zero)
//    }
    
}
