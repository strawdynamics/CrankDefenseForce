import PlaydateKit

class GameplayScene: BaseScene {
	var gameRunner: GameRunner? = nil
	
	override func update() {
		gameRunner?.update()
	}
	
	override func enter() {
		gameRunner = GameRunner()
	}
	
	override func start() {
		System.addMenuItem(title: "Give up") {
			game.scenePresenter.changeScene(
				newScene: MainMenuScene(),
				transition: CrtOutSceneTransition(),
			)
			
			System.removeAllMenuItems()
		}
	}
	
	override func exit() {
		gameRunner?.exit()
	}
	
	override func finish() {
		gameRunner?.finish()
	}
}
