//
//  GameScene.swift
//  Invaders
//
//  Created by Dan Wiegand on 11/11/16.
//  Copyright © 2016 Dan Wiegand. All rights reserved.
//

import SpriteKit
import GameplayKit
import CoreMotion
import AVFoundation




class MusicHelper {
    static let sharedHelper = MusicHelper()
    var audioPlayer: AVAudioPlayer?
    
    func playBackgroundMusic() {
        let aSound = NSURL(fileURLWithPath: Bundle.main.path(forResource: "bgmusic2", ofType: "wav")!)
        do {
            audioPlayer = try AVAudioPlayer(contentsOf:aSound as URL)
            audioPlayer!.numberOfLoops = -1
            audioPlayer!.prepareToPlay()
            audioPlayer!.play()
        } catch {
            print("Cannot play the file")
        }
    }
    
    func stopBackgroundMusic () {
        audioPlayer!.stop()
    }
}


extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(netHex:Int) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff)
    }
}

var gameScore = 300

class GameScene: SKScene, SKPhysicsContactDelegate, AVAudioPlayerDelegate {
    
   
// set physics categories so we can differentiate contacts
    struct PhysicsCategories {
        static let None: UInt32 = 0
        static let Player: UInt32 = 1
        static let Bullet: UInt32 = 2
        static let Enemy: UInt32 = 3
        static let BossBullet: UInt32 = 4
        static let Principle: UInt32 = 5
        static let Boss: UInt32 = 6
        static let Life: UInt32 = 7
        static let TripleShot: UInt32 = 8
    }
    
// random num generator
    func random() -> CGFloat {
        return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
    }
    
    func random(min: CGFloat, max: CGFloat) -> CGFloat{
        return random() * (max - min) + min
    }
    
// game state machine for start/end game
    enum gameState {
        case preGame
        case inGame
        case postGame
    }

// gameScene starts "inGame" state
    var currentGameState = gameState.inGame

// create stan globally (there will only ever be one of each on screen at a time)
    

//  create life power globally

// lives globals
    var livesNumber: Int = 3
    let livesLabel = SKLabelNode(fontNamed: "theBoldFont")
    
    
    
    
// level / score / boss health globals
    var bossHealth = 100
    var levelNumber = 0
    let scoreLabel = SKLabelNode(fontNamed: "theBoldFont")
    
// sound effects!
    var sound: AVAudioPlayer?
    func playSound(soundVariable : SKAction) {
            run(soundVariable)
    }
    let bulletSound = SKAction.playSoundFileNamed("member.wav", waitForCompletion: true)
    var youLose = SKAction.playSoundFileNamed("president.wav", waitForCompletion: true)
    let randySound = SKAction.playSoundFileNamed("america.wav", waitForCompletion: false)

    
// create motion manager, for contact
    let manager = CMMotionManager()
    
// triple shot global
    var tripleShotCount = 0
    let tripleShotLabel = SKLabelNode(fontNamed: "theBoldFont")
//    let tripleShotLabel2 = SKLabelNode(fontNamed: "theBoldFont")
    
// temp boss health global
    let healthBarOutline = SKSpriteNode(imageNamed: "healthBarOutline")
    let healthBarInner = SKSpriteNode(imageNamed: "healthBarInner")
    
// pause globals
    let pauseButton = SKSpriteNode(imageNamed: "pause")
    let playButton = SKSpriteNode(imageNamed: "play")
    
// player is defined globally because there is only one
    let player = SKSpriteNode(imageNamed: "playerShip")
    let cartman = SKSpriteNode(imageNamed: "cartman")

    
// set gameArea
    let gameArea: CGRect
    
    override init(size: CGSize) {
        
        let maxAspectRatio: CGFloat = 16.0/9.0
        let playableWidth = size.height / maxAspectRatio
        let margin = (size.width - playableWidth) / 2
        gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)
        super.init(size: size)
    }

// required with the init above, given to you by Xcode
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    

// objects contacted each other
        func didBegin(_ contact: SKPhysicsContact){
            var body1 = SKPhysicsBody()
            var body2 = SKPhysicsBody()
            
// setting our bodies from our "contact" to be in numerical order based on our categories, so we always know what bodyA and bodyB are
            if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
                body1 = contact.bodyA
                body2 = contact.bodyB
            }
            else {
                body1 = contact.bodyB
                body2 = contact.bodyA
            }
            
// if enemy hits player
            if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Enemy {
                
                if body2.node != nil {
                    loseLife()
                    
                }
                body2.node?.removeFromParent()
            }
            
            
            
            
// if bullet hits enemy
            if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Enemy {
            
                if body2.node != nil {
                    spawnExplosion(spawnPosition: (body2.node?.position)!)
                    addScore()
                    self.run(randySound)
                }

                
                body1.node?.removeFromParent()
                body2.node?.removeFromParent()
            }
            
            
// if player hits life
            if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.Life {
                if body2.node != nil {
                    livesNumber += 1
                    livesLabel.text = "Lives: \(livesNumber)"
                    spawnLifeExplosion(spawnPosition: (body2.node?.position)!)
                }
                
                body2.node?.removeFromParent()
            }
            
// if player hits triple shot
            if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.TripleShot {
                if body2.node != nil {
                    tripleShotCount += 15
                    spawnTripleShotExplosion(spawnPosition: (body2.node?.position)!)
                    tripleShotLabel.isHidden = false

                }
                
                body2.node?.removeFromParent()
            }
    
    
// if bullet hits principle, create split
            if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Principle {
      
                if body2.node != nil {
                    spawnPrinciple1()
                    spawnPrinciple2()
                }
            
                body1.node?.removeFromParent()
                let delete = SKAction.run {
                    body2.node?.removeFromParent()
                }
                let wait = SKAction.wait(forDuration: 0.1)
                let sequence = SKAction.sequence([wait, delete])
                run(sequence)
            }
       
// if bullet hits boss / bullet hits cartman
            if body1.categoryBitMask == PhysicsCategories.Bullet && body2.categoryBitMask == PhysicsCategories.Boss {
                
                if body2.node != nil {
                    gameScore += 10
                    bossHealth -= 1
                    print(bossHealth)
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    healthBarInner.xScale -= 0.007
                }
                
                body1.node?.removeFromParent()
                
                if bossHealth == 0 {
                    self.removeAllActions()
                    cartman.removeAllActions()
                    cartman.removeAllChildren()
                    body2.node?.removeFromParent()
                    let spawnWin = SKAction.run {
                        self.spawnWin()
                    }
                    let rungameover = SKAction.run {
                        self.runYouWin()
                    }
                    let livesGone = SKAction.sequence([spawnWin, rungameover])
                    
                    self.run(livesGone)
                }
            }
            
// boss bullet hits player
            if body1.categoryBitMask == PhysicsCategories.Player && body2.categoryBitMask == PhysicsCategories.BossBullet {
                
                if body2.node != nil {
                    loseHalfLife()
                    gameScore -= 50
                    
                }
                body2.node?.removeFromParent()
            }
            
    }

    var flipper: Int = 0
    
    
