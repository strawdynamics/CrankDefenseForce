import PlaydateKit

final class Game: PlaydateGame {
	var scenePresenter: ScenePresenter
	
	init() {
//		Graphics.drawMode = .fillWhite
		Display.refreshRate = 40.0
		Sprite.setAlwaysRedraw(true)
		self.scenePresenter = ScenePresenter(firstScene: MainMenuScene())
	}
	
	func update() -> Bool {
		Time.updateDeltaTime()
		
		Graphics.clear()
		Sprite.updateAndDrawDisplayListSprites()
		
		self.scenePresenter.update()
		
		if GameSettings.showFps {
			System.drawFPS()
		}
		
		return true
	}

	func gameWillPause() {
		print("Paused!")
	}
}

