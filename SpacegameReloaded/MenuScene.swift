//
//  MenuScene.swift
//  SpacegameReloaded
//
//  Created by serhan on 18.12.23.
//

import SpriteKit

class MenuScene: SKScene {

    var starfield:SKEmitterNode!
    
    var newGameButtonNode:SKSpriteNode!
    var difficultyButtonNode:SKSpriteNode!
    var difficultyLabelNode:SKLabelNode!
    
    
    override func didMove(to view: SKView) {
        
        starfield = self.childNode(withName: "starfield") as! SKEmitterNode
        starfield.advanceSimulationTime(10)
        
        newGameButtonNode = self.childNode(withName: "newGameButton") as! SKSpriteNode
        difficultyButtonNode = self.childNode(withName: "difficultyButton") as! SKSpriteNode
        
        // 11 : 53 deqiqede qaldiq
        
    }
    
    
}