// viewDidLoad
    override func didMove(to view: SKView) {
        

// spawn lives on timer
        Timer.scheduledTimer(timeInterval: TimeInterval(random(min: 25.0, max: 50.0)), target: self, selector: #selector(GameScene.spawnLife), userInfo: nil, repeats: true)
        
// spawn triple shot on timer
        Timer.scheduledTimer(timeInterval: TimeInterval(random(min: 35.0, max: 70.0)), target: self, selector: #selector(GameScene.spawnTripleShotPowerup), userInfo: nil, repeats: true)

//// set gameScore to 0
        gameScore = 0
        
// create pause button and play button
        pauseButton.setScale(0.45)
        pauseButton.position = CGPoint(x: self.size.width - 330, y: self.size.height * 0.07)
        pauseButton.zPosition = 101
//        pauseButton.isHidden = false
        pauseButton.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: 100), center: CGPoint(x: self.size.width - 340, y: self.size.height * 0.07))
        pauseButton.physicsBody?.affectedByGravity = false
        pauseButton.physicsBody?.categoryBitMask = PhysicsCategories.None
        pauseButton.physicsBody?.collisionBitMask = PhysicsCategories.None
        pauseButton.physicsBody?.contactTestBitMask = PhysicsCategories.None
        self.addChild(pauseButton)
        playButton.setScale(0.18)
        playButton.position = CGPoint(x: self.size.width - 330, y: self.size.height * 0.07)
        playButton.zPosition = 100
        playButton.physicsBody = SKPhysicsBody(circleOfRadius: 153)
        playButton.physicsBody?.affectedByGravity = false
        playButton.physicsBody?.categoryBitMask = PhysicsCategories.None
        playButton.physicsBody?.collisionBitMask = PhysicsCategories.None
        playButton.physicsBody?.contactTestBitMask = PhysicsCategories.None
//        playButton.isHidden = true
        self.addChild(playButton)
        
// create lives label
        livesLabel.text = "Lives: \(livesNumber)"
        livesLabel.fontSize = 100
        livesLabel.fontColor = SKColor.white
        livesLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.right
        livesLabel.position = CGPoint(x: self.size.width * 0.84, y: self.size.height * 0.93)
        livesLabel.zPosition = 10000
        self.addChild(livesLabel)

// create score label
        scoreLabel.text = "Score: \(gameScore)"
        scoreLabel.fontSize = 100
        scoreLabel.fontColor = SKColor.white
        scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentMode.left
        scoreLabel.position = CGPoint(x: self.size.width * 0.16, y: self.size.height * 0.93)
        scoreLabel.zPosition = 10000
        self.addChild(scoreLabel)
        
// create triple shot label
        tripleShotLabel.isHidden = true
        tripleShotLabel.fontSize = 150
        tripleShotLabel.fontColor = UIColor(netHex: 0xa369b8)
        tripleShotLabel.position = CGPoint(x: (self.size.width * 0.5) + 20, y: self.size.height * 0.9)
        tripleShotLabel.zPosition = 120000
        self.addChild(tripleShotLabel)
//        tripleShotLabel2.isHidden = true
//        tripleShotLabel2.fontSize = 170
//        tripleShotLabel2.fontColor = SKColor.white
//        tripleShotLabel2.position = CGPoint(x: (self.size.width * 0.5) + 20, y: (self.size.height * 0.86) - 8)
//        tripleShotLabel2.zPosition = 119
//        self.addChild(tripleShotLabel2)
        
// temp boss health label
        healthBarInner.isHidden = true
        healthBarInner.zPosition = 1200
        healthBarInner.yScale -= 0.6
        healthBarInner.position = CGPoint(x: (self.size.width * 0.179), y: self.size.height * 0.86)
        healthBarInner.anchorPoint = CGPoint(x: 0.0, y: 0.5)
        healthBarInner.setScale(0.7)
        self.addChild(healthBarInner)
        healthBarOutline.isHidden = true
        healthBarOutline.setScale(0.7)
        healthBarOutline.position = CGPoint(x: (self.size.width * 0.5), y: self.size.height * 0.86)
        healthBarOutline.zPosition = 1201
        self.addChild(healthBarOutline)
        
// allow contact
        self.physicsWorld.contactDelegate = self
        
// start level on load
        startNewLevel()
        changeLevel()
    
// create background
        // for i in 0...1 {
            let background = SKSpriteNode(imageNamed: "background")
            background.name = "Background"
            background.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height/2))
            // background.anchorPoint = CGPoint(x: 0.5, y: 0.0)
            background.zPosition = 0
            self.addChild(background)
        // }
        // let moveBG = SKAction.move(to: CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height)), duration: 30)
        // background.run(moveBG)
        
     
        
// motion manager
        manager.startAccelerometerUpdates()
        manager.accelerometerUpdateInterval = 0.1
        manager.startAccelerometerUpdates(to: OperationQueue.main){
            (data, _) in
            self.physicsWorld.gravity = CGVector(dx: (((data?.acceleration.x)!) + Double(self.random(min: -1.5, max: 1.5))) * 10, dy: (((data?.acceleration.y)!)) * 30)
        }

// create player
        player.setScale(1.2)
        player.name = "playerOG"
        player.position = CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(-self.size.height * 0.2)-100)
        player.zPosition = 68
        player.physicsBody = SKPhysicsBody(circleOfRadius: 120)
        player.physicsBody?.affectedByGravity = false
        player.physicsBody?.categoryBitMask = PhysicsCategories.Player
        player.physicsBody?.collisionBitMask = PhysicsCategories.None
        player.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy | PhysicsCategories.Boss
        self.addChild(player)
        let moveIn = SKAction.move(to: CGPoint(x: CGFloat(self.size.width/2), y: CGFloat(self.size.height * 0.2)), duration: 0.6)
        player.run(moveIn)
        
    }

    
// bump player
    func bumpPlayer() {
        let scaleIn = SKAction.scale(to: 1.45, duration: 0.075)
        let scaleOut = SKAction.scale(to: 1.2, duration: 0.075)
        let scale = SKAction.sequence([scaleIn, scaleOut])
        player.run(scale)
    }
    
// bump boss / bump cartmam
    func bumpBoss() {
        let scaleIn = SKAction.scale(to: 1.15, duration: 0.075)
        let scaleOut = SKAction.scale(to: 1, duration: 0.075)
        let scale = SKAction.sequence([scaleIn, scaleOut])
        cartman.run(scale)
    }
    
    
