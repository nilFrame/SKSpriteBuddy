//
//  KeyframeWrapper.swift
//  Pods
//
//  Created by Rafael Moura on 16/03/17.
//
//

import Foundation
import AEXML

class KeyframeWrapper: NSObject {

    var keyframes: [Int : Keyframe]
    private var sortedKeys = [Int]()
    weak var animation: IAAnimation?
    
    subscript(frame: Int) -> Keyframe? {
        get { return keyframe(at: frame) }
    }
    
    func keyframe(at frame: Int) -> Keyframe? {
        return keyframes[frame]
    }
    
    init(xmlElement: AEXMLElement) throws {
        
        guard xmlElement.name == IAXMLConstants.keyframeWrapperElement else {
            throw IAXMLParsingError.invalidXMLElement(message: "\(xmlElement.name) where were expected a keyframeWrapper xml element.")
        }
        
        self.keyframes = [Int : Keyframe]()
        
        super.init()
        
        for child in xmlElement.children {
            guard let frameString = child.attributes[IAXMLConstants.frameAttribute],
                let frame = Int(frameString) else {
                    throw IAXMLParsingError.invalidAttribute(message: "Expected \"frame\" attribute in keyframe element.")
            }
            let keyframe = try Keyframe(xmlElement: child)
            add(keyframe: keyframe, at: frame)
        }
    }
    
    private func add(keyframe keyframe: Keyframe, at frame: Int) {
        keyframes[frame] = keyframe
        var index = 0
        while index < sortedKeys.count {
            if sortedKeys[index] > frame {
                sortedKeys.insert(frame, at: index)
                break
            }
            index += 1
        }
        if index == sortedKeys.count { sortedKeys.append(frame) }
    }
    
    func relativeKeyframe(at frame: Int) -> Keyframe {
        print("frame: \(frame)")
        guard let animation = animation else {
            print("ERRO! KeyframeWrapper sem animação! Retornando um Keyframe vazio.")
            return Keyframe()
        }
        guard keyframes.count > 0 else { return Keyframe() }
        if let keyframe = keyframe(at: frame) { return keyframe }
        
        // Se é startFrame
        if frame == 0 { return keyframes[sortedKeys.first!]! }
        
        // Se é endFrame
        if frame == animation.endFrame { return relativeKeyframe(at: 0) }
        
        var previousKeyframe: Keyframe
        var previousFrame: Int
        var nextKeyframe: Keyframe
        var nextFrame: Int
        
        var auxIndex = 0
        while auxIndex < keyframes.count {
            if sortedKeys[auxIndex] > frame { break }
            auxIndex += 1
        }
        
        // Calculando previousKeyTuple
        if auxIndex == 0 { // Se não tem nenhum keyframe antes do frame em questão
            if frame < animation.endFrame {
                previousKeyframe = relativeKeyframe(at: 0)
                previousFrame = 0
            } else {
                previousKeyframe = relativeKeyframe(at: animation.endFrame)
                previousFrame = animation.endFrame
            }
        } else { // Tem algum keyframe antes do frame em questão
            if frame < animation.endFrame || sortedKeys[auxIndex - 1] >= animation.endFrame {
                previousFrame = sortedKeys[auxIndex - 1]
                previousKeyframe = keyframes[previousFrame]!
            } else {
                previousFrame = animation.endFrame
                previousKeyframe = relativeKeyframe(at: animation.endFrame)
            }
        }
        
        // Calculando nextKeyTuple
        if auxIndex == keyframes.count { // Se não te nenhum keyframe depois do frame em questão
            if frame < animation.endFrame {
                nextFrame = animation.endFrame
                nextKeyframe = relativeKeyframe(at: animation.endFrame)
            } else {
                nextFrame = previousFrame
                nextKeyframe = previousKeyframe
            }
        } else { // Tem algum keyframe depois do frame em questão
            if frame > animation.endFrame || sortedKeys[auxIndex] <= animation.endFrame {
                nextFrame = sortedKeys[auxIndex]
                nextKeyframe = keyframes[nextFrame]!
            } else {
                nextFrame = animation.endFrame
                nextKeyframe = relativeKeyframe(at: animation.endFrame)
            }
        }
        
        // Calculando deltaKeyTuple
        var deltaFrame = nextFrame - previousFrame
        var relativeFrame = frame - previousFrame
        if deltaFrame == 0 {
            deltaFrame = 1
            relativeFrame = 1
        }
        
        let deltaXPosition = nextKeyframe.position.x - previousKeyframe.position.x
        let relativeXPosition = (deltaXPosition / CGFloat(deltaFrame)) * CGFloat(relativeFrame)
        let deltaYPosition = nextKeyframe.position.y - previousKeyframe.position.y
        let relativeYPosition = (deltaYPosition / CGFloat(deltaFrame)) * CGFloat(relativeFrame)
        let relativePosition = CGPoint(x: relativeXPosition, y: relativeYPosition)
        
        let deltaRotation = nextKeyframe.rotation - previousKeyframe.rotation
        let relativeRotation = (deltaRotation / CGFloat(deltaFrame)) * CGFloat(relativeFrame)
        
        let deltaWidth = nextKeyframe.size.width - previousKeyframe.size.width
        let relativeWidth = (deltaWidth / CGFloat(deltaFrame)) * CGFloat(relativeFrame)
        let deltaHeight = nextKeyframe.size.height - previousKeyframe.size.height
        let relativeHeight = (deltaHeight / CGFloat(deltaFrame)) * CGFloat(relativeFrame)
        let relativeSize = CGSize(width: relativeWidth, height: relativeHeight)
        
        let deltaXScale = nextKeyframe.scale.x - previousKeyframe.scale.x
        let relativeXScale = (deltaXScale / CGFloat(deltaFrame)) * CGFloat(relativeFrame)
        let deltaYScale = nextKeyframe.scale.y - previousKeyframe.scale.y
        let relativeYScale = (deltaYScale / CGFloat(deltaFrame)) * CGFloat(relativeFrame)
        let relativeScale = CGPoint(x: relativeXScale, y: relativeYScale)
        
        let relativeKey = Keyframe()
        relativeKey.position = CGPoint(x: previousKeyframe.position.x + relativePosition.x, y: previousKeyframe.position.y + relativePosition.y)
        relativeKey.rotation = previousKeyframe.rotation + relativeRotation
        relativeKey.size = CGSize(width: previousKeyframe.size.width + relativeSize.width, height: previousKeyframe.size.height + relativeSize.height)
        relativeKey.scale = CGPoint(x: previousKeyframe.scale.x + relativeScale.x, y: previousKeyframe.scale.y + relativeScale.y)
        
        return relativeKey
    }

    
}
