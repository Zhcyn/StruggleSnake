import SpriteKit
import GameplayKit
class GameOverScene: SKScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameOverTransition = SKTransition.fade(withDuration: 0.5)
        let gameScene = SKScene(fileNamed: "GameScene")!
        gameScene.scaleMode = .fill
        self.view?.presentScene(gameScene, transition: gameOverTransition);
    }
    override func didMove(to view: SKView) {
        let highScoreLabel = self.childNode(withName: "HighScoreLabel") as! SKLabelNode
        let userDefaults = UserDefaults.standard
        let currentHighScore = userDefaults.integer(forKey: "HighScore")
        highScoreLabel.text = "High Score: \(currentHighScore)"
    }
}