// increment score
    func addScore() {
        gameScore += 10
        scoreLabel.text = "Score: \(gameScore)"
        
        if gameScore == 100 && flipper == 0 || gameScore == 105 && flipper == 0{
            startNewLevel()
            changeLevel()
            flipper = 1
        }
        if gameScore == 350 && flipper == 1 || gameScore == 355 && flipper == 1{
            startNewLevel()
            changeLevel()
            flipper = 2
        }
        if gameScore == 700 && flipper == 2 || gameScore == 705 && flipper == 2{
            startNewLevel()
            changeLevel()
            flipper = 3
        }
        if gameScore == 1100 && flipper == 3 || gameScore == 1105 && flipper == 3{
            startNewLevel()
            changeLevel()
            flipper = 4
        }
        if gameScore == 1605 && flipper == 4 || gameScore == 1600 && flipper == 4{
            startNewLevel()
            changeLevel()
        }
            
// easy mode
//        if gameScore == 10 || gameScore == 20 || gameScore == 30 || gameScore == 40 || gameScore == 50{
//            startNewLevel()
//            changeLevel()

        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    
// decrement lives
    func loseLife() {
        
        bumpPlayer()
        
        livesNumber -= 1
        livesLabel.text = "Lives: \(livesNumber)"
        let scaleIn = SKAction.scale(to: 1.7, duration: 0.1)
        let scaleOut = SKAction.scale(to: 1, duration: 0.3)
        let lifeMarkerSequence = SKAction.sequence([scaleIn, scaleOut])
        livesLabel.run(lifeMarkerSequence)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        let lifeSound = SKAction.playSoundFileNamed("ohjeez.wav", waitForCompletion: false)
        self.run(lifeSound, withKey: "lifeSound")
        
        if livesNumber == 0 {
            
            let bumpPlayer = SKAction.run {
                self.bumpPlayer()
            }
            let spawnblood = SKAction.run {
                self.spawnBlood()
            }
            let rungameover = SKAction.run {
                self.runGameOver()
            }
            let livesGone = SKAction.sequence([bumpPlayer, spawnblood, rungameover])
            
            self.run(livesGone)
        }
    }
    func loseHalfLife() {
        
        bumpPlayer()
        
        livesNumber -= Int(0.5)
        livesLabel.text = "Lives: \(livesNumber)"
        let scaleIn = SKAction.scale(to: 1.7, duration: 0.1)
        let scaleOut = SKAction.scale(to: 1, duration: 0.3)
        let lifeMarkerSequence = SKAction.sequence([scaleIn, scaleOut])
        livesLabel.run(lifeMarkerSequence)
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
        let lifeSound = SKAction.playSoundFileNamed("ohjeez.wav", waitForCompletion: false)
        self.run(lifeSound, withKey: "lifeSound")
        
        if livesNumber == 0 {
            
            let bumpPlayer = SKAction.run {
                self.bumpPlayer()
            }
            let spawnblood = SKAction.run {
                self.spawnBlood()
            }
            let rungameover = SKAction.run {
                self.runGameOver()
            }
            let livesGone = SKAction.sequence([bumpPlayer, spawnblood, rungameover])
            
            self.run(livesGone)
        }
    }
    
    func loseScore () {
        gameScore -= 5
        scoreLabel.text = "Score: \(gameScore)"
    }
 

// run game over method, stop all actions
    func runGameOver() {
        flipper = 0
        healthBarInner.isHidden = true
        healthBarOutline.isHidden = true
        scoreLabel.isHidden = false
        scoreLabel.isHidden = false
        run(youLose)
        MusicHelper.sharedHelper.stopBackgroundMusic()
        currentGameState = gameState.postGame
        
        player.removeAllActions()
        self.removeAction(forKey: "spawningEnemies")
        
        self.enumerateChildNodes(withName: "Bullet") {
            bullet, stop in
            
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy") {
            enemy, stop in
            enemy.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Life") {
            life, stop in
            life.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Stan") {
            stan, stop in
            stan.removeAllActions()
        }
        self.enumerateChildNodes(withName: "TripleShot") {
            tripleshot, stop in
            tripleshot.removeAllActions()
        }
        self.enumerateChildNodes(withName: "BossBullet") {
            bossBullet, stop in
            bossBullet.removeAllActions()
            bossBullet.removeFromParent()
        }
        self.enumerateChildNodes(withName: "Cartman") {
            boss, stop in
            boss.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Principle") {
            principle, stop in
            principle.removeAllActions()
        }

        changeScene()
    }
    func runYouWin () {
        flipper = 0
        healthBarInner.isHidden = true
        healthBarOutline.isHidden = true
        scoreLabel.isHidden = false
        scoreLabel.isHidden = false
        MusicHelper.sharedHelper.stopBackgroundMusic()
        currentGameState = gameState.postGame
        
        player.removeAllActions()
        self.removeAction(forKey: "spawningEnemies")
        
        self.enumerateChildNodes(withName: "Bullet") {
            bullet, stop in
            
            bullet.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Enemy") {
            enemy, stop in
            enemy.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Life") {
            life, stop in
            life.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Stan") {
            stan, stop in
            stan.removeAllActions()
        }
        self.enumerateChildNodes(withName: "TripleShot") {
            tripleshot, stop in
            tripleshot.removeAllActions()
        }
        self.enumerateChildNodes(withName: "BossBullet") {
            bossBullet, stop in
            bossBullet.removeAllActions()
            bossBullet.removeFromParent()
        }
        self.enumerateChildNodes(withName: "Cartman") {
            boss, stop in
            boss.removeAllActions()
        }
        self.enumerateChildNodes(withName: "Principle") {
            principle, stop in
            principle.removeAllActions()
        }
        
        changeWinScene()

        
    }
    
    
// change scene
    func changeScene() {
        
        let waitToChangeScene = SKAction.wait(forDuration: 3)
        let moveScene = SKAction.run {
            let sceneToMoveTo = GameOverScene(size: self.size)
            sceneToMoveTo.scaleMode = self.scaleMode
            self.view!.presentScene(sceneToMoveTo)
        }
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, moveScene])
        self.run(changeSceneSequence)
    }
    
    func changeWinScene() {
        let waitToChangeScene = SKAction.wait(forDuration: 3)
        let moveScene = SKAction.run {
            let sceneToMoveTo = YouWinScene(size: self.size)
            sceneToMoveTo.scaleMode = self.scaleMode
            self.view!.presentScene(sceneToMoveTo)
        }
        let changeSceneSequence = SKAction.sequence([waitToChangeScene, moveScene])
        self.run(changeSceneSequence)

    }
    
// change level
    func changeLevel() {
        
        let vibrate = SKAction.run {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
        let delete = SKAction.removeFromParent()
        
        
        let FadeIn = SKAction.fadeAlpha(to: 0.75, duration: 0.6)
        let Wait = SKAction.wait(forDuration: 0.6)
        let waitBoss = SKAction.wait(forDuration: 2)
        let FadeOut = SKAction.fadeAlpha(to: 0, duration: 0.6)
        
        let Sequence = SKAction.sequence([FadeIn, Wait, Wait, FadeOut, delete])
        let bossSequence = SKAction.sequence([FadeIn, waitBoss, Wait, FadeOut, delete])
        
        let getReady = SKLabelNode(fontNamed: "theBoldFont")
        getReady.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.65)
        getReady.fontSize = 190
        getReady.text = "Get Ready!"
        getReady.alpha = 0
        getReady.fontColor = SKColor.white
        getReady.zPosition = 1
        self.addChild(getReady)
        
        
        let levelUpLabel = SKLabelNode(fontNamed: "theBoldFont")
        levelUpLabel.text = "Level \(levelNumber)"
        levelUpLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.65)
        levelUpLabel.fontSize = 250
        levelUpLabel.alpha = 0
//        levelUpLabel.isHidden = true
        levelUpLabel.fontColor = SKColor.white
        levelUpLabel.zPosition = 1
        self.addChild(levelUpLabel)
        
        
        let randy = SKSpriteNode(imageNamed: "randy")
        randy.setScale(1.6)
        randy.alpha = 0
        randy.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.4)
        randy.zPosition = 500
        
        let cartman = SKSpriteNode(imageNamed: "cartman")
        cartman.setScale(0.7)
        cartman.alpha = 0
        cartman.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.4)
        cartman.zPosition = 500
        
        let kyle = SKSpriteNode(imageNamed: "kyle")
        kyle.setScale(0.85)
        kyle.alpha = 0
        kyle.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.4)
        kyle.zPosition = 500
        
        let butters = SKSpriteNode(imageNamed: "buttersExplosion")
        butters.setScale(1.4)
        butters.alpha = 0
        butters.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.4)
        butters.zPosition = 500
        
        let principle = SKSpriteNode(imageNamed: "principle")
        principle.setScale(0.9)
        principle.alpha = 0
        principle.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.4)
        principle.zPosition = 500
        
        let stan = SKSpriteNode(imageNamed: "stansmall")
        stan.setScale(1.7)
        stan.alpha = 0
        stan.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.41)
        stan.zPosition = 500
        
        
        if levelNumber == 1 {
            self.addChild(butters)
            butters.run(Sequence)
            levelUpLabel.run(Sequence)
            self.run(vibrate)
        }
        if levelNumber == 2 {
            self.addChild(randy)
            randy.run(Sequence)
            levelUpLabel.run(Sequence)
            self.run(vibrate)
            self.run(vibrate)
        }
        if levelNumber == 3 {
            self.addChild(kyle)
            kyle.run(Sequence)
            levelUpLabel.run(Sequence)
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
        }
        if levelNumber == 4 {
            self.addChild(stan)
            stan.run(Sequence)
            levelUpLabel.run(Sequence)
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
        }
        if levelNumber == 5 {
            self.addChild(principle)
            principle.run(Sequence)
            levelUpLabel.run(Sequence)
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
            
        }
        if levelNumber == 6 {
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
            self.run(vibrate)
            getReady.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.6)
            levelUpLabel.text = "Boss Level"
            levelUpLabel.fontSize = 200
            levelUpLabel.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.7)
            self.addChild(cartman)
            levelUpLabel.run(bossSequence)
            cartman.run(bossSequence)
            getReady.run(bossSequence)
        }
        self.enumerateChildNodes(withName: "Enemy") {
            enemy, stop in
            
            enemy.removeFromParent()
        }
        
        childNode(withName: "Butters")?.removeFromParent()
        
        childNode(withName: "Kyle")?.removeFromParent()
        
        childNode(withName: "Stan")?.removeFromParent()
        
        childNode(withName: "Randy")?.removeFromParent()
        
        childNode(withName: "Principle")?.removeFromParent()
        
    }
    
    
    
