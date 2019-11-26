import SpriteKit
import GameplayKit
import AVFoundation
class GameScene: SKScene {
    var isGamePaused: Bool = false
    private var snakeLogic: SnakeLogic?
    private var snakeSegments: [SKShapeNode] = []
    private var timer : Timer!
    private var flareTimer : Timer!
    private var runCount : Int = 0
    private var scoreLabel: SKLabelNode!
    private var scoreLabelShadow: SKLabelNode!
    private var flare = SKSpriteNode(imageNamed: "1")
    private var score : Int = 0 {
        didSet {
            self.scoreLabel.text = "Score: \(score)"
            self.scoreLabelShadow.text = "Score: \(score)"
        }
    }
    var musicPlayer : AVAudioPlayer?
    private var foodSoundPlayer : AVAudioPlayer?
    private var deathSoundPlayer : AVAudioPlayer?
    private var flareSoundPlayer : AVAudioPlayer?
    private var snakeScale = 30
    private var snakeInitialLength = 10
    private var foodTypeArray : [String] = ["banana", "black-berry-light", "black-cherry", "coconut", "green-apple", "green-grape", "lemon", "lime", "orange", "peach", "pear", "plum", "raspberry", "red-apple", "red-cherry", "red-grape", "star-fruit", "strawberry", "watermelon"]
    private var food = SKSpriteNode(imageNamed: "red-apple")
    override func didMove(to view: SKView) {
        snakeLogic = SnakeLogic(worldSize: self.frame.size, snakeSize: CGSize(width: snakeScale, height: snakeScale), initialLength: snakeInitialLength)
        for index in 0..<snakeLogic!.points.count {
            snakeSegments.append(SKShapeNode(rectOf: snakeLogic!.snakeSize))
            self.addChild(snakeSegments[index])
        }
        snakeLogic!.generateFood()
        self.food.position = snakeLogic!.foodLocation
        self.food.size.width = snakeLogic!.snakeSize.width * 1.5
        self.food.size.height = snakeLogic!.snakeSize.height * 1.5
        self.food.zPosition = -1
        self.addChild(food)
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        self.view!.addGestureRecognizer(swipeUp)
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.view!.addGestureRecognizer(swipeDown)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.view!.addGestureRecognizer(swipeLeft)
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.view!.addGestureRecognizer(swipeRight)
        scoreLabel = self.childNode(withName: "CurrentScoreLabel") as! SKLabelNode
        scoreLabelShadow = self.childNode(withName: "CurrentScoreLabelShadow") as! SKLabelNode
        self.timer = Timer.scheduledTimer(timeInterval: currentDifficulty.rawValue, target: self, selector: #selector(self.timerMethod), userInfo: nil, repeats: true)
        flare.size.height = snakeLogic!.snakeSize.height * 2
        flare.size.width = snakeLogic!.snakeSize.width * 2
        flare.position = CGPoint(x: 0, y: 0)
        let flareAction = SKAction(named: "SpinFlare")
        flare.run(flareAction!)
        flare.isHidden = true
        self.addChild(flare)
        self.flareTimer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.flareTimerMethod), userInfo: nil, repeats: true)
        playMusic()
        didGameMinimize = false
    }
    @objc private func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.up:
                snakeLogic!.changeDirection(.Up)
            case UISwipeGestureRecognizerDirection.down:
                snakeLogic!.changeDirection(.Down)
            case UISwipeGestureRecognizerDirection.left:
                snakeLogic!.changeDirection(.Left)
            case UISwipeGestureRecognizerDirection.right:
                snakeLogic!.changeDirection(.Right)
            default:
                break
            }
        }
    }
    @objc private func timerMethod() {
        if(!isGamePaused) {
            snakeLogic!.move()
            if(snakeLogic!.didEatFood) {
                self.food.texture = SKTexture(imageNamed: foodTypeArray[Int(arc4random_uniform(UInt32(foodTypeArray.count)))])
                snakeLogic!.generateFood()
                food.position = snakeLogic!.foodLocation
                snakeSegments.append(SKShapeNode(rectOf: snakeLogic!.snakeSize))
                snakeLogic!.didEatFood = false
                score = snakeLogic!.updateScore(FoodTypes.Fruit)
                playFoodSound()
            }
            if(snakeLogic!.points[0] == flare.position && !flare.isHidden) {
                score = snakeLogic!.updateScore(FoodTypes.Flare)
                flare.isHidden = true
                playFlareSound()
            }
            var i: Int = 0
            for segment in snakeSegments {
                segment.position = snakeLogic!.points[i]
                segment.zPosition = 0
                i += 1
                segment.removeFromParent()
                self.addChild(segment)
            }
            if(snakeLogic!.didGameEnd()) {
                let userDefaults = UserDefaults.standard
                if(snakeLogic!.currentScore > userDefaults.integer(forKey: "HighScore")) {
                    userDefaults.set(snakeLogic!.currentScore, forKey: "HighScore")
                }
                let gameOverTransition = SKTransition.fade(withDuration: 2)
                let gameOverScene = SKScene(fileNamed: "GameOverScene")!
                gameOverScene.scaleMode = .fill
                self.view?.presentScene(gameOverScene, transition: gameOverTransition);
                musicPlayer!.stop()
                playDeathSound()
                timer.invalidate()
            }
        }
    }
    @objc private func flareTimerMethod() {
        if(!isGamePaused) {
            snakeLogic!.generateFlare()
            flare.position = snakeLogic!.flareLocation
            flare.run(SKAction(named: "Unhide")!)
            flare.run(SKAction(named: "HideFlare")!)
        }
    }
    override func update(_ currentTime: TimeInterval) {
        if(didGameMinimize) {
            isGamePaused = true
            musicPlayer!.pause()
            self.unhidePauseMenu()
            didGameMinimize = false
        }
    }
    func unhidePauseMenu() {
        let pauseMenu = self.childNode(withName: "GamePausedLabel") as! SKLabelNode
        let pauseMenuShadow = self.childNode(withName: "GamePausedLabelShadow") as! SKLabelNode
        let unhideAction = SKAction(named: "Unhide")
        pauseMenu.run(unhideAction!)
        pauseMenuShadow.run(unhideAction!)
    }
    func hidePauseMenu() {
        let pauseMenu = self.childNode(withName: "GamePausedLabel") as! SKLabelNode
        let pauseMenuShadow = self.childNode(withName: "GamePausedLabelShadow") as! SKLabelNode
        let hideAction = SKAction(named: "Hide")
        pauseMenu.run(hideAction!)
        pauseMenuShadow.run(hideAction!)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let nodeArray = self.nodes(at: location)
            for node in nodeArray {
                if (node.name == "PauseButton") {
                    if(isGamePaused) {
                        isGamePaused = false
                        musicPlayer!.play()
                        self.hidePauseMenu()
                    } else {
                        isGamePaused = true
                        musicPlayer!.pause()
                        self.unhidePauseMenu()
                    }
                } else if (node.name == "YesButton") {
                    isGamePaused = true
                    musicPlayer!.stop()
                    let mainMenuTransition = SKTransition.fade(withDuration: 2)
                    let mainMenuScene = SKScene(fileNamed: "MainMenuScene")!
                    mainMenuScene.scaleMode = .fill
                    self.view?.presentScene(mainMenuScene, transition: mainMenuTransition);
                } else if (node.name == "NoButton") {
                    isGamePaused = false
                    musicPlayer!.play()
                    self.hidePauseMenu()
                }
            }
        }
    }
    private func playMusic() {
        guard let sound = NSDataAsset(name: "me-and-my-guitar") else {
            print("asset not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            musicPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileType.mp3.rawValue)
            musicPlayer!.numberOfLoops = -1
            musicPlayer!.volume = 0.5
            musicPlayer!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    private func playFoodSound() {
        guard let sound = NSDataAsset(name: "food-sound") else {
            print("asset not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            foodSoundPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileType.mp3.rawValue)
            foodSoundPlayer!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    private func playFlareSound() {
        guard let sound = NSDataAsset(name: "flare-sound") else {
            print("asset not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            flareSoundPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileType.mp3.rawValue)
            flareSoundPlayer!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
    private func playDeathSound() {
        guard let sound = NSDataAsset(name: "death-sound") else {
            print("asset not found")
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            deathSoundPlayer = try AVAudioPlayer(data: sound.data, fileTypeHint: AVFileType.mp3.rawValue)
            deathSoundPlayer!.play()
        } catch let error as NSError {
            print("error: \(error.localizedDescription)")
        }
    }
}
