//
//  IAAnimation.swift
//  Pods
//
//  Created by Rafael Moura on 16/03/17.
//
//

import Foundation
import SpriteKit
import AEXML

class IAAnimation: NSObject {

    var name: String
    var startFrame: Int
    var endFrame: Int
    var frameDuration: TimeInterval
    
    var actions: [NSUUID : SKAction]
    
    init(xmlElement: AEXMLElement) throws {
        
        guard xmlElement.name == IAXMLConstants.animationElement else {
            throw IAXMLParsingError.invalidXMLElement(message: "\(xmlElement.name) where were expected a animation xml element.")
        }
        
        guard let name = xmlElement.attributes[IAXMLConstants.nameAttribute] else {
            throw IAXMLParsingError.invalidAttribute(message: "Expected \"name\" attribute in animation xml element.")
        }
        
        guard let startFrameString = xmlElement.attributes[IAXMLConstants.startFrameAttribute],
            let startFrame = Int(startFrameString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"startFrame\" attribute in animation xml element.")
        }
        guard let endFrameString = xmlElement.attributes[IAXMLConstants.endFrameAttribute],
            let endFrame = Int(endFrameString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"endFrame\" attribute in animation xml element.")
        }
        guard let frameDurationString = xmlElement.attributes[IAXMLConstants.frameDurationAttribute],
            let frameDuration = TimeInterval(frameDurationString) else {
                throw IAXMLParsingError.invalidAttribute(message: "Expected \"frameDuration\" attribute in animation xml element.")
        }
        
        self.startFrame = startFrame
        self.endFrame = endFrame
        self.frameDuration = frameDuration
        self.name = name
        self.actions = [NSUUID : SKAction]()
        
        super.init()
        
        for child in xmlElement.children {
            
            guard let uuidString = child.attributes[IAXMLConstants.uuidAttribute],
                let uuid = NSUUID(uuidString: uuidString) else {
                    throw IAXMLParsingError.invalidAttribute(message: "Expected \"frameDuration\" attribute in animation xml element.")
            }
            let keyframeWrapper = try KeyframeWrapper(xmlElement: child)
            keyframeWrapper.animation = self
            self.actions[uuid] = try self.action(for: keyframeWrapper)
        }
    }
    
    private func sequence(for wrapper: KeyframeWrapper) throws -> SKAction {
        
        var actions = [SKAction]()
        
        var lastKeyframeIndex = self.startFrame
        for index in self.startFrame...self.endFrame {
            guard let keyframe = wrapper[index] else { continue }
            let duration = TimeInterval(index - lastKeyframeIndex) * self.frameDuration
            let lastKeyframe = wrapper[lastKeyframeIndex]
            let action = ActionFactory.action(for: keyframe, previousKeyframe: lastKeyframe, duration: duration)
            actions.append(action)
            lastKeyframeIndex = index
        }
        
        if lastKeyframeIndex < self.endFrame {
            let keyframe = wrapper.relativeKeyframe(at: self.endFrame)
            let duration = TimeInterval(self.endFrame - lastKeyframeIndex) * self.frameDuration
            let lastKeyframe = wrapper[lastKeyframeIndex]
            let action =  ActionFactory.action(for: keyframe, previousKeyframe: lastKeyframe, duration: duration)
            actions.append(action)
        }
        
        return SKAction.sequence(actions)
    }
    
    private func action(for wrapper: KeyframeWrapper) throws -> SKAction {
        let actionSequence = try sequence(for: wrapper)
        return actionSequence
    }
}
