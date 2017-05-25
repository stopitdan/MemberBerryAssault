//
//  StartScene.swift
//  Invaders
//
//  Created by Dan Wiegand on 11/13/16.
//  Copyright © 2016 Dan Wiegand. All rights reserved.
//

import Foundation
import SpriteKit
import UIKit


class StartScene: SKScene {
    
    let startLabel = SKLabelNode(fontNamed: "theBoldFont")
    let howToPlayLabel = SKLabelNode(fontNamed: "theBoldFont")
    var x = true
    
    
    
    
    
    override func didMove(to view: SKView) {
        
//        if var x == true {
            MusicHelper.sharedHelper.playBackgroundMusic()
//            var x = false
//        }
        
        
            let background = SKSpriteNode(imageNamed: "mainmenubg")
            background.size = self.size
            background.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height/2))
            background.zPosition = 0
            self.addChild(background)
        
        
        
        startLabel.text = "Start Game"
        startLabel.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height) * 0.116)
        startLabel.zPosition = 5
        startLabel.fontSize = 170
        startLabel.fontColor = SKColor.white
        self.addChild(startLabel)
        
        howToPlayLabel.text = "How To Play"
        howToPlayLabel.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height) * 0.037)
        howToPlayLabel.zPosition = 5
        howToPlayLabel.fontSize = 150
        howToPlayLabel.fontColor = SKColor.white
        self.addChild(howToPlayLabel)
        
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            
            let reveal = SKTransition.reveal(with: .left,
                                             duration: 0.6)
            let pointOfTouch = touch.location(in: self)
            
            if startLabel.contains(pointOfTouch) {
                
                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                self.view!.presentScene(sceneToMoveTo, transition: reveal)
                
            }
            
            if howToPlayLabel.contains(pointOfTouch) {
                let sceneToMoveTo = HowToPlayScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                self.view!.presentScene(sceneToMoveTo, transition: reveal)
            }
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?){
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)

            if startLabel.contains(pointOfTouch) {
                
                let scaleIn = SKAction.scale(to: 1.14, duration: 0.05)
                let scaleOut = SKAction.scale(to: 1, duration: 0.05)
                let scale = SKAction.sequence([scaleIn, scaleOut])
                startLabel.run(scale)
            }
            
            if howToPlayLabel.contains(pointOfTouch) {
                let scaleIn = SKAction.scale(to: 1.14, duration: 0.05)
                let scaleOut = SKAction.scale(to: 1, duration: 0.05)
                let scale = SKAction.sequence([scaleIn, scaleOut])
                howToPlayLabel.run(scale)
            }
        }
    }
}
