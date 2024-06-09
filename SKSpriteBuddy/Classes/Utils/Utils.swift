//
//  Utils.swift
//  Pods
//
//  Created by Rafael Moura on 15/03/17.
//  Copyright © 2023 Nilframe. All rights reserved.
//

import Foundation

public enum IAXMLParsingError : Error {
    case invalidXMLElement(message: String)
    case invalidAttribute(message: String)
    case invalidXMLStructure(message: String)
}

struct IAXMLConstants {
    
    // Node xml element parse
    static let xmlElement = "bone"
    static let entityElement = "entity"
    
    static let uuidAttribute = "uuid"
    static let nameAttribute = "name"
    static let blendModeAttribute = "blendMode"
    static let alphaAttribute = "alpha"
    static let colorBlendFactorAttribute = "colorBlendFactor"
    static let documentNameAttribute = "documentName"
    
    static let positionElement = "position"
    static let zPositionElement = "zPosition"
    static let anchorPointElement = "anchorPoint"
    static let sizeElement = "size"
    static let rotationElement = "rotation"
    static let childrenElement = "children"
    static let colorElement = "color"
    
    // Skins xml element parse
    static let skinsElement = "skins"
    static let skinElement = "skin"
    static let entityInfoElement = "entityInfo"
    static let textureElement = "texture"
    
    static let defaultSkinAttribute = "workingSkin"
    static let boneVisibilityAttribute = "isVisible"
    
    // Animation xml element parse
    static let scaleElement = "scale"
    static let keyframeWrapperElement = "keyframeWrapper"
    static let keyframeElement = "keyframe"
    static let animationElement = "animation"
    static let animationsElement = "animations"
    
    static let timingModeAttribute = "timingMode"
    static let frameAttribute = "frame"
    static let startFrameAttribute = "startFrame"
    static let endFrameAttribute = "endFrame"
    static let frameDurationAttribute = "frameDuration" 
}

extension CGPoint {

    init?(xmlElement: AEXMLElement) {

        guard let xString = xmlElement.attributes["x"], let xFloat = Float(xString) else { return nil }
        guard let yString = xmlElement.attributes["y"], let yFloat = Float(yString) else { return nil }

        self.init()

        self.x = CGFloat(xFloat)
        self.y = CGFloat(yFloat)
    }
    
    func xmlElement() -> AEXMLElement {

        let attributes = ["x": "\(self.x)", "y": "\(self.y)"]
        return AEXMLElement("point", value: nil, attributes: attributes)
    }
}

extension CGFloat {
    init?(xmlElement: AEXMLElement) {

        guard let valueString = xmlElement.attributes["value"], let value = Float(valueString) else { return nil }
        self.init(value)
    }
    
    func xmlElement() -> AEXMLElement {

        let attributes = ["value": "\(self)"]
        return AEXMLElement("float", value: nil, attributes: attributes)
    }
}

extension String {

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
        
        guard let floatValue = Float(self) else{ return nil }
        
        return CGFloat(floatValue)
    }
}

extension CGSize {

    init?(xmlElement: AEXMLElement) {

        guard let widthString = xmlElement.attributes["width"], let widthFloat = Float(widthString) else { return nil }

        guard let heightString = xmlElement.attributes["height"], let heightFloat = Float(heightString) else { return nil }

        self.init()

        self.width = CGFloat(widthFloat)
        self.height = CGFloat(heightFloat)
    }
    
    func xmlElement() -> AEXMLElement {

        let attributes = ["width": "\(self.width)", "height": "\(self.height)"]
        return AEXMLElement("size", value: nil, attributes: attributes)
    }
}

extension UIColor {

    convenience init(xmlElement: AEXMLElement?) {

        let redAttribute = xmlElement?.attributes["red"] ?? "0"
        let red = Float(redAttribute) ?? 0

        let greenAttribute = xmlElement?.attributes["green"] ?? "0"
        let green = Float(greenAttribute) ?? 0

        let blueAttribute = xmlElement?.attributes["blue"] ?? "0"
        let blue = Float(blueAttribute) ?? 0

        let alphaAttribute = xmlElement?.attributes["alpha"] ?? "0"
        let alpah = Float(alphaAttribute) ?? 0

        self.init(red: CGFloat(red),
                  green: CGFloat(green),
                  blue: CGFloat(blue),
                  alpha: CGFloat(alpah))
    }
}