// fire bullet
    func fireBullet() {
        let bullet = SKSpriteNode(imageNamed: "bullet")
        bullet.name = "Bullet"
        bullet.setScale(0.3)
        bullet.position = player.position
        bullet.zPosition = 67
        bullet.physicsBody = SKPhysicsBody(circleOfRadius: 57)
        bullet.physicsBody?.affectedByGravity = false
        bullet.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bullet.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy
        self.addChild(bullet)
        let moveBullet = SKAction.moveTo(y: self.size.height + bullet.size.height, duration: 1.3)
        let deleteBullet = SKAction.removeFromParent()
        let bulletSequence = SKAction.sequence([SKAction(playSound(soundVariable: bulletSound)), moveBullet, deleteBullet])
        bullet.run(bulletSequence)
        if tripleShotCount == 1 {
            tripleShotLabel.isHidden = true
//            tripleShotLabel2.isHidden = true
        }
    }
    
// spawn explosion, ran on death of enemy
    func spawnExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosionBlood")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.physicsBody = SKPhysicsBody()
        explosion.physicsBody?.affectedByGravity = false
        explosion.physicsBody?.categoryBitMask = PhysicsCategories.None
        explosion.physicsBody?.collisionBitMask = PhysicsCategories.None
        explosion.setScale(0)
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 0.7, duration: 0.05)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }

// spawn boss explosion
    func spawnBigExplosion(spawnPosition: CGPoint){
        let explosion = SKSpriteNode(imageNamed: "explosionBlood")
        explosion.position = spawnPosition
        explosion.zPosition = 3
        explosion.physicsBody = SKPhysicsBody()
        explosion.physicsBody?.affectedByGravity = false
        explosion.physicsBody?.categoryBitMask = PhysicsCategories.None
        explosion.physicsBody?.collisionBitMask = PhysicsCategories.None
        explosion.setScale(0)
        self.addChild(explosion)
        let scaleIn = SKAction.scale(to: 1.6, duration: 0.09)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let delete = SKAction.removeFromParent()
        let explosionSequence = SKAction.sequence([scaleIn, fadeOut, delete])
        explosion.run(explosionSequence)
    }
    
// spawn explosion life
    func spawnLifeExplosion(spawnPosition: CGPoint){
        let lifeExplosion = SKSpriteNode(imageNamed: "extralife")
        lifeExplosion.position = spawnPosition
        lifeExplosion.name = "Life"
        lifeExplosion.zPosition = 3
        lifeExplosion.physicsBody = SKPhysicsBody()
        lifeExplosion.physicsBody?.affectedByGravity = false
        lifeExplosion.physicsBody?.categoryBitMask = PhysicsCategories.None
        lifeExplosion.physicsBody?.collisionBitMask = PhysicsCategories.None
        lifeExplosion.setScale(0)
        lifeExplosion.zPosition = 3
//        lifeExplosion.zRotation = life.zRotation
        self.addChild(lifeExplosion)
        let scaleIn = SKAction.scale(to: 7, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let delete = SKAction.removeFromParent()
        let lifeExplosionSequence = SKAction.sequence([fadeOut, delete])
        lifeExplosion.run(scaleIn)
        lifeExplosion.run(lifeExplosionSequence)
    }
    
// spawn explosion triple shot
    func spawnTripleShotExplosion(spawnPosition: CGPoint) {
        let tripleShotExplosion = SKSpriteNode(imageNamed: "tripleshot")
        tripleShotExplosion.position = spawnPosition
        tripleShotExplosion.name = "TripleShot"
        tripleShotExplosion.zPosition = 3
//        tripleShotExplosion.zRotation = tripleShotPowerUp.zRotation
        tripleShotExplosion.physicsBody = SKPhysicsBody()
        tripleShotExplosion.physicsBody?.affectedByGravity = false
        tripleShotExplosion.physicsBody?.categoryBitMask = PhysicsCategories.None
        tripleShotExplosion.physicsBody?.collisionBitMask = PhysicsCategories.None
        tripleShotExplosion.setScale(0)
        self.addChild(tripleShotExplosion)
        let scaleIn = SKAction.scale(to: 7, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let delete = SKAction.removeFromParent()
        let tripleShotExplosionSequence = SKAction.sequence([fadeOut, delete])
        tripleShotExplosion.run(scaleIn)
        tripleShotExplosion.run(tripleShotExplosionSequence)
    }

// create the blood node and set its position above screen, ran on death
    func spawnBlood(){
        let blood = SKSpriteNode(imageNamed: "blood")
        blood.setScale(CGFloat(1))
        blood.position = (CGPoint(x: (self.size.width) / 2, y: (self.size.height) * 1.65))
        blood.zPosition = 1010
        self.addChild(blood)
        let moveBlood = SKAction.move(to: CGPoint(x: (self.size.width) / 2, y: (self.size.height / 2) - 50), duration: 3)
        let waitAfter = SKAction.wait(forDuration: 4)
        let spawnBloodSequence = SKAction.sequence([moveBlood, waitAfter])
        blood.run(spawnBloodSequence)
    }
    
    func spawnWin(){
        let winningBG = SKSpriteNode(imageNamed: "winningbg")
        winningBG.setScale(CGFloat(1))
        winningBG.position = (CGPoint(x: (self.size.width) / 2, y: (self.size.height) * 1.55))
        winningBG.zPosition = 101000
        self.addChild(winningBG)
        let moveWinningBG = SKAction.move(to: CGPoint(x: (self.size.width) / 2, y: (self.size.height / 2)), duration: 3)
        let waitAfter = SKAction.wait(forDuration: 4)
        let spawnWinningBGSequence = SKAction.sequence([moveWinningBG, waitAfter])
        winningBG.run(spawnWinningBGSequence)
        
    }
 
// spawn triple shot bullets
    func spawnTripleShotBullets () {
        tripleShotCount -= 1
 
// right bullet
        let bullet1 = SKSpriteNode(imageNamed: "bullet")
        bullet1.name = "Bullet"
        bullet1.position = player.position
        bullet1.zPosition = 66
        bullet1.setScale(0.3)
        bullet1.physicsBody = SKPhysicsBody(circleOfRadius: 57)
        bullet1.physicsBody?.affectedByGravity = false
        bullet1.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bullet1.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet1.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy | PhysicsCategories.Principle | PhysicsCategories.Boss
        self.addChild(bullet1)
        let moveBullet1 = SKAction.move(to: CGPoint(x: player.position.x * 1.45, y: self.size.height * 1.2), duration: 1.5)
        let deleteBullet1 = SKAction.removeFromParent()
        let bullet1Sequence = SKAction.sequence([moveBullet1, deleteBullet1])
        bullet1.run(bullet1Sequence)

// left bullet
        let bullet2 = SKSpriteNode(imageNamed: "bullet")
        bullet2.name = "Bullet"
        bullet2.position = player.position
        bullet2.zPosition = 68
        bullet2.setScale(0.3)
        bullet2.physicsBody = SKPhysicsBody(circleOfRadius: 57)
        bullet2.physicsBody?.affectedByGravity = false
        bullet2.physicsBody?.categoryBitMask = PhysicsCategories.Bullet
        bullet2.physicsBody?.collisionBitMask = PhysicsCategories.None
        bullet2.physicsBody?.contactTestBitMask = PhysicsCategories.Enemy | PhysicsCategories.Principle | PhysicsCategories.Boss
        self.addChild(bullet2)
        let moveBullet2 = SKAction.move(to: CGPoint(x: player.position.x * 0.55, y: self.size.height * 1.2), duration: 1.5)
        let deleteBullet2 = SKAction.removeFromParent()
        let bullet2Sequence = SKAction.sequence([moveBullet2, deleteBullet2])
        bullet2.run(bullet2Sequence)
    }
    
// spawn life
    func spawnLife () {
        let life = SKSpriteNode(imageNamed: "extralife")
        life.name = "Life"
        life.setScale(0.7)
        life.position = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: random(min: gameArea.size.height * 0.3, max: gameArea.maxY))
        life.zPosition = 3
        life.physicsBody = SKPhysicsBody(rectangleOf: life.size)
        life.physicsBody?.affectedByGravity = false
        life.physicsBody?.categoryBitMask = PhysicsCategories.Life
        life.physicsBody?.collisionBitMask = PhysicsCategories.None
        life.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        self.addChild(life)
//        life.zRotation = random(min: gameArea.minX, max: gameArea.maxX)
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        let scaleOut = SKAction.scale(to: 0, duration: 4)
        let deleteLife = SKAction.removeFromParent()
        let lifeSequence = SKAction.sequence([fadeIn, scaleOut, deleteLife])
        life.run(lifeSequence)
        
    }
    
// spawn powerup triple shot
    func spawnTripleShotPowerup() {
        let tripleShotPowerUp = SKSpriteNode(imageNamed: "tripleshot")
        tripleShotPowerUp.name = "TripleShot"
        tripleShotPowerUp.setScale(0.7)
        tripleShotPowerUp.position = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: random(min: gameArea.size.height * 0.3, max: gameArea.maxY))
        tripleShotPowerUp.zPosition = 3
        tripleShotPowerUp.physicsBody = SKPhysicsBody(rectangleOf: tripleShotPowerUp.size)
        tripleShotPowerUp.physicsBody?.affectedByGravity = false
        tripleShotPowerUp.physicsBody?.categoryBitMask = PhysicsCategories.TripleShot
        tripleShotPowerUp.physicsBody?.collisionBitMask = PhysicsCategories.None
        tripleShotPowerUp.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        self.addChild(tripleShotPowerUp)
//        tripleShotPowerUp.zRotation = random(min: gameArea.minX, max: gameArea.maxX)
        let fadeIn = SKAction.fadeIn(withDuration: 0.25)
        let scaleOut = SKAction.scale(to: 0, duration: 4)
        let delete = SKAction.removeFromParent()
        let tripleShotPowerUpSequence = SKAction.sequence([fadeIn, scaleOut, delete])
        tripleShotPowerUp.run(tripleShotPowerUpSequence)
    }

