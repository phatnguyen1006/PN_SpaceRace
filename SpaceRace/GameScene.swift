//
//  GameScene.swift
//  SpaceRace
//
//  Created by Phat Nguyen on 05/12/2021.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate {
    var startField: SKEmitterNode!
    var player: SKSpriteNode!
    var scoreLabel: SKLabelNode!
    
    let possibleEnemies = ["ball", "hammer", "tv"]
    var isGameOver = false
    var gameTimer: Timer?
    
    var scores = 0 {
        didSet {
            scoreLabel.text = "Score: \(scores)"
        }
    }
    
    var startBtn : SKLabelNode!
    private let restartBtn : SKLabelNode = {
        let restartBtn = SKLabelNode(fontNamed: "Chalkduster")
        restartBtn.text = "Restart"
        restartBtn.name = "restart"
        restartBtn.horizontalAlignmentMode = .center
        restartBtn.position = CGPoint(x: 512, y: 200)
        restartBtn.zPosition = 1
        restartBtn.isHidden = true
        return restartBtn
    }()
    
    override func didMove(to view: SKView) {
        backgroundColor = .black
        
        backgound()
        playerSetUp()
        showScores()
        scores = 0
        gameTimerSetUp()
        
        // Gravity Configurate
        physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        physicsWorld.contactDelegate = self
    }
    
    override func update(_ currentTime: TimeInterval) {
        // remove every nodes invisible
        for node in children {
            if node.position.x < -300 {
                node.removeFromParent()
            }
        }
        
        if !isGameOver {
            scores += 1
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // if someone touch insside the restart btn
        if isGameOver {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let tappedNodes = nodes(at: location)
            
            if tappedNodes.contains(restartBtn) {
                // restart new game
                
                // remove all nodes
                for node in children {
                    node.removeFromParent()
                }
                
                // restart the state
                restartBtn.isHidden = true
                isGameOver = false
                
                startGame()
            }
            
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        var location = touch.location(in: self)
        
        if location.y < 100 {
            location.y = 100
        } else if location.y > 668 {
            location.y = 668
        }
        
        player.position = location
    }
    
    func startGame() {
        backgound()
        playerSetUp()
        showScores()
        scores = 0
        
        gameTimerSetUp()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let explosion = SKEmitterNode(fileNamed: "explosion")!
        explosion.position = player.position
        addChild(explosion)
        
        player.removeFromParent()
        isGameOver = true
        endGame()
    }
    
    func gameTimerSetUp() {
        gameTimer = Timer.scheduledTimer(timeInterval: 0.35, target: self, selector: #selector(createEnemies), userInfo: nil, repeats: true)
    }
    
    func backgound() {
        startField = SKEmitterNode(fileNamed: "starfield")
        startField.position = CGPoint(x: 1024, y: 384)
        startField.advanceSimulationTime(10)
        startField.zPosition = -1
        addChild(startField)
        addChild(restartBtn)
    }
    
    func playerSetUp() {
        // textture: The texture used to draw the sprite. (render faster than normal draw)
        // CollisionBitMask:
        player = SKSpriteNode(imageNamed: "player")
        player.position = CGPoint(x: 100, y: 384)
        player.physicsBody = SKPhysicsBody(texture: player.texture!, size: player.size)
        player.physicsBody?.contactTestBitMask = 1
        addChild(player)
    }
    
    func showScores() {
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.position = CGPoint(x: 16, y: 16)
        scoreLabel.horizontalAlignmentMode = .left
        addChild(scoreLabel)
    }
    
    func endGame() {
        // stop Timer
        // show restart button
        if isGameOver {
            gameTimer?.invalidate()
            
            restartBtn.isHidden = false
        }
    }
    
    @objc func createEnemies() {
        guard let enemy = possibleEnemies.randomElement() else { return }
        
        let sprite = SKSpriteNode(imageNamed: enemy)
        sprite.position = CGPoint(x: 1024, y: Int.random(in: 50...736))
        addChild(sprite)
        
        /**
         * CategoryBitMask : defined which category this physicBody belong to
         * Velocity : a vector simulate speed and velocity
         * AngularVelocity : spin speed of this physicBody
         * AngularDamping : /"Sự tắt dần của giao động" "Ma sát: Friction"/ Set value for Angular Friction
         * LinearDamping : /"Sự tắt dần của giao động" "Ma sát: Friction"/ Set value for Linear Friction
         */
        
        sprite.physicsBody = SKPhysicsBody(texture: sprite.texture!, size: sprite.size)
        sprite.physicsBody?.categoryBitMask = 1
        sprite.physicsBody?.velocity = CGVector(dx: -500, dy: 0)
        sprite.physicsBody?.angularVelocity = 5
        sprite.physicsBody?.angularDamping = 0
        sprite.physicsBody?.linearDamping = 0
    }
}
