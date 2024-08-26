import PlaydateKit

final class Game: PlaydateGame {
	public var scenePresenter: ScenePresenter
	
	public var time: Time
	
	init() {
		self.scenePresenter = ScenePresenter(firstScene: MainMenuScene())
		self.time = Time()
	}
	
	func update() -> Bool {
		self.time.updateDeltaTime()
		
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

