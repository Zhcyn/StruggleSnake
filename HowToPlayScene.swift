import SpriteKit
class HowToPlayScene : SKScene {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let mainMenuTransition = SKTransition.fade(withDuration: 0.5)
        let mainMenuScene = SKScene(fileNamed: "MainMenuScene")!
        mainMenuScene.scaleMode = .fill
        self.view?.presentScene(mainMenuScene, transition: mainMenuTransition);
    }
}
