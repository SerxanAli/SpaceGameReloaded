//
//  GameScene.swift
//  SpacegameReloaded
//
//  Created by serhan on 12/21/20.
//




import SpriteKit
import GameplayKit
import CoreMotion

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    var starfiled: SKEmitterNode! = nil  // nil - e diqqet et
    var player: SKSpriteNode! = nil
    
    var hundurluk = 0.0
    var en = 0.0
    
    var scoreLabel:SKLabelNode!
    var score:Int = 0 {
        didSet{
            scoreLabel.text = "Score: \(score)"
        }
    }
    
    var gameTimer: Timer!
    
    var possibleAliens = ["alien","alien2","alien3"]
    
    let alienCategory:UInt32 = 0x1 << 1
    let photonTorpedoCategory:UInt32 = 0x1 << 0
    
    let motionManger = CMMotionManager()
    var xAcceleration:CGFloat = 0
    

    override func didMove(to view: SKView) {
        
        hundurluk = view.frame.size.height
        en = view.frame.size.width
        
        self.size = CGSize(width: en , height: hundurluk)

       
        starfiled = SKEmitterNode(fileNamed: "Starfield")
        starfiled.position = CGPoint(x: en / 2, y:hundurluk)
        starfiled.advanceSimulationTime(10)
        self.addChild(starfiled)
        starfiled.zPosition = -1
        
        
        
        player = SKSpriteNode(imageNamed:"shuttle")
        player.position = CGPoint(x: self.frame.size.width / 2, y: player.size.height/2 + 20)
       
        self.addChild(player)
        
        print(self.frame.size.width,hundurluk)
        
        self.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
        self.physicsWorld.contactDelegate = self
        
        scoreLabel = SKLabelNode(text: "Score: 0")
        scoreLabel.position = CGPoint(x: Double(en) * 0.25, y: Double(hundurluk) * 0.90)
        // NOT -- sriftler makin oz yazi siriftlerinin icinden goturmek olar
        scoreLabel.fontName = "Arial Rounded MT Bold"
        scoreLabel.fontSize = 36
        scoreLabel.fontColor = UIColor.white
        score = 0
        
        // NOT -- burda scor 100 ve ya yuxari eded olduqda scorLabel yerini deyisib ekranda itir
        // bunu hell etmek ucun yazini ortadan yox sagdan boyumesi funksiyasini arasdir
        
        self.addChild(scoreLabel)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.75, target: self, selector: #selector(addAlien), userInfo: nil, repeats: true)
        
        
        motionManger.accelerometerUpdateInterval = 0.2
        motionManger.startAccelerometerUpdates(to: OperationQueue.current!) {(data: CMAccelerometerData?, error:Error? )in
            if let acceleromrterData = data {
                let acceleration = acceleromrterData.acceleration
                self.xAcceleration = CGFloat(acceleration.x) * 0.75 + self.xAcceleration * 0.25
            }
        }
        
        
        
    }
    
    
    @objc func addAlien(){
        
        possibleAliens = GKRandomSource.sharedRandom().arrayByShufflingObjects(in: possibleAliens) as! [String]
        
        let alien = SKSpriteNode(imageNamed: possibleAliens[0])
        
        let randomAlienPosition = GKRandomDistribution(lowestValue: 0, highestValue: Int(hundurluk))
        let position = CGFloat(randomAlienPosition.nextInt())
        alien.position = CGPoint(x: position, y: self.frame.size.height + alien.size.height)
        alien.physicsBody = SKPhysicsBody(rectangleOf: alien.size)
        alien.physicsBody?.isDynamic = true
        
        alien.physicsBody?.categoryBitMask = alienCategory
        alien.physicsBody?.contactTestBitMask = photonTorpedoCategory
        alien.physicsBody?.collisionBitMask = 0
        
        self.addChild(alien)
        
        
        let animationDuration:TimeInterval = 6
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: position, y: -alien.size.height), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        alien.run(SKAction.sequence(actionArray))
        
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        fireTorpedo()
    }
    
  
    
    
    // Ates etmek
    func fireTorpedo() {
        
        self.run(SKAction.playSoundFileNamed("torpedo.mp3", waitForCompletion: false))
        
        let torpedoNode = SKSpriteNode(imageNamed: "torpedo")
        torpedoNode.position =  player.position
        torpedoNode.position.y += 5
        torpedoNode.physicsBody = SKPhysicsBody(circleOfRadius: torpedoNode.size.width / 2)
        torpedoNode.physicsBody?.isDynamic = true
        
        torpedoNode.physicsBody?.categoryBitMask = photonTorpedoCategory
        torpedoNode.physicsBody?.contactTestBitMask = alienCategory
        torpedoNode.physicsBody?.collisionBitMask = 0
        torpedoNode.physicsBody?.usesPreciseCollisionDetection = true
        
        self.addChild(torpedoNode)
        
        let animationDuration:TimeInterval = 0.3
        var actionArray = [SKAction]()
        
        actionArray.append(SKAction.move(to: CGPoint(x: player.position.x, y: hundurluk + 10), duration: animationDuration))
        actionArray.append(SKAction.removeFromParent())
        
        torpedoNode.run(SKAction.sequence(actionArray))
        
        
        
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        var firstBody: SKPhysicsBody
        var secondBody: SKPhysicsBody
        
        if contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask {
            firstBody = contact.bodyA
            secondBody = contact.bodyB
        } else {
            firstBody = contact.bodyB
            secondBody = contact.bodyA
        }
        
        if (firstBody.categoryBitMask & photonTorpedoCategory) != 0 && (secondBody.categoryBitMask & alienCategory) != 0 {
            torpedoDidCollideWithAlien(torpedoNode: firstBody.node as! SKSpriteNode, alienNode: secondBody.node as! SKSpriteNode)
        }
        
        
        
        
    }
    
    
    func torpedoDidCollideWithAlien (torpedoNode:SKSpriteNode, alienNode:SKSpriteNode) {
        
        let explosion = SKEmitterNode(fileNamed: "Explosion")
        explosion?.position = alienNode.position
        self.addChild(explosion!)
        self.run(SKAction.playSoundFileNamed("explosion.mp3", waitForCompletion: false))
        
        alienNode.removeFromParent()
        torpedoNode.removeFromParent()
        
        
        self.run(SKAction.wait(forDuration: 2)){
            explosion?.removeFromParent()
            
        }
        
        score += 5
    }
    
    
    
    
   
    override func didSimulatePhysics() {
        player.position.x += xAcceleration * 50
        
        if player.position.x < -20 {
            player.position = CGPoint(x: self.size.width + 20, y: player.position.y)
        }else if player.position.x > self.size.width + 20{
            player.position = CGPoint(x: -20, y: player.position.y)
        }
        
    }
    
    
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
