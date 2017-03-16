//
//  Keyframe.swift
//  Pods
//
//  Created by Rafael Moura on 16/03/17.
//
//

import Foundation
import AEXML

class Keyframe: NSObject {
    
    var position: CGPoint = CGPoint.zero
    var rotation: CGFloat = 0
    var size: CGSize = CGSize.zero
    var scale: CGPoint = CGPoint(x: 1, y: 1)
    var timingMode: TimingMode = .linear
    
    enum TimingMode: String {
        case linear = "linear"
        case easeIn = "easeIn"
        case easeOut = "easeOut"
        case easeInEaseOut = "easeInEaseOut"
    }
    
    override init() {
        super.init()
    }
    
    func sync(with node: IASpriteNode) {
        position = node.position
        rotation = node.zRotation
        size = node.size
        scale = CGPoint(x: node.xScale, y: node.yScale)
    }
    
    init(xmlElement: AEXMLElement) throws {
        
        guard xmlElement.name == IAXMLConstants.keyframeElement else {
            throw IAXMLParsingError.invalidXMLElement(message: "\(xmlElement.name) where were expected a keyframe xml element.")
        }
        
        guard let timingModeString = xmlElement.attributes[IAXMLConstants.timingModeAttribute],
            let timingMode = TimingMode(rawValue: timingModeString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"position\" element into keyframe element.")
        }
        
        guard let position = CGPoint(xmlElement: xmlElement[IAXMLConstants.positionElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"position\" element into keyframe element.")
        }
        
        guard let rotation = CGFloat(xmlElement: xmlElement[IAXMLConstants.rotationElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"rotation\" element into keyframe element.")
        }
        
        guard let size = CGSize(xmlElement: xmlElement[IAXMLConstants.sizeElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"size\" element into keyframe element.")
        }
        
        guard let scale = CGPoint(xmlElement: xmlElement[IAXMLConstants.scaleElement]) else {
            throw IAXMLParsingError.invalidXMLElement(message: "Expected \"scale\" element into keyframe element.")
        }
        

        self.timingMode = timingMode
        self.position = position
        self.rotation = rotation
        self.size = size
        self.scale = scale
        
        super.init()
    }
}