// new level
    func startNewLevel() {
    
        levelNumber += 1

//  if the spawn enemies function is already running (which runs forever) remove it, and start it again but on the higher difficulty due to our switch case.
        if self.action(forKey: "spawningButters") != nil {
            self.removeAction(forKey: "spawningButters")
        }
        if self.action(forKey: "spawningRandy") != nil {
            self.removeAction(forKey: "spawningRandy")
        }
        if self.action(forKey: "spawningKyle") != nil {
            self.removeAction(forKey: "spawningKyle")
        }
        
        if self.action(forKey: "spawningStan") != nil {
            self.removeAction(forKey: "spawningStan")
        }
        if self.action(forKey: "spawningPrinciple") != nil {
            self.removeAction(forKey: "spawningPrinciple")
        }
        
        
        switch levelNumber {
        case 1: print("Level 1!")
        case 2: print("Level 2!")
        case 3: print("Level 3!")
        case 4: print("Level 4!")
        case 5: print("Level 5!")
        case 6: print("Boss Level!")
        default:
        print("Cannot find level info")
        }

// interval between enemy spawns
        let wait = SKAction.wait(forDuration: 3)
        
        let spawnButters = SKAction.run { self.spawnButters() }
        let waitForSpawnButters = SKAction.wait(forDuration: 1.75)
        let spawnButtersSequence = SKAction.sequence([spawnButters, waitForSpawnButters])
        let spawnButtersForever = SKAction.repeatForever(spawnButtersSequence)
        let buttersSequence = SKAction.sequence([wait, spawnButtersForever])
        
        let spawnRandy = SKAction.run { self.spawnRandy() }
        let waitForSpawnRandy = SKAction.wait(forDuration: 2.5)
        let spawnRandySequence = SKAction.sequence([waitForSpawnRandy, spawnRandy])
        let spawnRandyForever = SKAction.repeatForever(spawnRandySequence)
        let randySequence = SKAction.sequence([wait, spawnRandyForever])

        
        let spawnKyle = SKAction.run { self.spawnKyle() }
        let waitForSpawnKyle = SKAction.wait(forDuration: 1.1)
        let spawnKyleSequence = SKAction.sequence([spawnKyle, waitForSpawnKyle])
        let spawnKyleForever = SKAction.repeatForever(spawnKyleSequence)
        let kyleSequence = SKAction.sequence([wait, spawnKyleForever])
        
        let spawnStan = SKAction.run { self.spawnStan() }
        let waitForSpawnStan = SKAction.wait(forDuration: 3)
        let spawnStanSequence = SKAction.sequence([waitForSpawnStan, spawnStan])
        let spawnStanForever = SKAction.repeatForever(spawnStanSequence)
        let stanSequence = SKAction.sequence([wait, spawnStanForever])
        
        let spawnPrinciple = SKAction.run { self.spawnPrinciple() }
        let waitForSpawnPrinciple = SKAction.wait(forDuration: 4)
        let spawnPrincipleSequence = SKAction.sequence([spawnPrinciple, waitForSpawnPrinciple])
        let spawnPrincipleForever = SKAction.repeatForever(spawnPrincipleSequence)
        let principleSequence = SKAction.sequence([wait, spawnPrincipleForever])
        
        let spawnCartman = SKAction.run { self.spawnCartman() }
        let cartmanSequence = SKAction.sequence([wait, spawnCartman])
        let fireBossBullet = SKAction.run { self.fireBossBullet() }
        let waitForBossBullet = SKAction.wait(forDuration: 1.3)
        let waitForBossBullet2 = SKAction.wait(forDuration: 0.9)
        let waitForBossBullet3 = SKAction.wait(forDuration: 1.5)
        let waitForBossBullet4 = SKAction.wait(forDuration: 0.9)
        let waitForBossBullet5 = SKAction.wait(forDuration: 1.3)
        let bossBulletSequence = SKAction.sequence([waitForBossBullet, fireBossBullet, waitForBossBullet2, fireBossBullet, waitForBossBullet3, fireBossBullet, waitForBossBullet4, fireBossBullet, waitForBossBullet5, fireBossBullet])
        let fireBossBulletForever = SKAction.repeatForever(bossBulletSequence)
        
//        let wait = SKAction.wait(forDuration: 3)
//        
//        let spawnButters = SKAction.run { self.spawnButters() }
//        let waitForSpawnButters = SKAction.wait(forDuration: 2)
//        let spawnButtersSequence = SKAction.sequence([spawnButters, waitForSpawnButters])
//        let spawnButtersForever = SKAction.repeatForever(spawnButtersSequence)
//        let buttersSequence = SKAction.sequence([wait, spawnButtersForever])
//        
//        let spawnRandy = SKAction.run { self.spawnRandy() }
//        let waitForSpawnRandy = SKAction.wait(forDuration: 3)
//        let spawnRandySequence = SKAction.sequence([spawnRandy, waitForSpawnRandy])
//        let spawnRandyForever = SKAction.repeatForever(spawnRandySequence)
//        let randySequence = SKAction.sequence([wait, spawnRandyForever])
//        
//        
//        let spawnKyle = SKAction.run { self.spawnKyle() }
//        let waitForSpawnKyle = SKAction.wait(forDuration: 1.6)
//        let spawnKyleSequence = SKAction.sequence([spawnKyle, waitForSpawnKyle])
//        let spawnKyleForever = SKAction.repeatForever(spawnKyleSequence)
//        let kyleSequence = SKAction.sequence([wait, spawnKyleForever])
//        
//        let spawnStan = SKAction.run { self.spawnStan() }
//        let waitForSpawnStan = SKAction.wait(forDuration: 4)
//        let spawnStanSequence = SKAction.sequence([spawnStan, waitForSpawnStan])
//        let spawnStanForever = SKAction.repeatForever(spawnStanSequence)
//        let stanSequence = SKAction.sequence([wait, spawnStanForever])
//        
//        let spawnPrinciple = SKAction.run { self.spawnPrinciple() }
//        let waitForSpawnPrinciple = SKAction.wait(forDuration: 5)
//        let spawnPrincipleSequence = SKAction.sequence([spawnPrinciple, waitForSpawnPrinciple])
//        let spawnPrincipleForever = SKAction.repeatForever(spawnPrincipleSequence)
//        let principleSequence = SKAction.sequence([wait, spawnPrincipleForever])
//        
//        let spawnCartman = SKAction.run { self.spawnCartman() }
//        let cartmanSequence = SKAction.sequence([wait, spawnCartman])
//        let fireBossBullet = SKAction.run { self.fireBossBullet() }
//        let waitForBossBullet = SKAction.wait(forDuration: TimeInterval(random(min: 2, max: 3)))
//        let bossBulletSequence = SKAction.sequence([SKAction.wait(forDuration: TimeInterval(random(min: 0.5, max: 2))), fireBossBullet])
//        let fireBossBulletForever = SKAction.repeatForever(bossBulletSequence)

        
        
// check level
        if levelNumber >= 1 {
            self.run(buttersSequence, withKey: "spawningButters")
        }
        if levelNumber >= 2 {
            self.run(buttersSequence, withKey: "spawningButters")
            self.run(randySequence, withKey: "spawningRandy")
        }
        if levelNumber >= 3 {
            self.run(buttersSequence, withKey: "spawningButters")
            self.run(randySequence, withKey: "spawningRandy")
            self.run(kyleSequence, withKey: "spawningKyle")
        }
        if levelNumber >= 4 {
            self.run(buttersSequence, withKey: "spawningButters")
            self.run(randySequence, withKey: "spawningRandy")
            self.run(kyleSequence, withKey: "spawningKyle")
            self.run(stanSequence, withKey: "spawningStan")
        }
        if levelNumber >= 5 {
            self.run(buttersSequence, withKey: "spawningButters")
            self.run(randySequence, withKey: "spawningRandy")
            self.run(kyleSequence, withKey: "spawningKyle")
            self.run(stanSequence, withKey: "spawningStan")
            self.run(principleSequence, withKey: "spawningPrinciple")
        }
        if levelNumber >= 6 {
            healthBarInner.isHidden = false
            healthBarOutline.isHidden = false
            self.removeAction(forKey: "spawningButters")
            self.removeAction(forKey: "spawningRandy")
            self.removeAction(forKey: "spawningKyle")
            self.removeAction(forKey: "spawningStan")
            self.removeAction(forKey: "spawningPrinciple")
            self.run(wait)
            self.run(cartmanSequence, withKey: "spawningCartman")
            self.run(fireBossBulletForever)
        }
    }
    
