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


class HowToPlayScene: SKScene {
    
    
    let mainMenuLabel = SKLabelNode(fontNamed: "theBoldFont")

    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "howtoplaybg")
        background.size = self.size
        background.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height/2))
        background.zPosition = 0
        self.addChild(background)
        
        let howToPlayLabel = SKLabelNode(fontNamed: "theBoldFont")
        howToPlayLabel.text = "How To Play"
        howToPlayLabel.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height) * 0.85)
        howToPlayLabel.zPosition = 5
        howToPlayLabel.fontSize = 140
        howToPlayLabel.fontColor = SKColor.white
        self.addChild(howToPlayLabel)
        
        
        let enemiesLabel = SKLabelNode(fontNamed: "theBoldFont")
        enemiesLabel.text = "Shoot These"
        enemiesLabel.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height) * 0.77)
        enemiesLabel.zPosition = 5
        enemiesLabel.fontSize = 90
        enemiesLabel.fontColor = SKColor.white
        self.addChild(enemiesLabel)
        
        let randy = SKSpriteNode(imageNamed: "randy")
        randy.position = CGPoint(x: CGFloat(self.size.width/2) - 140, y: CGFloat(self.size.height) * 0.73)
        randy.setScale(0.42)
        randy.zPosition = 5
        self.addChild(randy)
        
        let butters = SKSpriteNode(imageNamed: "buttersExplosion")
        butters.position = CGPoint(x: CGFloat(self.size.width/2) - 5, y: CGFloat(self.size.height) * 0.73)
        butters.setScale(0.3)
        butters.zPosition = 5
        self.addChild(butters)
        
        let kyle = SKSpriteNode(imageNamed: "kyle")
        kyle.position = CGPoint(x: CGFloat(self.size.width/2) + 136, y: CGFloat(self.size.height) * 0.73)
        kyle.setScale(0.2)
        kyle.zPosition = 5
        self.addChild(kyle)
        
        let stan = SKSpriteNode(imageNamed: "stansmall")
        stan.position = CGPoint(x: CGFloat(self.size.width/2) + 280, y: (CGFloat(self.size.height) * 0.73) + 5)
        stan.setScale(0.33)
        stan.zPosition = 5
        self.addChild(stan)
        
        let principle = SKSpriteNode(imageNamed: "principle")
        principle.position = CGPoint(x: CGFloat(self.size.width/2) - 270, y: CGFloat(self.size.height) * 0.73)
        principle.setScale(0.17)
        principle.zPosition = 5
        self.addChild(principle)
        
        let powerupsLabel = SKLabelNode(fontNamed: "theBoldFont")
        powerupsLabel.text = "Power Ups"
        powerupsLabel.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height) * 0.635)
        powerupsLabel.zPosition = 5
        powerupsLabel.fontSize = 90
        powerupsLabel.fontColor = SKColor.white
        self.addChild(powerupsLabel)
        
        let life = SKSpriteNode(imageNamed: "extralife")
        life.position = CGPoint(x: CGFloat(self.size.width/2) + 105, y: CGFloat(self.size.height) * 0.58)
        life.setScale(0.24)
        life.zPosition = 5
        self.addChild(life)
        
        let tripleShot = SKSpriteNode(imageNamed: "tripleshot")
        tripleShot.position = CGPoint(x: CGFloat(self.size.width/2) - 115, y: (CGFloat(self.size.height) * 0.58) - 12)
        tripleShot.setScale(0.3)
        tripleShot.zPosition = 5
        self.addChild(tripleShot)
        
        let bossLabel = SKLabelNode(fontNamed: "theBoldFont")
        bossLabel.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height) * 0.48)
        bossLabel.zPosition = 5
        bossLabel.text = "Boss Level"
        bossLabel.fontSize = 90
        bossLabel.fontColor = SKColor.white
        self.addChild(bossLabel)

        let bossImage = SKSpriteNode(imageNamed: "cartmanblank")
        bossImage.position = CGPoint(x: CGFloat(self.size.width/2) - 5, y: CGFloat(self.size.height) * 0.426)
        bossImage.setScale(0.24)
        bossImage.zPosition = 5
        self.addChild(bossImage)
        
        let tapLabel = SKLabelNode(fontNamed: "theBoldFont")
        tapLabel.text = "1.    Tap to shoot berries"
        tapLabel.position = CGPoint(x: CGFloat(self.size.width/2) - 22, y: CGFloat(self.size.height) * 0.33)
        tapLabel.zPosition = 5
        tapLabel.fontSize = 75
        tapLabel.fontColor = SKColor.white
        self.addChild(tapLabel)
        
        let dragLabel = SKLabelNode(fontNamed: "theBoldFont")
        dragLabel.text = "2.    Drag to move player"
        dragLabel.position = CGPoint(x: CGFloat(self.size.width/2) - 14, y: CGFloat(self.size.height) * 0.28)
        dragLabel.zPosition = 5
        dragLabel.fontSize = 75
        dragLabel.fontColor = SKColor.white
        self.addChild(dragLabel)
        
