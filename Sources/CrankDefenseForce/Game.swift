import PlaydateKit

final class Game: PlaydateGame {
	private var scenePresenter: ScenePresenter
	
	init() {
		self.scenePresenter = ScenePresenter(firstScene: MainMenuScene())
	}
	
	func update() -> Bool {
		Time.deltaTime = System.elapsedTime
		System.resetElapsedTime()
		
		Graphics.clear()
		Sprite.updateAndDrawDisplayListSprites()
		
		self.scenePresenter.update()
		
		System.drawFPS()
		
		return true
	}

	func gameWillPause() {
		print("Paused!")
	}
}