// spawn cartman boss
    func spawnCartman() {
        cartman.name = "Cartman"
        cartman.setScale(0.35)
        cartman.position = CGPoint(x: gameArea.width / 2, y: self.size.height * 1.1)
        cartman.zPosition = 300
        cartman.physicsBody = SKPhysicsBody(circleOfRadius: 160)
        cartman.physicsBody?.affectedByGravity = false
        cartman.physicsBody?.categoryBitMask = PhysicsCategories.Boss
        cartman.physicsBody?.collisionBitMask = PhysicsCategories.None
        cartman.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(cartman)
        let wait = SKAction.wait(forDuration: TimeInterval(random(min: 0.2, max: 0.7)))
        let wait2 = SKAction.wait(forDuration: TimeInterval(random(min: 0.4, max: 0.7)))
        let wait3 = SKAction.wait(forDuration: TimeInterval(random(min: 0.2, max: 0.7)))
        let moveIn = SKAction.move(to: CGPoint(x: gameArea.width / 2, y: self.size.height * 0.9), duration: 0.6)
        let moveRight = SKAction.move(to: CGPoint(x: gameArea.maxX - cartman.size.width * 0.4, y: self.size.height * (random(min: 0.6, max: 0.9))), duration: TimeInterval(random(min: 0.5, max: 1.5)))
        let moveLeft = SKAction.move(to: CGPoint(x: gameArea.minX + cartman.size.width * 0.4, y: self.size.height * (random(min: 0.6, max: 0.8))), duration: TimeInterval(random(min: 0.2, max: 1)))
        let moveRight2 = SKAction.move(to: CGPoint(x: gameArea.maxX - cartman.size.width * 0.4, y: self.size.height * (random(min: 0.5, max: 0.7))), duration: TimeInterval(random(min: 0.5, max: 2)))
        let moveLeft2 = SKAction.move(to: CGPoint(x: gameArea.minX + cartman.size.width * 0.4, y: self.size.height * (random(min: 0.7, max: 0.9))), duration: TimeInterval(random(min: 0.2, max: 1)))
        let moveRight3 = SKAction.move(to: CGPoint(x: gameArea.maxX - cartman.size.width * 0.4, y: self.size.height * (random(min: 0.7, max: 0.9))), duration: TimeInterval(random(min: 0.5, max: 2)))
        let moveLeft3 = SKAction.move(to: CGPoint(x: gameArea.minX + cartman.size.width * 0.4, y: self.size.height * (random(min: 0.6, max: 0.8))), duration: TimeInterval(random(min: 0.5, max: 2.5)))
        let moveRight4 = SKAction.move(to: CGPoint(x: gameArea.maxX - cartman.size.width * 0.4, y: self.size.height * (random(min: 0.7, max: 0.9))), duration: TimeInterval(random(min: 0.2, max: 1)))
        let moveLeft4 = SKAction.move(to: CGPoint(x: gameArea.minX + cartman.size.width * 0.4, y: self.size.height * (random(min: 0.6, max: 0.8))), duration: TimeInterval(random(min: 0.5, max: 2)))
        let repeatForeverSequence = SKAction.sequence([moveRight, wait, moveLeft, wait2, moveRight2, wait, moveLeft2, wait3, moveRight3, wait2, moveLeft3, wait, moveRight4, wait2, moveLeft4, wait3])
        let repeatForever = SKAction.repeatForever(repeatForeverSequence)
        let fullSequence = SKAction.sequence([moveIn, repeatForever])
        cartman.run(fullSequence)

    }
    
        
    func fireBossBullet () {
        let bossBullet = SKSpriteNode(imageNamed: "mrhankey")
        let endPoint = CGPoint(x: player.position.x, y: -self.size.height * 0.1)
        bossBullet.name = "BossBullet"
        bossBullet.setScale(0.24)
        bossBullet.position = CGPoint(x: cartman.position.x, y: cartman.position.y)
        bossBullet.zPosition = 299
        bossBullet.physicsBody = SKPhysicsBody(rectangleOf: bossBullet.size)
        bossBullet.physicsBody?.affectedByGravity = false
        bossBullet.physicsBody?.categoryBitMask = PhysicsCategories.BossBullet
        bossBullet.physicsBody?.collisionBitMask = PhysicsCategories.None
        bossBullet.physicsBody?.contactTestBitMask = PhysicsCategories.Player
        self.addChild(bossBullet)
        let moveBossBullet = SKAction.move(to: endPoint, duration: 1.2)
        let delete = SKAction.removeFromParent()
        let bossBulletSequence = SKAction.sequence([moveBossBullet, delete])
//        let forever = SKAction.repeatForever(bossBulletSequence)
        bossBullet.run(bossBulletSequence)
        let deltaX1 = player.position.x - endPoint.x
        let deltaY1 = player.position.y - endPoint.y
        let amountToRotate1 = atan2(deltaX1, deltaY1)
        bossBullet.zRotation = amountToRotate1 * 1.1
    
    }
    
    
