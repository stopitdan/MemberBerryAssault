////
////  ChangeLevelScene.swift
////  Invaders
////
////  Created by Dan Wiegand on 11/17/16.
////  Copyright © 2016 Dan Wiegand. All rights reserved.
////
//
//import Foundation
//import SpriteKit
//import UIKit
//
//class ChangeLevelScene: SKScene {
//    
//    
//    override func didMove(to view: SKView) {
//        var levelNumber: Int = 0
//        levelNumber += 1
//        let vibrate = SKAction.run {
//            let generator = UIImpactFeedbackGenerator(style: .light)
//            generator.impactOccurred()
//        }
//        
//        let background = SKSpriteNode(imageNamed: "background")
//        background.name = "Background"
//        background.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height/2))
//        // background.anchorPoint = CGPoint(x: 0.5, y: 0.0)
//        background.zPosition = 0
//        self.addChild(background)
//        
//        
//        let levelUpLabel = SKLabelNode(fontNamed: "theBoldFont")
//        levelUpLabel.text = "Level \(levelNumber)"
//        levelUpLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.65)
//        levelUpLabel.fontSize = 250
//        levelUpLabel.isHidden = true
//        levelUpLabel.fontColor = SKColor.white
//        levelUpLabel.zPosition = 1
//        self.addChild(levelUpLabel)
//        
//        let fadeIn = SKAction.fadeIn(withDuration: 0.6)
//        let wait = SKAction.wait(forDuration: 3)
//        let fadeOut = SKAction.fadeOut(withDuration: 1)
//        let delete = SKAction.removeFromParent()
//        let change = SKAction.run {
//            let sceneToMoveTo = GameScene(size: self.size)
//            sceneToMoveTo.scaleMode = self.scaleMode
//            self.view!.presentScene(sceneToMoveTo)
//        }
//        let sequence = SKAction.sequence([fadeIn, wait, fadeOut, delete, change])
//        levelUpLabel.run(sequence)
//        
//        let randy = SKSpriteNode(imageNamed: "enemyShip")
//        randy.setScale(1)
//        randy.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.35)
//        randy.zPosition = 1
//        
//        let kyle = SKSpriteNode(imageNamed: "kyle")
//        kyle.setScale(1)
//        kyle.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.35)
//        kyle.zPosition = 1
//        
//        let butters = SKSpriteNode(imageNamed: "buttersexplosion")
//        butters.setScale(1)
//        butters.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.35)
//        butters.zPosition = 1
//        
//        let principle = SKSpriteNode(imageNamed: "principle")
//        principle.setScale(1)
//        principle.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.35)
//        principle.zPosition = 1
//        
//        let stan = SKSpriteNode(imageNamed: "stansmall")
//        stan.setScale(1)
//        stan.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.35)
//        stan.zPosition = 1
//
//        if levelNumber == 1 {
//            self.addChild(butters)
//            let buttersFadeIn = SKAction.fadeIn(withDuration: 0.6)
//            let buttersWait = SKAction.wait(forDuration: 1.5)
//            let buttersFadeOut = SKAction.fadeOut(withDuration: 1)
//            let buttersSequence = SKAction.sequence([buttersFadeIn, buttersWait, vibrate, buttersWait, buttersFadeOut, delete])
//            butters.run(buttersSequence)
//        }
//        if levelNumber == 2 {
//            self.addChild(randy)
//            let randyFadeIn = SKAction.fadeIn(withDuration: 0.6)
//            let randyWait = SKAction.wait(forDuration: 1.5)
//            let randyFadeOut = SKAction.fadeOut(withDuration: 1)
//            let randySequence = SKAction.sequence([randyFadeIn, randyWait, vibrate, randyWait, randyFadeOut, delete])
//            randy.run(randySequence)
//        }
//        if levelNumber == 3 {
//            self.addChild(kyle)
//            let kyleFadeIn = SKAction.fadeIn(withDuration: 0.6)
//            let kyleWait = SKAction.wait(forDuration: 1.5)
//            let kyleFadeOut = SKAction.fadeOut(withDuration: 1)
//            let kyleSequence = SKAction.sequence([kyleFadeIn, kyleWait, vibrate, kyleWait, kyleFadeOut, delete])
//            kyle.run(kyleSequence)
//        }
//        if levelNumber == 4 {
//            self.addChild(stan)
//            let stanFadeIn = SKAction.fadeIn(withDuration: 0.6)
//            let stanWait = SKAction.wait(forDuration: 1.5)
//            let stanFadeOut = SKAction.fadeOut(withDuration: 1)
//            let stanSequence = SKAction.sequence([stanFadeIn, stanWait, vibrate, stanWait, stanFadeOut, delete])
//            stan.run(stanSequence)
//        }
//        if levelNumber == 5 {
//            self.addChild(principle)
//            let principleFadeIn = SKAction.fadeIn(withDuration: 0.6)
//            let principleWait = SKAction.wait(forDuration: 1.5)
//            let principleFadeOut = SKAction.fadeOut(withDuration: 1)
//            let principleSequence = SKAction.sequence([principleFadeIn, principleWait, vibrate, principleWait, principleFadeOut, delete])
//            principle.run(principleSequence)
//        }
//        else {
//            print("Error: Level Not Found!")
//        }
//        
//    }
//    
//    
//}
