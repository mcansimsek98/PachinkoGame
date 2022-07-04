//
//  GameScene.swift
//  Project11
//
//  Created by Mehmet Can Şimşek on 1.07.2022.
//

import SpriteKit

class GameScene: SKScene, SKPhysicsContactDelegate, UIAlertViewDelegate {
  
    var ballsLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var editLbl: SKLabelNode!
    var score = 0 {
        didSet {
            scoreLabel.text = "Score: \(score)"
        }
    }
    var editingMode: Bool = false {
        didSet {
            if editingMode {
                editLbl.text = "Done"
            }else {
                editLbl.text = "Edit"
            }
        }
    }
    var limit = 5 {
        didSet {
            ballsLabel.text = "Balls limit: \(limit)"
        }
    }
    
   
    
    var color = ["ballBlue", "ballCyan","ballGreen","ballGrey","ballPurple","ballRed","ballYellow"]
    
    override func didMove(to view: SKView) {
        let background = SKSpriteNode(imageNamed: "background.jpg")
        background.position = CGPoint(x: 512, y: 384)
        background.blendMode = .replace
        background.zPosition = -2
        addChild(background)
        
      //  physicsBody = SKPhysicsBody(edgeLoopFrom: CGRect(x: 0, y: 0, width: 1024, height: 768))
        physicsBody = SKPhysicsBody(edgeLoopFrom: frame)
        physicsWorld.contactDelegate = self
        
        makeSlot(at: CGPoint(x: 128, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 384, y: 0), isGood: false)
        makeSlot(at: CGPoint(x: 640, y: 0), isGood: true)
        makeSlot(at: CGPoint(x: 896, y: 0), isGood: false)
        
        makeBouner(at: CGPoint(x: 0, y: 0))
        makeBouner(at: CGPoint(x: 256, y: 0))
        makeBouner(at: CGPoint(x: 512, y: 0))
        makeBouner(at: CGPoint(x: 768, y: 0))
        makeBouner(at: CGPoint(x: 1024, y: 0))
        
        scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
        scoreLabel.text = "Score: 0"
        scoreLabel.horizontalAlignmentMode = .right
        scoreLabel.position = CGPoint(x: 980, y: 650)
        addChild(scoreLabel)
        
        editLbl = SKLabelNode(fontNamed: "Chalkduster")
        editLbl.text = "Edit"
        editLbl.position = CGPoint(x: 80, y: 650)
        addChild(editLbl)
        
        ballsLabel = SKLabelNode(fontNamed: "Chalkduster")
        ballsLabel.text = "Balls limit: 5 "
        ballsLabel.position = CGPoint(x: 860, y: 600)
        addChild(ballsLabel)
        
    }

    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
            guard let touch = touches.first else { return }
            let location = touch.location(in: self)
            let objects = nodes(at: location)
            if objects.contains(editLbl) {
                editingMode.toggle()
            }else {
                if editingMode {
                    let size = CGSize(width: Int.random(in: 16...128), height: 16)
                    let box = SKSpriteNode(color: UIColor(red: CGFloat.random(in: 0...1), green: CGFloat.random(in: 0...1), blue: CGFloat.random(in: 0...1), alpha: 1), size: size)
                    box.zRotation = CGFloat.random(in: 0...3)
                    box.position = location
                    box.name = "box"
                    box.physicsBody = SKPhysicsBody(rectangleOf: box.size)
                    box.physicsBody?.isDynamic = false
                    addChild(box)
                    
                }else {
                    if limit > 0 {
                        let ball = SKSpriteNode(imageNamed: color.randomElement() ?? "ballRed" )
                        ball.physicsBody = SKPhysicsBody(circleOfRadius: ball.size.width / 2.0 )
                        ball.physicsBody?.restitution = 0.4
                        ball.physicsBody?.contactTestBitMask = ball.physicsBody?.collisionBitMask ?? 0
                        ball.position = CGPoint(x: location.x, y: 650)
                        ball.name = "ball"
                        limit -= 1
                        addChild(ball)
                    }else {
                        gameOver()
                    }
                }
            }
    }
    
    
    func makeBouner(at position: CGPoint) {
        let bouncer = SKSpriteNode(imageNamed: "bouncer")
        bouncer.position = position
        bouncer.physicsBody = SKPhysicsBody(circleOfRadius: bouncer.size.width / 2.0 )
        bouncer.physicsBody?.isDynamic = false
        addChild(bouncer)
    }
    
    func makeSlot(at position: CGPoint, isGood: Bool) {
        var slotBase: SKSpriteNode
        var slotGlow: SKSpriteNode

        if isGood{
            slotBase = SKSpriteNode(imageNamed: "slotBaseGood")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowGood")
            slotBase.name = "good"
        }else {
            slotBase = SKSpriteNode(imageNamed: "slotBaseBad")
            slotGlow = SKSpriteNode(imageNamed: "slotGlowBad")
            slotBase.name = "bad"
        }
        slotBase.position = position
        slotGlow.position = position
        slotBase.physicsBody = SKPhysicsBody(rectangleOf: slotBase.size)
        slotBase.physicsBody?.isDynamic = false
        addChild(slotBase)
        addChild(slotGlow)
        
        let spin = SKAction.rotate(byAngle: .pi, duration: 10)
        let spinForever = SKAction.repeatForever(spin)
        slotGlow.run(spinForever)
    }
    
    func collision(between ball: SKNode, object: SKNode) {
        if object.name == "good" {
            destroy(ball: ball)
            score += 1
            limit += 1
        }else if object.name == "bad" {
            destroy(ball: ball)
            score -= 1
        }else if object.name == "box" {
            destory(box: object)
        }
    }
    
    func destory(box: SKNode) {
        box.removeFromParent()
    }
     
    func destroy(ball: SKNode) {
            if let fireParticles = SKEmitterNode(fileNamed: "FireParticles") {
                fireParticles.position = ball.position
                addChild(fireParticles)
            }
        ball.removeFromParent()
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        guard let nodeA = contact.bodyA.node else { return }
        guard let nodeB = contact.bodyB.node else { return }
        
        if nodeA.name == "ball" {
            collision(between: nodeA, object: nodeB)
        } else if nodeB.name == "ball" {
            collision(between: nodeB, object: nodeA)
        }
        
    }
    
  
    func gameOver() {
            let ac = UIAlertController(title: "Game Over", message: "Your score is \(score). ", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "Play Again", style: .default, handler: { _ in
                self.score = 0
                self.limit = 5
            
            }))
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            DispatchQueue.main.async {
                self.view?.window?.rootViewController?.present(ac, animated: true)
            
        }
    }
  
}