// spawn principle
    func spawnPrinciple() {
        let startPoint = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: self.size.height * 1.1)
        let endPoint = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height * 0.2)
        let principle = SKSpriteNode(imageNamed: "principle2")
        principle.name = "Principle"
        principle.setScale(0.4)
        principle.position = startPoint
        principle.zPosition = 16
        principle.physicsBody = SKPhysicsBody(circleOfRadius: 120)
        principle.physicsBody?.affectedByGravity = false
        principle.physicsBody?.categoryBitMask = PhysicsCategories.Principle
        principle.physicsBody?.collisionBitMask = PhysicsCategories.None
        principle.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(principle)
        let loseScoreAction = SKAction.run {
            self.loseScore()
        }
        
        let scaleScore = SKAction.scale(to: 1.7, duration: 0.1)
        let scaleOutScore = SKAction.scale(to: 1, duration: 0.3)
        let scoreLabelSequence = SKAction.sequence([scaleScore, scaleOutScore])
        let bumpScore = SKAction.run {
            self.scoreLabel.run(scoreLabelSequence)
        }
     
        let movePrinciple = SKAction.move(to: CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height * 0.1), duration: 5)
        let delete = SKAction.removeFromParent()
        let principleSequence = SKAction.sequence([movePrinciple, delete, loseScoreAction, bumpScore])
        
        if currentGameState == gameState.inGame && levelNumber >= 5{
            principle.run(principleSequence)
        }
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let amountToRotate = atan2(deltaX, deltaY)
        principle.zRotation = amountToRotate
    }
    
    
// spawn principle1
    func spawnPrinciple1 () {
        let loseScoreAction = SKAction.run {
            self.loseScore()
        }
        
        let scaleScore = SKAction.scale(to: 1.7, duration: 0.1)
        let scaleOutScore = SKAction.scale(to: 1, duration: 0.3)
        let scoreLabelSequence = SKAction.sequence([scaleScore, scaleOutScore])
        let bumpScore = SKAction.run {
            self.scoreLabel.run(scoreLabelSequence)
        }
        
        let principle1 = SKSpriteNode(imageNamed: "principle")
        let principle = self.childNode(withName: "Principle") as! SKSpriteNode
        let endPoint = CGPoint(x: gameArea.maxX - 60, y: -self.size.height * 0.1)
        principle1.name = "Enemy"
        principle1.setScale(0.25)
        principle1.position = CGPoint(x: principle.position.x, y: principle.position.y)
        principle1.zPosition = 14
        principle1.physicsBody = SKPhysicsBody(circleOfRadius: 57)
        principle1.physicsBody?.affectedByGravity = false
        principle1.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        principle1.physicsBody?.collisionBitMask = PhysicsCategories.None
        principle1.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(principle1)
        let movePrinciple1 = SKAction.move(to: endPoint, duration: 3)
        let delete = SKAction.removeFromParent()
        let principle1Sequence = SKAction.sequence([movePrinciple1, delete, loseScoreAction, bumpScore])
        if currentGameState == gameState.inGame && levelNumber >= 5{
            principle1.run(principle1Sequence)
        }
        let deltaX1 = principle.position.x - endPoint.x
        let deltaY1 = principle.position.y - endPoint.y
        let amountToRotate1 = atan2(deltaX1, deltaY1)
        principle1.zRotation = amountToRotate1 * 1.1
    }
    

// spawn stan2
    func spawnPrinciple2() {
        let loseScoreAction = SKAction.run {
            self.loseScore()
        }
        
        let scaleScore = SKAction.scale(to: 1.7, duration: 0.1)
        let scaleOutScore = SKAction.scale(to: 1, duration: 0.3)
        let scoreLabelSequence = SKAction.sequence([scaleScore, scaleOutScore])
        let bumpScore = SKAction.run {
            self.scoreLabel.run(scoreLabelSequence)
        }
        
        let principle2 = SKSpriteNode(imageNamed: "principle")
        let principle = self.childNode(withName: "Principle") as! SKSpriteNode
        let endPoint = CGPoint(x: gameArea.minX + 60, y: -self.size.height * 0.1)
        principle2.name = "Enemy"
        principle2.setScale(0.25)
        principle2.position = CGPoint(x: principle.position.x, y: principle.position.y)
        principle2.zPosition = 14
        principle2.physicsBody = SKPhysicsBody(circleOfRadius: 57)
        principle2.physicsBody?.affectedByGravity = false
        principle2.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        principle2.physicsBody?.collisionBitMask = PhysicsCategories.None
        principle2.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(principle2)
        let movePrinciple1 = SKAction.move(to: endPoint, duration: 3)
        let delete = SKAction.removeFromParent()
        let principle1Sequence = SKAction.sequence([movePrinciple1, delete, loseScoreAction, bumpScore])
        if currentGameState == gameState.inGame && levelNumber >= 5{
            principle2.run(principle1Sequence)
        }
        let deltaX1 = principle.position.x - endPoint.x
        let deltaY1 = principle.position.y - endPoint.y
        let amountToRotate1 = atan2(deltaX1, deltaY1)
        principle2.zRotation = amountToRotate1 * 1.1
    }
    
// spawn stan
    func spawnStan() {
        let startPoint = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: self.size.height * 1.1)
        let endPoint = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height * 0.2)
        let stan = SKSpriteNode(imageNamed: "stan")
        stan.name = "Enemy"
        stan.setScale(0.55)
        stan.position = startPoint
        stan.zPosition = 16
        stan.physicsBody = SKPhysicsBody(circleOfRadius: 93)
        stan.physicsBody?.affectedByGravity = false
        stan.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        stan.physicsBody?.collisionBitMask = PhysicsCategories.None
        stan.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(stan)
        let loseScoreAction = SKAction.run {
            self.loseScore()
        }
        
        let scaleScore = SKAction.scale(to: 1.7, duration: 0.1)
        let scaleOutScore = SKAction.scale(to: 1, duration: 0.3)
        let scoreLabelSequence = SKAction.sequence([scaleScore, scaleOutScore])
        let bumpScore = SKAction.run {
            self.scoreLabel.run(scoreLabelSequence)
        }
        
        let moveStan1 = SKAction.move(to: CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: gameArea.size.height * 0.75), duration: 0.9)
        let moveStan2 = SKAction.move(to: CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: gameArea.size.height * 0.5), duration: 0.3)
        let moveStan3 = SKAction.move(to: CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height * 0.1), duration: 1.1)
        let deleteEnemy = SKAction.removeFromParent()
        let stanSequence = SKAction.sequence([moveStan1, moveStan2, moveStan3, deleteEnemy, loseScoreAction, bumpScore])
        
        if currentGameState == gameState.inGame && levelNumber >= 4{
            stan.run(stanSequence)
        }
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let amountToRotate = atan2(deltaX, deltaY)
        stan.zRotation = amountToRotate
    }
    
// spawn butters
    func spawnButters(){
    
        let startPoint = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: self.size.height * 1.1)
        let endPoint = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height * 0.2)
        let butters = SKSpriteNode(imageNamed: "butters")
        butters.name = "Enemy"
        butters.setScale(0.4)
        butters.position = startPoint
        butters.zPosition = 9
        butters.physicsBody = SKPhysicsBody(circleOfRadius: 80)
        butters.physicsBody?.affectedByGravity = false
        butters.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        butters.physicsBody?.collisionBitMask = PhysicsCategories.None
        butters.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(butters)
        let loseScoreAction = SKAction.run {
            self.loseScore()
        }
        let scaleScore = SKAction.scale(to: 1.7, duration: 0.1)
        let scaleOutScore = SKAction.scale(to: 1, duration: 0.3)
        let scoreLabelSequence = SKAction.sequence([scaleScore, scaleOutScore])
        let bumpScore = SKAction.run {
            self.scoreLabel.run(scoreLabelSequence)
        }
        
        let moveButters = SKAction.move(to: CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height * 0.1), duration: 2.8)
        let deleteEnemy = SKAction.removeFromParent()
        let buttersSequence = SKAction.sequence([moveButters, deleteEnemy, loseScoreAction, bumpScore])
        
        if currentGameState == gameState.inGame && levelNumber >= 1{
            butters.run(buttersSequence)

        }
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let amountToRotate = atan2(deltaX, deltaY)
        butters.zRotation = amountToRotate
        
    }
    