//        let powerUpHintLabel = SKLabelNode(fontNamed: "theBoldFont")
//        powerUpHintLabel.text = "3.    grab power ups by"
//        powerUpHintLabel.position = CGPoint(x: CGFloat(self.size.width/2) - 52, y: CGFloat(self.size.height) * 0.23)
//        powerUpHintLabel.zPosition = 5
//        powerUpHintLabel.fontSize = 75
//        powerUpHintLabel.fontColor = SKColor.white
//        self.addChild(powerUpHintLabel)
//        let powerUpHintLabel2 = SKLabelNode(fontNamed: "theBoldFont")
//        powerUpHintLabel2.text = "moving player onto them"
//        powerUpHintLabel2.position = CGPoint(x: CGFloat(self.size.width/2) + 10, y: CGFloat(self.size.height) * 0.19)
//        powerUpHintLabel2.zPosition = 5
//        powerUpHintLabel2.fontSize = 75
//        powerUpHintLabel2.fontColor = SKColor.white
//        self.addChild(powerUpHintLabel2)
        let powerUpHintLabel = SKLabelNode(fontNamed: "theBoldFont")
        powerUpHintLabel.text = "3.    move player onto"
        powerUpHintLabel.position = CGPoint(x: CGFloat(self.size.width/2) - 58, y: CGFloat(self.size.height) * 0.23)
        powerUpHintLabel.zPosition = 5
        powerUpHintLabel.fontSize = 75
        powerUpHintLabel.fontColor = SKColor.white
        self.addChild(powerUpHintLabel)
        let powerUpHintLabel2 = SKLabelNode(fontNamed: "theBoldFont")
        powerUpHintLabel2.text = "power ups to collect"
        powerUpHintLabel2.position = CGPoint(x: CGFloat(self.size.width/2) + 60, y: CGFloat(self.size.height) * 0.19)
        powerUpHintLabel2.zPosition = 5
        powerUpHintLabel2.fontSize = 75
        powerUpHintLabel2.fontColor = SKColor.white
        self.addChild(powerUpHintLabel2)
        
        let hintLabel = SKLabelNode(fontNamed: "theBoldFont")
        hintLabel.text = "Hint: Use two fingers!"
        hintLabel.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height) * 0.13)
        hintLabel.zPosition = 5
        hintLabel.fontSize = 60
        hintLabel.fontColor = SKColor.white
        self.addChild(hintLabel)

        mainMenuLabel.text = "Main Menu"
        mainMenuLabel.fontSize = 100
        mainMenuLabel.fontColor = SKColor.white
        mainMenuLabel.zPosition = 1
        mainMenuLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.05)
        self.addChild(mainMenuLabel)

        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            let reveal = SKTransition.reveal(with: .right,
                                             duration: 0.6)
            
            if mainMenuLabel.contains(pointOfTouch) {
               
                let sceneToMoveTo = StartScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                self.view!.presentScene(sceneToMoveTo, transition: reveal)
                
            }

        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            
            if mainMenuLabel.contains(pointOfTouch) {
                let scaleIn = SKAction.scale(to: 1.14, duration: 0.05)
                let scaleOut = SKAction.scale(to: 1, duration: 0.05)
                let scale = SKAction.sequence([scaleIn, scaleOut])
                mainMenuLabel.run(scale)
            }
        }
    }
    
    
    
}
