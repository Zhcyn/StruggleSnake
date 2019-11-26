import SpriteKit
import GameplayKit
var currentDifficulty = Difficulty.Easy
var gameScene: SKScene?
class MainMenuScene: SKScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self) {
            let nodeArray = self.nodes(at: location)
            for node in nodeArray {
                if (node.name == "StartButton") {
                    let startGameTransition = SKTransition.fade(withDuration: 0.5)
                    gameScene = SKScene(fileNamed: "GameScene")!
                    gameScene!.scaleMode = .fill
                    self.view?.presentScene(gameScene!, transition: startGameTransition);
                }
                if (node.name == "DifficultyButton") {
                    self.setDifficulty()
                }
                if (node.name == "HowToPlayLabel") {
                    let howToPlayTransition = SKTransition.fade(withDuration: 0.5)
                    let howToPlayScene = SKScene(fileNamed: "HowToPlayScene")!
                    howToPlayScene.scaleMode = .fill
                    self.view?.presentScene(howToPlayScene, transition: howToPlayTransition);
                }
            }
        }
    }
    override func didMove(to view: SKView) {
        let highScoreLabel = self.childNode(withName: "HighScoreLabel") as! SKLabelNode
        let userDefaults = UserDefaults.standard
        let currentHighScore = userDefaults.integer(forKey: "HighScore")
        highScoreLabel.text = "High Score: \(currentHighScore)"
        self.setDifficulty()
    }
    func setDifficulty() {
        let difficultyLabel = self.childNode(withName: "DifficultyLabel") as! SKLabelNode
        switch(difficultyLabel.text!) {
        case "Difficulty: Easy":
            difficultyLabel.text = "Difficulty: Medium"
            currentDifficulty = Difficulty.Medium
        case "Difficulty: Medium":
            difficultyLabel.text = "Difficulty: Hard"
            currentDifficulty = Difficulty.Hard
        case "Difficulty: Hard":
            difficultyLabel.text = "Difficulty: Easy"
            currentDifficulty = Difficulty.Easy
        default:
            print("Undefined Difficulty - This should never happen")
        }
    }
}
