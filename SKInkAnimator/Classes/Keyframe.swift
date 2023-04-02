//
//  Keyframe.swift
//  Pods
//
//  Created by Rafael Moura on 16/03/17.
//  Copyright © 2023 InkAnimator. All rights reserved.
//

import Foundation

struct Keyframe {
    
    var position: CGPoint = .zero
    var rotation: CGFloat = .zero
    var size: CGSize = CGSize.zero
    var scale: CGPoint = CGPoint(x: 1, y: 1)
    var timingMode: TimingMode = .linear
    var colorBlendFactor: CGFloat = .zero
    var alpha: CGFloat = 1.0
    var color: UIColor = .clear
    
    enum TimingMode: String {
        case linear = "linear"
        case easeIn = "easeIn"
        case easeOut = "easeOut"
        case easeInEaseOut = "easeInEaseOut"
    }

    init(position: CGPoint = .zero,
         rotation: CGFloat = .zero,
         size: CGSize = CGSize.zero,
         scale: CGPoint = CGPoint(x: 1, y: 1),
         timingMode: TimingMode = .linear,
         colorBlendFactor: CGFloat = .zero,
         alpha: CGFloat = 1.0,
         color: UIColor = .clear) {

        self.position = position
        self.rotation = rotation
        self.size = size
        self.scale = scale
        self.timingMode = timingMode
        self.colorBlendFactor = colorBlendFactor
        self.alpha = alpha
        self.color = color
    }

    init(xmlElement: AEXMLElement) throws {
        
        guard xmlElement.name == IAXMLConstants.keyframeElement else {
            throw IAXMLParsingError.invalidXMLElement(message: "\(xmlElement.name) where were expected a keyframe xml element.")
        }

        if let timingModeString = xmlElement.attributes[IAXMLConstants.timingModeAttribute] {

            self.timingMode = TimingMode(rawValue: timingModeString) ?? .linear

        } else {

            self.timingMode = .linear
        }

        self.position = CGPoint(xmlElement: xmlElement[IAXMLConstants.positionElement]) ?? .zero
        self.rotation = CGFloat(xmlElement: xmlElement[IAXMLConstants.rotationElement]) ?? .zero
        self.size = CGSize(xmlElement: xmlElement[IAXMLConstants.sizeElement]) ?? .zero
        self.scale = CGPoint(xmlElement: xmlElement[IAXMLConstants.scaleElement]) ?? CGPoint(x: 1, y: 1)
        self.color = UIColor(xmlElement: xmlElement[IAXMLConstants.colorElement])

        let colorBlendFactorAttribute = xmlElement.attributes[IAXMLConstants.colorBlendFactorAttribute]
        self.colorBlendFactor = colorBlendFactorAttribute?.toCGFloat() ?? 0

        let alphaAttribute = xmlElement.attributes[IAXMLConstants.alphaAttribute]
        self.alpha = alphaAttribute?.toCGFloat() ?? 1
    }
}
