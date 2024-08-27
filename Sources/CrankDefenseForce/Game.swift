import PlaydateKit

final class Game: PlaydateGame {
	var scenePresenter: ScenePresenter
	
	init() {
		self.scenePresenter = ScenePresenter(firstScene: MainMenuScene())
	}
	
	func update() -> Bool {
		Time.updateDeltaTime()
		
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

