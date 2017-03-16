//
//  Utils.swift
//  Pods
//
//  Created by Rafael Moura on 15/03/17.
//
//

import Foundation
import AEXML

public enum IAXMLParsingError : Error {
    case invalidXMLElement(message: String)
    case invalidAttribute(message: String)
    case invalidXMLStructure(message: String)
}

public struct IAXMLConstants {
    
    // Node xml element parse
    static let xmlElement = "bone"
    static let entityElement = "entity"
    static let uuidAttribute = "uuid"
    static let nameAttribute = "name"
    static let blendModeAttribute = "blendMode"
    static let alphaAttribute = "alpha"
    static let documentNameAttribute = "documentName"
    
    static let positionElement = "position"
    static let zPositionElement = "zPosition"
    static let anchorPointElement = "anchorPoint"
    static let sizeElement = "size"
    static let rotationElement = "rotation"
    static let childrenElement = "children"
    
    // Skins xml element parse
    static let skinsElement = "skins"
    static let skinElement = "skin"
    static let entityInfoElement = "entityInfo"
    static let textureElement = "texture"
    static let defaultSkinAttribute = "workingSkin"
    static let boneVisibilityAttribute = "isVisible"
}

public extension CGPoint {
    init?(xmlElement: AEXMLElement) {
        guard let xString = xmlElement.attributes["x"], let xFloat = Float(xString) else { return nil }
        guard let yString = xmlElement.attributes["y"], let yFloat = Float(yString) else { return nil }
        self.x = CGFloat(xFloat)
        self.y = CGFloat(yFloat)
    }
    
    func xmlElement() -> AEXMLElement {
        let attributes = ["x": "\(self.x)", "y": "\(self.y)"]
        return AEXMLElement(name: "point", value: nil, attributes: attributes)
    }
}

public extension CGFloat {
    init?(xmlElement: AEXMLElement) {
        guard let valueString = xmlElement.attributes["value"], let value = Float(valueString) else { return nil }
        self.init(value)
    }
    
    func xmlElement() -> AEXMLElement {
        let attributes = ["value": "\(self)"]
        return AEXMLElement(name: "float", value: nil, attributes: attributes)
    }
}

public extension String {
    func toBool() -> Bool? {
        switch self {
        case "True", "true":
            return true
        case "False", "false":
            return false
        default:
            return nil
        }
    }
    
    func toUUID() -> NSUUID? {
        return NSUUID(uuidString: self)
    }
    
    func toCGFloat() -> CGFloat?{
        
        guard let floatValue = Float(self) else{
            return nil
        }
        
        return CGFloat(floatValue)
        
    }
}


public extension CGSize {
    init?(xmlElement: AEXMLElement) {
        guard let widthString = xmlElement.attributes["width"], let widthFloat = Float(widthString) else { return nil }
        guard let heightString = xmlElement.attributes["height"], let heightFloat = Float(heightString) else { return nil }
        self.width = CGFloat(widthFloat)
        self.height = CGFloat(heightFloat)
    }
    
    func xmlElement() -> AEXMLElement {
        let attributes = ["width": "\(self.width)", "height": "\(self.height)"]
        return AEXMLElement(name: "size", value: nil, attributes: attributes)
    }
}