// spawn randy
    func spawnRandy() {
        
        let startPoint = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: self.size.height * 1.1)
        let endPoint = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height * 0.2)
        let randy = SKSpriteNode(imageNamed: "enemyShip")
        randy.name = "Enemy"
        randy.setScale(0.6)
        randy.position = CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: self.size.height * 1.1)
        randy.zPosition = 8
        randy.physicsBody = SKPhysicsBody(circleOfRadius: 90)
        randy.physicsBody?.affectedByGravity = false
        randy.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        randy.physicsBody?.collisionBitMask = PhysicsCategories.None
        randy.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(randy)
        let loseScoreAction = SKAction.run {
            self.loseScore()
        }
        
        let scaleScore = SKAction.scale(to: 1.7, duration: 0.1)
        let scaleOutScore = SKAction.scale(to: 1, duration: 0.3)
        let scoreLabelSequence = SKAction.sequence([scaleScore, scaleOutScore])
        let bumpScore = SKAction.run {
            self.scoreLabel.run(scoreLabelSequence)
        }
        
        let moveRandy = SKAction.move(to: CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height * 0.1), duration: 2)
        let deleteEnemy = SKAction.removeFromParent()
        let randySequence = SKAction.sequence([moveRandy, deleteEnemy, loseScoreAction, bumpScore])
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let amountToRotate = atan2(deltaX, deltaY)
        randy.zRotation = amountToRotate
        if currentGameState == gameState.inGame && levelNumber >= 2{
            randy.run(randySequence)
        }
    }
    
    
// spawn kyle
    func spawnKyle() {

        let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
        let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
        let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.1)
        let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2)
        let kyle = SKSpriteNode(imageNamed: "kyleb")
        kyle.name = "Enemy"
        kyle.setScale(0.25)
        kyle.position = CGPoint(x: randomXStart, y: self.size.height * 1.1)
        kyle.zPosition = 7
        kyle.physicsBody = SKPhysicsBody(circleOfRadius: 90)
        kyle.physicsBody?.affectedByGravity = false
        kyle.physicsBody?.categoryBitMask = PhysicsCategories.Enemy
        kyle.physicsBody?.collisionBitMask = PhysicsCategories.None
        kyle.physicsBody?.contactTestBitMask = PhysicsCategories.Player | PhysicsCategories.Bullet
        self.addChild(kyle)
        let loseScoreAction = SKAction.run {
            self.loseScore()
        }
        
        let scaleScore = SKAction.scale(to: 1.7, duration: 0.1)
        let scaleOutScore = SKAction.scale(to: 1, duration: 0.3)
        let scoreLabelSequence = SKAction.sequence([scaleScore, scaleOutScore])
        let bumpScore = SKAction.run {
            self.scoreLabel.run(scoreLabelSequence)
        }
        
        let moveKyle = SKAction.move(to: CGPoint(x: random(min: gameArea.minX, max: gameArea.maxX), y: -self.size.height * 0.1), duration: 4)
        let deleteEnemy = SKAction.removeFromParent()
        let kyleSequence = SKAction.sequence([moveKyle, deleteEnemy, loseScoreAction, bumpScore])
        let deltaX = endPoint.x - startPoint.x
        let deltaY = endPoint.y - startPoint.y
        let amountToRotate = atan2(deltaX, deltaY)
        kyle.zRotation = amountToRotate
        if currentGameState == gameState.inGame && levelNumber >= 3{
            kyle.run(kyleSequence)
        }
    }
    
    
    
//    var lastUpdateTime: TimeInterval = 0
//    var deltaFrameTime: TimeInterval = 0
//    var amountToMovePerSecond: CGFloat = 100.0

    
// on frame update
    override func update(_ currentTime: TimeInterval) {
        
        tripleShotLabel.text = "\(tripleShotCount)"
//        tripleShotLabel2.text = "\(tripleShotCount)"
        
//        if lastUpdateTime == 0 {
//            lastUpdateTime = currentTime
//        }
//        else{
//            deltaFrameTime = currentTime - lastUpdateTime
//            lastUpdateTime = currentTime
//        }
//        
//        let amountToMoveBG = amountToMovePerSecond * CGFloat(deltaFrameTime)
//        
//        self.enumerateChildNodes(withName: "Background") {
//            background, stop in
//            
//            if self.currentGameState == gameState.inGame{
//                background.position.y -= amountToMoveBG
//            }
//            
//            if background.position.y < -self.size.height {
//                background.position.y += self.size.height * 2
//            }
//            
//        }
        
        if player.position.x > gameArea.maxX - player.size.width/2{
            player.position.x = gameArea.maxX - (player.size.width/2) - 10
        }
        if player.position.x < gameArea.minX + player.size.width/2{
            player.position.x = gameArea.minX + (player.size.width/2) + 10
        }
        if player.position.y > gameArea.maxY - player.size.width/2{
            player.position.y = gameArea.maxY - (player.size.width/2) - 10
        }
        if player.position.y < -gameArea.size.height * 0.07{
            player.position.y = -gameArea.size.height * 0.07
        }
        
        
        
    }
    
 
// on touch, fire bullet method is ran
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if currentGameState == gameState.inGame {
            
            for touch: AnyObject in touches {
                
                let pointOfTouch = touch.location(in: self)
                
                if pauseButton.contains(pointOfTouch) {
                    isPaused = true
                    pauseButton.isHidden = true
                    pauseButton.isPaused = true
                    playButton.isHidden = false
                    playButton.isPaused = false
                    self.view?.isPaused = true

                }
                
                if playButton.contains(pointOfTouch) {
                    pauseButton.isHidden = false
                    pauseButton.isPaused = false
                    playButton.isHidden = true
                    playButton.isPaused = true
                    self.view?.isPaused = false

                }
            }
            
            if tripleShotCount >= 1 {
                fireBullet()
                spawnTripleShotBullets()
                print(tripleShotCount)
            }
            else {
                fireBullet()
            }
        }
    }
    
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        if currentGameState == gameState.inGame {
//            
//            for touch: AnyObject in touches {
//                
//                let pointOfTouch = touch.location(in: self)
//                
//                if pauseButton.contains(pointOfTouch) {
//                    isPaused = true
//                    pauseButton.isHidden = true
//                    pauseButton.isPaused = true
//                    playButton.isHidden = false
//                    playButton.isPaused = false
//                }
//                
//                if playButton.contains(pointOfTouch) {
//                    isPaused = false
//                    pauseButton.isHidden = false
//                    pauseButton.isPaused = false
//                    playButton.isHidden = true
//                    playButton.isPaused = true
//                }
//            }
//            
//        }
//    }
    
// touch moved, player moved
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
// find every touch point in a movement
        for touch: AnyObject in touches {
            let pointOfTouch = touch.location(in: self)
            let previousPointOfTouch = touch.previousLocation(in: self)
            
// find difference between new touch and previous touch (this happens very quickly, based on the slightest movement, even pixels. even the slightest movement will run this code hundreds if not thousands of times)
// add the difference on the x axis, so the player only slides left to right
            let amountDragged = CGPoint(x: pointOfTouch.x - previousPointOfTouch.x, y: pointOfTouch.y - previousPointOfTouch.y)
            
            if currentGameState == gameState.inGame{
                player.position.x += amountDragged.x
                player.position.y += amountDragged.y
            }
                
            if player.position.x > gameArea.maxX - player.size.width/2{
                player.position.x = gameArea.maxX - player.size.width/2
            }
            if player.position.x < gameArea.minX + player.size.width/2{
                player.position.x = gameArea.minX + player.size.width/2
            }
        }
    }
}
