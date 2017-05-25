//
//  GameOverScene.swift
//  Invaders
//
//  Created by Dan Wiegand on 11/13/16.
//  Copyright © 2016 Dan Wiegand. All rights reserved.
//

import Foundation
import UIKit
import SpriteKit


class GameOverScene: SKScene {
    
    let gameOverLabel = SKLabelNode(fontNamed: "theBoldFont")
   
    let restartLabel = SKLabelNode(fontNamed: "theBoldFont")
    
    let mainMenuLabel = SKLabelNode(fontNamed: "theBoldFont")
    
    override func didMove(to view: SKView) {
        
        let background = SKSpriteNode(imageNamed: "blood")
        background.position = CGPoint(x: (self.size.width) / 2, y: (self.size.height / 2) - 50)
        background.zPosition = 0
        self.addChild(background)
        
        
        let scoreLabel = SKLabelNode(fontNamed: "theBoldFont")
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 130
        scoreLabel.fontColor = SKColor.white
        scoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2)
        scoreLabel.zPosition = 1
        self.addChild(scoreLabel)
        
        
        let defaults = UserDefaults()
        var highScoreNumber = defaults.integer(forKey: "highScoreSaved")
        
        if gameScore > highScoreNumber {
            highScoreNumber = gameScore
            defaults.set(highScoreNumber, forKey: "highScoreSaved")
        }
        
        
        let highScoreLabel = SKLabelNode(fontNamed: "theBoldFont")
        highScoreLabel.text = "Highscore: \(highScoreNumber)"
        highScoreLabel.fontSize = 130
        highScoreLabel.fontColor = SKColor.white
        highScoreLabel.zPosition = 1
        highScoreLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.4)
        self.addChild(highScoreLabel)
        
        
        restartLabel.text = "Restart"
        restartLabel.fontSize = 100
        restartLabel.fontColor = SKColor.white
        restartLabel.zPosition = 1
        restartLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.25)
        self.addChild(restartLabel)
        
        mainMenuLabel.text = "Main Menu"
        mainMenuLabel.fontSize = 100
        mainMenuLabel.fontColor = SKColor.white
        mainMenuLabel.zPosition = 1
        mainMenuLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.15)
        self.addChild(mainMenuLabel)

        
        gameOverLabel.text = "Game Over"
        gameOverLabel.fontSize = 150
        gameOverLabel.fontColor = SKColor.white
        gameOverLabel.zPosition = 1
        gameOverLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.75)
        self.addChild(gameOverLabel)
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch) {
                
                MusicHelper.sharedHelper.playBackgroundMusic()

                let sceneToMoveTo = GameScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                self.view!.presentScene(sceneToMoveTo)
    
            }
            
            if mainMenuLabel.contains(pointOfTouch) {
                MusicHelper.sharedHelper.playBackgroundMusic()
                
                let sceneToMoveTo = StartScene(size: self.size)
                sceneToMoveTo.scaleMode = self.scaleMode
                self.view!.presentScene(sceneToMoveTo)
            }
        }
    }
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?){
        for touch: AnyObject in touches {
            
            let pointOfTouch = touch.location(in: self)
            
            if restartLabel.contains(pointOfTouch) {
                let scaleIn = SKAction.scale(to: 1.14, duration: 0.05)
                let scaleOut = SKAction.scale(to: 1, duration: 0.05)
                let scale = SKAction.sequence([scaleIn, scaleOut])
                restartLabel.run(scale)
                
            }
            
            if mainMenuLabel.contains(pointOfTouch) {
                let scaleIn = SKAction.scale(to: 1.14, duration: 0.05)
                let scaleOut = SKAction.scale(to: 1, duration: 0.05)
                let scale = SKAction.sequence([scaleIn, scaleOut])
                mainMenuLabel.run(scale)
            }
        }
    }
}
